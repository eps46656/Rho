#ifndef RHO__define_guard__Kernel__Camera_cuh
#define RHO__define_guard__Kernel__Camera_cuh

#include "init.cuh"
#include "ComponentCollider.cuh"
#include "Ray.cuh"

namespace rho {

// Only 3 dimension space can be a Camera::parent_
// Camera::dim	is always 3

class Camera {
public:
	static constexpr size_t thread_num = 1920 * 1080;

	using Collider = ComponentCollider;
	using Light = ComponentLight;
	using Material = Collider::Material;

	struct RenderData {
		mutable size_t index;
		mutable size_t depth;
		mutable Num dist;
		mutable Num3 intensity;
		mutable bool rendered;

		RHO__cuda void Clear() const;
	};

	struct Task: public cntr::BidirectionalNode {
		Ray ray;
		Num dist;
		size_t depth;
		Num3 decay;

		RHO__cuda Task* prev() const;
		RHO__cuda Task* next() const;
	};

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Space* ref();
	RHO__cuda const Space* ref() const;

	RHO__cuda const Space* root() const;

	RHO__cuda dim_t root_dim() const;

	RHO__cuda size_t image_height() const;
	RHO__cuda size_t image_width() const;
	RHO__cuda size_t image_size() const;

	RHO__cuda void resize(size_t col_dim, size_t row_dim);

	RHO__cuda size_t max_depth() const;
	RHO__cuda void set_max_depth(size_t max_depth);

	RHO__cuda size_t render_data_size() const;
	RHO__cuda RenderData* render_data() const;

	RHO__cuda Collider::Material& void_material();
	RHO__cuda const Collider::Material& void_material() const;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda void AddCollider(const Collider* collider);
	RHO__cuda void AddLight(const Light* light);

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Camera(Space* parent, size_t col_dim, size_t row_dim,
					 size_t max_depth);

	RHO__hst void RenderReady(size_t size) const;
	RHO__hst void Render(size_t block_pos_h, size_t block_pos_w,
						 size_t block_size_h, size_t block_size_w) const;

private:
	Space* ref_;

	size_t image_height_;
	size_t image_width_;
	size_t image_size_;

	size_t block_size_;

	size_t max_depth_;

#///////////////////////////////////////////////////////////////////////////////

	// used data when Imaging

	mutable size_t render_data_size_;
	mutable RenderData* render_data_;

	mutable RBT<const Collider*> collider_;

	mutable cntr::Vector<const Collider*> collider__ray_cast_order_;
	mutable cntr::Vector<const Collider*> collider__detect_order_;

	mutable cntr::Vector<const Light*> light_;

	mutable Vec direct_f_;
	mutable Vec direct_h_;
	mutable Vec direct_w_;

	Material void_material_;

	// mutable pair<cntr::BidirectionalNode*> task_stack_[thread_num];
	// thread_stack_[thread_num].first  point to all allocated task
	// thread_stack_[thraed_num].second point to which task is being processed

	// mutable Num3 intensity_sum_;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda ~Camera();

#///////////////////////////////////////////////////////////////////////////////

	RHO__glb friend void CameraRenderReady_(const Camera* camera, size_t size);
	RHO__glb friend void CameraRenderMain_(const Camera* camera,
										   const size_t block_pos_h,
										   const size_t block_pos_w,
										   const size_t block_size_h,
										   const size_t block_size_w);
};

}

#endif