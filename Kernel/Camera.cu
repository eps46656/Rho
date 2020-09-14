#include "define.cuh"
#include "Kernel.cuh"

#define RHO__throw__local(desc) RHO__throw(Camera, __func__, desc)

#define RHO__task_stack_second (task_stack.second + task_stack.first)

namespace rho {

void Camera::RenderData::Clear() const {
	this->intensity[0] = this->intensity[1] = this->intensity[2] = this->dist =
		0;
}

#///////////////////////////////////////////////////////////////////////////////

Space* Camera::root() const { return this->ref_->root(); }
Space* Camera::ref() const { return this->ref_; }

size_t Camera::dim_r() const { return this->ref_->dim_r(); }

size_t Camera::image_height() const { return this->image_height_; }
size_t Camera::image_width() const { return this->image_width_; }
size_t Camera::image_size() const { return this->image_size_; }

void Camera::resize(size_t image_height, size_t image_width) {
	if (!image_height) { this->image_height_ = image_height; }
	if (!image_width) { this->image_width_ = image_width; }
}

size_t Camera::max_depth() const { return this->max_depth_; }
void Camera::set_max_depth(size_t max_depth) { this->max_depth_ = max_depth; }

size_t Camera::render_data_size() const { return this->render_data_size_; }
Camera::RenderData* Camera::render_data() const { return this->render_data_; }

ComponentCollider::Material& Camera::void_cmpt_collider_material() {
	return this->void_cmpt_collider_material_;
}

const ComponentCollider::Material& Camera::void_cmpt_collider_material() const {
	return this->void_cmpt_collider_material_;
}

#///////////////////////////////////////////////////////////////////////////////

void Camera::AddCmptCollider(ComponentCollider* cmpt_collider) {
	this->cmpt_collider__ray_cast_order_.Push(cmpt_collider);
	this->cmpt_collider__detect_order_.Push(cmpt_collider);
}

void Camera::AddCmptLight(ComponentLight* cmpt_light) {
	this->cmpt_light_.Push(cmpt_light);
}

#///////////////////////////////////////////////////////////////////////////////

Camera::Camera(Space* ref, size_t image_height, size_t image_width,
			   size_t max_depth):
	ref_(ref),
	image_height_(image_height), image_width_(image_width),
	image_size_(image_height * image_width), max_depth_(max_depth),
	render_data_size_(0), render_data_(nullptr) {}

Camera::~Camera() {}

#///////////////////////////////////////////////////////////////////////////////

void Camera::RenderReady(size_t size) const {
	CameraRenderReady_<<<1, 1>>>(this, size);
}

void Camera::Render(size_t block_pos_h, size_t block_pos_w, size_t block_size_h,
					size_t block_size_w) const {
	CameraRenderMain_<<<32, 1024>>>(this, block_pos_h, block_pos_w,
									block_size_h, block_size_w);
}

RHO__glb void CameraRenderReady_(const Camera* camera, size_t size) {
	RHO__debug_if(!camera->void_cmpt_collider_material_.Check()) {
		RHO__throw__local("material error");
	}

	camera->ref_->RefreshSelf();

	for (size_t i(0); i != camera->cmpt_light_.size(); ++i) {
#if RHO__debug_flag
		for (size_t j(i + 1); j != camera->cmpt_light_.size(); ++j) {
			if (camera->cmpt_light_[i] == camera->cmpt_light_[j]) {
				RHO__throw__local("repeat cmpt light");
			}
		}

		if (!camera->cmpt_light_[i]->Refresh()) {
			RHO__throw__local("cmpt light refresh error");
		}
#else
		camera->cmpt_light_[i]->Refresh();
#endif
	}

	{
		// compare cmpt_collider__ray_cast_order_ and
		// cmpt_collider__detect_order_
		// to ensure their elements are all same
		// and refresh them

		size_t size(camera->cmpt_collider__ray_cast_order_.size());

		RHO__debug_if(size != camera->cmpt_collider__detect_order_.size()) {
			RHO__throw__local("size error");
		}

		cntr::Vector<ComponentCollider*> temp(
			camera->cmpt_collider__ray_cast_order_);
		Sort(temp.begin(), temp.end());

		for (size_t i(0); i != size; ++i) {
			if (BinarySearch(temp, size,
							 camera->cmpt_collider__detect_order_[i]) == size) {
				RHO__throw__local("not found error");
			}

			if (!camera->cmpt_collider__detect_order_[i]->Refresh()) {
				RHO__throw__local("refresh error");
			}
		}

		Sort(camera->cmpt_collider__ray_cast_order_.begin(),
			 camera->cmpt_collider__ray_cast_order_.end(),
			 [](const ComponentCollider* x, const ComponentCollider* y) {
				 return x->domain()->RayCastComplexity() <
						y->domain()->RayCastComplexity();
			 });
	}

#///////////////////////////////////////////////////////////////////////////////

	{
		const Num* a[]{ camera->ref_->root_axis(),
						camera->ref_->root_axis() + RHO__max_dim,
						camera->ref_->root_axis() + RHO__max_dim * 2 };

#pragma unroll
		for (dim_t i(0); i != RHO__max_dim; ++i)
			camera->direct_f_[i] = a[0][i] - a[1][i] - a[2][i];

#pragma unroll
		for (dim_t i(0); i != RHO__max_dim; ++i)
			camera->direct_h_[i] = a[1][i] * 2 / camera->image_height_;

#pragma unroll
		for (dim_t i(0); i != RHO__max_dim; ++i)
			camera->direct_w_[i] = a[2][i] * 2 / camera->image_width_;
	}

#///////////////////////////////////////////////////////////////////////////////

	if (camera->render_data_size_ < size) {
		camera->render_data_size_ = size;
		Delete(camera->render_data_);
		camera->render_data_ = Malloc<Camera::RenderData>(size);
	}
}

#///////////////////////////////////////////////////////////////////////////////

RHO__glb void CameraRenderMain_(const Camera* camera, const size_t block_pos_h,
								const size_t block_pos_w,
								const size_t block_size_h,
								const size_t block_size_w) {
	const size_t thread_num(RHO__thread_num);
	const size_t thread_id(RHO__thread_index);
	const size_t block_size(block_size_h * block_size_w);

	size_t render_index(thread_id);
	Camera::RenderData* render_data;

	Num dist_sq;
	Num d_dist;

	RayCastDataPair rcdp;
	Vec point[2];

	ComponentCollider* collider[3];

	const ComponentCollider::Material* material[2];

	Texture::Data texture_data;

	Num3 transmittance;
	Num3 reflectance;
	Num3 difuss_reflectance;

	Tod tod;

	Vector reflection_vector;

	size_t task_size(0);
	cntr::BidirectionalNode task_node;

#define RHO__static_task_size 10

	Camera::Task static_task[RHO__static_task_size];
	// this task is to avoid using New<Camera::Task>()

	for (size_t i(0); i != RHO__static_task_size; ++i)
		task_node.PushNext(static_task + i);

	Camera::Task* task;
	Camera::Task* next_task;

	Vec temp;

#///////////////////////////////////////////////////////////////////////////////

	for (;; --task_size) {
		if (task_size) {
			// the current have not been done
			// we pop the task from pre-tracing
			task = static_cast<Camera::Task*>(task->prev);
		} else {
			// if then current pixel have been done
			// task_stack will be vacant
			// then we can process the next

			if (block_size <= render_index) { return; }

			++task_size;
			task = static_cast<Camera::Task*>(task_node.next);

			render_data = camera->render_data_ + render_index;
			render_data->dist = 0;
			render_data->intensity[0] = 0;
			render_data->intensity[1] = 0;
			render_data->intensity[2] = 0;

			size_t i(render_index / block_size_w);
			size_t j(render_index - i * block_size_w);

			Vector::Copy(task->ray.origin, camera->ref_->root_origin());

			i += block_pos_h;
			j += block_pos_w;

#pragma unroll
			for (dim_t k(0); k != RHO__max_dim; ++k) {
				task->ray.direct[k] = camera->direct_f_[k] +
									  camera->direct_h_[k] * i +
									  camera->direct_w_[k] * j;
			}

			task->dist = 0;
			task->depth = 0;

			task->decay[0] = 1;
			task->decay[1] = 1;
			task->decay[2] = 1;

			render_index += thread_num;
		}

#///////////////////////////////////////////////////////////////////////////////

		// every point between ray.origin and the first hit point is
		// in the material a
		// every point between the first and second hit points is
		// in the material b

		rcdp[0] = nullptr;
		rcdp[1] = nullptr;
		collider[2] = nullptr;

		{
			Num pre_t(-1);

			for (size_t i(0);
				 i != camera->cmpt_collider__ray_cast_order_.size(); ++i) {
				camera->cmpt_collider__ray_cast_order_[i]
					->domain()
					->RayCastPair(rcdp, task->ray);

				if (rcdp[0]) {
					if (pre_t != rcdp[0]->t) {
						pre_t = rcdp[0]->t;
						collider[2] = camera->cmpt_collider__ray_cast_order_[i];
					}
				}
			}
		}

		if (!rcdp[0]) {
			/*goto function_head; */
			continue;
		}

		task->ray.point(point[0], rcdp[0]->t);

		if (rcdp[1]) { task->ray.point(point[1], rcdp[1]->t); }

#///////////////////////////////////////////////////////////////////////////////

		// calculate the dist fromt origin to point[0]
		// to get the transmittance through material a

		task->ray.point(temp, rcdp[0]->t / 2);

		collider[0] = nullptr;

		for (size_t i(0); i != camera->cmpt_collider__detect_order_.size();
			 ++i) {
			if (camera->cmpt_collider__detect_order_[i]->Contain(temp)) {
				collider[0] = camera->cmpt_collider__detect_order_[i];
				break;
			}
		}

		material[0] = collider[0] ? &collider[0]->material()
								  : &camera->void_cmpt_collider_material();

		// get collider[0]

		// if collider[0] is exist
		// get material from its object

		// if not
		// get void material from manager

		// object's material are initialized to default material

		d_dist = abs(camera->dim_r(), task->ray.direct) * rcdp[0]->t;

		if (render_data->dist.eq<0>()) { render_data->dist = d_dist; }

		dist_sq = sq(task->dist += d_dist);

		task->decay[0] *= pow(material[0]->transmittance[0], d_dist);
		task->decay[1] *= pow(material[0]->transmittance[1], d_dist);
		task->decay[2] *= pow(material[0]->transmittance[2], d_dist);

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

		rcdp[0]->domain->GetTodTan(tod.tan, rcdp[0], task->ray.direct);

#pragma unroll
		for (dim_t i(0); i != RHO__max_dim; ++i)
			tod.orth[i] = task->ray.direct[i] - tod.tan[i];

		texture_data = collider[2]->texture()->GetData(point[0], tod.tan);

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

		transmittance = texture_data.transmittance;
		reflectance = texture_data.reflectance;

		// transmission

		if (transmittance[0].ne<0>() || transmittance[1].ne<0>() ||
			transmittance[2].ne<0>()) {
			task->ray.point(temp, rcdp[1] ? ((rcdp[0]->t + rcdp[1]->t) / 2)
										  : (rcdp[0]->t + 1));

			collider[1] = nullptr;

			for (size_t i(0); i != camera->cmpt_collider__detect_order_.size();
				 ++i) {
				if (camera->cmpt_collider__detect_order_[i]->Contain(temp)) {
					collider[1] = camera->cmpt_collider__detect_order_[i];
					break;
				}
			}

			material[1] = collider[1] ? &collider[1]->material()
									  : &camera->void_cmpt_collider_material();

			if (material[1]->transmittance[0].ne<0>() ||
				material[1]->transmittance[1].ne<0>() ||
				material[1]->transmittance[2].ne<0>()) {
				RefractionData refraction(rcdp[0], tod, material[0],
										  material[1]);

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

					next_decay[0] = task->decay[0] * transmittance[0];
					next_decay[1] = task->decay[1] * transmittance[1];
					next_decay[2] = task->decay[2] * transmittance[2];

					// after (long long) judge
					// we push a task to task_stack

					// printf("reflection task add\n");

					if (task->depth < camera->max_depth_) {
						if (task->next == &task_node) {
							task->PushPrev(next_task = New<Camera::Task>());
						} else {
							cntr::BidirectionalNode::Swap(
								*task, *(next_task = static_cast<Camera::Task*>(
											 task->next)));
						}

						Vector::Copy(next_task->ray.origin, point[0]);
						line<RHO__max_dim>(next_task->ray.direct,
										   refraction.parallel_ratio, tod.tan,
										   tod.orth);
						next_task->dist = task->dist;
						next_task->depth = task->depth + 1;
						next_task->decay = Move(next_decay);

						++task_size;
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
			next_decay[0] = task->decay[0] * reflectance[0];
			next_decay[1] = task->decay[1] * reflectance[1];
			next_decay[2] = task->decay[2] * reflectance[2];

			if (task->depth < camera->max_depth_) {
				// after (long long) judge
				// we push a task to task_stack

				if (task->next == &task_node) {
					task->PushPrev(next_task = New<Camera::Task>());
				} else {
					cntr::BidirectionalNode::Swap(
						*task,
						*(next_task = static_cast<Camera::Task*>(task->next)));
				}

				Vector::Copy(next_task->ray.origin, point[0]);
				Vector::Copy(next_task->ray.direct, reflection_vector);
				next_task->dist = task->dist;
				next_task->depth = task->depth + 1;
				next_task->decay = next_decay;

				++task_size;
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
				point[0], tod, camera->cmpt_collider__ray_cast_order_,
				reflection_vector, texture_data, task->ray, task->dist));

			render_data->intensity[0] += texture_data.color[0] / 255 *
										 intensity[0] * difuss_reflectance[0] *
										 task->decay[0];
			render_data->intensity[1] += texture_data.color[1] / 255 *
										 intensity[1] * difuss_reflectance[1] *
										 task->decay[1];
			render_data->intensity[2] += texture_data.color[2] / 255 *
										 intensity[2] * difuss_reflectance[2] *
										 task->decay[2];
		}
	}

	Camera::Task* n(static_cast<Camera::Task*>(task_node.next));
	Camera::Task* m;

	while (n != &task_node) {
		m = static_cast<Camera::Task*>(n->next);
		int k(n - static_task);
		if (!(0 < k && k < RHO__static_task_size)) { Delete(n); }
		n = m;
	}
}
}
