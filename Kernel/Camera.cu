#include "define.cuh"
#include "Kernel.cuh"

#define RHO__throw__local(description) RHO__throw(Camera, __func__, description)

#define RHO__task_stack_second (task_stack.second + task_stack.first)

namespace rho {

void Camera::RenderData::Clear() const {
	this->intensity[0] = this->intensity[1] = this->intensity[2] = this->dist =
		0;
}

#///////////////////////////////////////////////////////////////////////////////

Manager* Camera::manager() const { return this->manager_; }

Space* Camera::root() const { return this->root_; }
Space* Camera::ref() const { return this->ref_; }

size_t Camera::dim_r() const { return this->dim_r_; }

size_t Camera::image_height() const { return this->image_height_; }
size_t Camera::image_width() const { return this->image_width_; }
size_t Camera::image_size() const { return this->image_size_; }

void Camera::resize(size_t image_height, size_t image_width) {
	if (!image_height) { this->image_height_ = image_height; }
	if (!image_width) { this->image_width_ = image_width; }
}

size_t Camera::max_depth() const { return this->max_depth_; }

void Camera::set_max_depth(size_t max_depth) { this->max_depth_ = max_depth; }

pair<size_t, Camera::RenderData*>& Camera::render_data() const {
	return this->render_data_;
}

#///////////////////////////////////////////////////////////////////////////////

Camera::Camera(Space* ref, size_t image_height, size_t image_width,
			   size_t max_depth):
	manager_(ref->manager()),
	root_(ref->root()), ref_(ref), dim_r_(ref->dim_r()),
	image_height_(image_height), image_width_(image_width),
	image_size_(image_height * image_width), max_depth_(max_depth),
	render_data_(0, nullptr) {
	this->manager_->RegisterCamera_(this);
}

Camera::~Camera() {}

#///////////////////////////////////////////////////////////////////////////////

void Camera::RenderReady(size_t size) const {
	// printf("render ready begin\n");

	Camera_Render_pre_<<<1, 1>>>(this, size);

	// printf("render ready end\n");
}

void Camera::Render(size_t block_pos_h, size_t block_pos_w, size_t block_size_h,
					size_t block_size_w) const {
	/*printf("render begin\n");

	Camera_Render_main_ << <
		dim3(1, 1, 480),
		dim3(1, 1, 270) >> > (this);

	cudaDeviceSynchronize();

	printf("render end\n");*/

	/*Camera_Render_ << <1, 1 >> > (this);*/

	Camera_Render_main_<<<3, 1024>>>(this, block_pos_h, block_pos_w,
									 block_size_h, block_size_w);
}

RHO__glb void Camera_Render_(const Camera* camera) {
	for (size_t i(0); i != camera->render_data_.first; ++i)
		camera->render_data_.second[i].rendered = false;
}

RHO__glb void Camera_Render_pre_(const Camera* camera, size_t size) {
	camera->ref_->RefreshSelf();

	{
		const RBT<Object*>& object(camera->manager_->active_object());

		auto iter(object.begin());

		if (RHO__debug_flag) {
			for (auto end(object.end()); iter != end; ++iter)
				if (!(*iter)->Refresh())
					RHO__throw__local("ReadyForRendering error");
		} else {
			for (auto end(object.end()); iter != end; ++iter)
				(*iter)->Refresh();
		}
	}

	{
		const ComponentContainer& cmpt_cntr(camera->manager_->active_cmpt());

		camera->cmpt_collider_.Clear();
		camera->cmpt_collider_.Reserve(cmpt_cntr.size());

		camera->cmpt_light_.Clear();
		camera->cmpt_light_.Reserve(cmpt_cntr.size());

		auto iter(cmpt_cntr.begin());

		for (auto end(cmpt_cntr.end()); iter != end; ++iter) {
			if (!(*iter)->Refresh()) RHO__throw__local("Refresh error");

			switch ((*iter)->type) {
				case Component::Type::collider: {
					camera->cmpt_collider_.Push(
						static_cast<ComponentCollider*>(*iter));

					break;
				}
				case Component::Type::light: {
					camera->cmpt_light_.Push(
						static_cast<ComponentLight*>(*iter));

					break;
				}
			}
		}

		Sort(camera->cmpt_collider_.begin(), camera->cmpt_collider_.end(),
			 [](const ComponentCollider* x, const ComponentCollider* y) {
				 return x->domain()->Complexity() < y->domain()->Complexity();
			 });
	}

#///////////////////////////////////////////////////////////////////////////////

	camera->direct_f_.set_dim(3);
	camera->direct_h_.set_dim(3);
	camera->direct_w_.set_dim(3);

	Copy(camera->dim_r_, camera->direct_f_, camera->ref_->root_axis());
	Copy(camera->dim_r_, camera->direct_h_,
		 camera->ref_->root_axis() + RHO__max_dim);
	Copy(camera->dim_r_, camera->direct_w_,
		 camera->ref_->root_axis() + RHO__max_dim * 2);

	camera->direct_f_ -= camera->direct_h_;
	camera->direct_f_ -= camera->direct_w_;

	camera->direct_h_ *= Num(2) / camera->image_height_;
	camera->direct_w_ *= Num(2) / camera->image_width_;

#///////////////////////////////////////////////////////////////////////////////

	if (camera->render_data_.first < size) {
		camera->render_data_.first = size;
		Delete(camera->render_data_.second);
		camera->render_data_.second = Malloc<Camera::RenderData>(size);
	}

	// camera->RenderDataRefresh_(render_data);
}

#///////////////////////////////////////////////////////////////////////////////

RHO__glb void Camera_Render_main_(const Camera* camera,
								  const size_t block_pos_h,
								  const size_t block_pos_w,
								  const size_t block_size_h,
								  const size_t block_size_w) {
	const size_t thread_num(RHO__thread_num);
	const size_t thread_id(RHO__thread_index);
	const size_t block_size(block_size_h * block_size_w);

	// variable to store current trace data

	size_t render_index(thread_id);
	Camera::RenderData* render_data;

	Ray ray;

	Num dist;
	size_t depth;
	Num3 decay;

	Num dist_sq;
	Num d_dist;

	RayCastDataPair rcdp;
	Vector point[2];

	ComponentCollider* collider_a;
	ComponentCollider* collider_b;

	Material* material_a;
	Material* material_b;

	Texture::Data texture_data;

	Num3 transmittance;
	Num3 reflectance;
	Num3 difuss_reflectance;

	Tod tod;

	Vector reflection_vector;

	pair<size_t, Camera::Task*> task_stack{ 0, Malloc<Camera::Task>(
												   camera->max_depth_) };

	NumVector temp;

#///////////////////////////////////////////////////////////////////////////////

	for (;;) {
		if (task_stack.first) {
			// the current have not been done
			// we pop the task from pre-tracing

			--task_stack.first;

			Vector::Copy(ray.origin, RHO__task_stack_second->origin);
			Vector::Copy(ray.direct, RHO__task_stack_second->direct);

			dist = RHO__task_stack_second->dist;
			depth = RHO__task_stack_second->depth;

			decay = RHO__task_stack_second->decay;

		} else {
			// if then current pixel have been done
			// task_stack will be vacant
			// then we can process the next

			if (block_size <= render_index) { return; }

			render_data = camera->render_data_.second + render_index;
			render_data->dist = 0;
			render_data->intensity[0] = 0;
			render_data->intensity[1] = 0;
			render_data->intensity[2] = 0;

			size_t i(render_index / block_size_w);
			size_t j(render_index - i * block_size_w);

			Vector::Copy(ray.origin, camera->ref_->root_origin());

#pragma unroll
			for (dim_t k(0); k != RHO__max_dim; ++k) {
				ray.direct[k] = camera->direct_f_[k] +
								camera->direct_h_[k] * (block_pos_h + i) +
								camera->direct_w_[k] * (block_pos_w + j);
			}

			dist = 0;
			depth = 0;

			decay[0] = 1;
			decay[1] = 1;
			decay[2] = 1;

			render_index += thread_num;
		}

#///////////////////////////////////////////////////////////////////////////////

		// every point between ray.origin and the first hit point is
		// in the material a
		// every point between the first and second hit points is
		// in the material b

		ray.RayCastForRender(rcdp, camera->cmpt_collider_);

		if (!rcdp[0]) {
			/*goto function_head; */
			continue;
		}

		line<RHO__max_dim>(point[0], rcdp[0]->t, ray.direct, ray.origin);

		if (rcdp[1])
			line<RHO__max_dim>(point[1], rcdp[1]->t, ray.direct, ray.origin);

#///////////////////////////////////////////////////////////////////////////////

			// 在另一面計算在材質a中的路徑長
			// 計算在材質a中的穿透率

#pragma unroll
		for (dim_t i(0); i != RHO__max_dim; ++i)
			temp[i] = (ray.origin[i] + point[0][i]) / 2;

		material_a = (collider_a = camera->manager_->GetComponentCollider(temp))
						 ? collider_a->object()->material()
						 : camera->manager_->void_material();

		// get collider_a

		// if collider_a is exist
		// get material from its object

		// if not
		// get void material from manager

		// object's material are initialized to default material

		d_dist = abs(camera->dim_r(), ray.direct) * rcdp[0]->t;

		if (render_data->dist.eq<0>()) { render_data->dist = d_dist; }

		dist_sq = sq(dist += d_dist);

		decay[0] *= pow(material_a->transmittance[0], d_dist);
		decay[1] *= pow(material_a->transmittance[1], d_dist);
		decay[2] *= pow(material_a->transmittance[2], d_dist);

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

		rcdp[0]->domain->GetTodTan(tod.tan, rcdp[0], ray.direct);

#pragma unroll
		for (dim_t i(0); i != RHO__max_dim; ++i)
			tod.orth[i] = ray.direct[i] - tod.tan[i];

		texture_data =
			rcdp[0]->cmpt_collider->texture()->GetData(point[0], tod.tan);

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

		transmittance = texture_data.transmittance;
		reflectance = texture_data.reflectance;

		// transmission

		if (transmittance[0].ne<0>() || transmittance[1].ne<0>() ||
			transmittance[2].ne<0>()) {
			/*collider_b = camera->manager_->GetComponentCollider(
				rcdp[1] ? (point[0] + point[1]) / 2 : point[0] + ray.direct);*/

			if (rcdp[1]) {
#pragma unroll
				for (dim_t i(0); i != RHO__max_dim; ++i)
					temp[i] = (point[0][i] + point[1][i]) / 2;
			} else {
#pragma unroll
				for (dim_t i(0); i != RHO__max_dim; ++i)
					temp[i] = point[0][i] + ray.direct[i];
			}

			material_b =
				(collider_b = camera->manager_->GetComponentCollider(temp))
					? collider_b->object()->material()
					: camera->manager_->void_material();

			if (material_b->transmittance[0].ne<0>() ||
				material_b->transmittance[1].ne<0>() ||
				material_b->transmittance[2].ne<0>()) {
				RefractionData refraction(rcdp[0], tod, material_a, material_b);

				if (refraction.transmittance.eq<0>()) {
					reflectance[0] += transmittance[0];
					reflectance[1] += transmittance[1];
					reflectance[2] += transmittance[2];

					transmittance[0] = 0;
					transmittance[1] = 0;
					transmittance[2] = 0;
				} else {
					Num n(1 - refraction.transmittance);
					Num3 next_decay;

					reflectance[0] += transmittance[0] * n;
					reflectance[1] += transmittance[1] * n;
					reflectance[2] += transmittance[2] * n;

					transmittance[0] *= refraction.transmittance;
					transmittance[1] *= refraction.transmittance;
					transmittance[2] *= refraction.transmittance;

					next_decay[0] = decay[0] * transmittance[0];
					next_decay[1] = decay[1] * transmittance[1];
					next_decay[2] = decay[2] * transmittance[2];

					// after (long long) judge
					// we push a task to task_stack

					// printf("reflection task add\n");

					if (task_stack.first < camera->max_depth_) {
						Vector::Copy(RHO__task_stack_second->origin, point[0]);
						line<RHO__max_dim>(RHO__task_stack_second->direct,
										   refraction.parallel_ratio, tod.tan,
										   tod.orth);
						RHO__task_stack_second->dist = dist;
						RHO__task_stack_second->depth = depth + 1;
						RHO__task_stack_second->decay = Move(next_decay);

						++task_stack.first;
					}
				}
			}
		}

#pragma unroll
		for (dim_t i(0); i != RHO__max_dim; ++i)
			reflection_vector[i] = tod.tan[i] - tod.orth[i];

		// reflection

		if (reflectance[0].ne<0>() || reflectance[1].ne<0>() ||
			reflectance[2].ne<0>()) {
			Num3 next_decay;
			next_decay[0] = decay[0] * reflectance[0];
			next_decay[1] = decay[1] * reflectance[1];
			next_decay[2] = decay[2] * reflectance[2];

			/*
			camera->min_recv_intensity_[0] < camera->intensity_sum_[0]
				* next_intensity_decay[0] / dist_sq ||
				camera->min_recv_intensity_[1] < camera->intensity_sum_[1]
				* next_intensity_decay[1] / dist_sq ||
				camera->min_recv_intensity_[2] < camera->intensity_sum_[2]
				* next_intensity_decay[2] / dist_sq
			*/

			if (task_stack.first < camera->max_depth_) {
				// after (long long) judge
				// we push a task to task_stack

				Vector::Copy(RHO__task_stack_second->origin, point[0]);
				Vector::Copy(RHO__task_stack_second->direct, reflection_vector);
				RHO__task_stack_second->dist = dist;
				RHO__task_stack_second->depth = depth + 1;
				RHO__task_stack_second->decay = Move(next_decay);

				++task_stack.first;
			}
		}

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

		// Bling Phong specular
		// check blocked

		{
			bool b(true);

			for (size_t i(0); i != 3; ++i) {
				difuss_reflectance[i] = 1 - transmittance[i] - reflectance[i];
				if ((difuss_reflectance[i]).le<0>()) {
					difuss_reflectance[i] = 0;
				} else {
					b = false;
				}
			}

			if (b) {
				// goto function_head;
				continue;
			}
		}

		for (size_t i(0); i != camera->cmpt_light_.size(); ++i) {
			// influence caused by position is processed in
			// ComponentLight::intensity point tod reflection_vector ray
			// pre_length

			// influence caused by texture or material is processed in Camera
			// material transmittence
			// texture reflectance
			// texture transmittance
			// refraction transmittance

			Num3 intensity(camera->cmpt_light_[i]->intensity(
				point[0], tod, camera->cmpt_collider_, reflection_vector,
				texture_data, ray, dist));

			render_data->intensity[0] += texture_data.color[0] / 255 *
										 intensity[0] * difuss_reflectance[0] *
										 decay[0];
			render_data->intensity[1] += texture_data.color[1] / 255 *
										 intensity[1] * difuss_reflectance[1] *
										 decay[1];
			render_data->intensity[2] += texture_data.color[2] / 255 *
										 intensity[2] * difuss_reflectance[2] *
										 decay[2];
		}
	}

	// goto function_head;
}

void Camera::RenderDataRefresh_(RenderData* render_data) const {
	/*if (this->render_data_.first < this->size_) {
		Free(this->render_data_.second);
		this->render_data_.second =
			Malloc<RenderData>(this->size_);
	}*/

	this->render_data_.second = render_data;

	printf("render data alloc end\n");
}
}
