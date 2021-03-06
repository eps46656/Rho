#include "define.cuh"
#include "Kernel.cuh"

#define B 0.1

namespace rho {

const Space* ComponentLightPoint::ref() const { return this->ref_; }
const Space* ComponentLightPoint::root() const { return this->ref_->root(); }

dim_t ComponentLightPoint::root_dim() const { return this->ref_->root_dim(); }

Num3& ComponentLightPoint::intensity() { return this->intensity_; }
const Num3& ComponentLightPoint::intensity() const { return this->intensity_; }

ComponentLightPoint* ComponentLightPoint::set_ref(const Space* ref) {
	this->ref_ = ref;
	return this;
}

#///////////////////////////////////////////////////////////////////////////////

ComponentLightPoint::ComponentLightPoint(const Space* ref,
										 const Num3& intensity):
	ref_(ref),
	intensity_(intensity) {}

#///////////////////////////////////////////////////////////////////////////////

bool ComponentLightPoint::Refresh() const {
	return this->ref_->Refresh() && this->intensity_[0].ge<0>() &&
		   this->intensity_[1].ge<0>() && this->intensity_[2].ge<0>();
}

#///////////////////////////////////////////////////////////////////////////////

Num3 ComponentLightPoint::intensity(
	const Num* root_point, const Tod& tod,
	const cntr::Vector<const ComponentCollider*>& cmpt_collider,
	const Num* reflection_vector, const Texture::Data& texture_data, Ray& ray,
	Num pre_dist) const {
	// from light point to hit point

	Vec direct;
	Vector::sub(direct, root_point, this->ref_->root_origin());

	Num face_angle_cos(angle_cos(this->root_dim(), direct, tod.orth));
	bool indirect(face_angle_cos.lt<0>());

	// check if light is blocked by other colliders

	if (!indirect) {
		Copy<RHO__max_dim>(ray.origin, this->ref_->root_origin());
		Copy<RHO__max_dim>(ray.direct, direct);

		RayCastData a;

		for (size_t i(0); i != cmpt_collider.size(); ++i) {
			if (cmpt_collider[i]->domain()->RayCastB(ray)) {
				indirect = true;
				break;
			}
		}
	}

	Num3 r;
	Num length_sq(sq(pre_dist + abs(this->root_dim(), direct)));
	Num half_cos_sq(
		(Num(1) + angle_cos(this->root_dim(), direct, reflection_vector)) / 2);

	r[0] = (this->intensity_[0] / length_sq) *
		   pow(half_cos_sq, texture_data.shininess[0] / 2);
	r[1] = (this->intensity_[1] / length_sq) *
		   pow(half_cos_sq, texture_data.shininess[1] / 2);
	r[2] = (this->intensity_[2] / length_sq) *
		   pow(half_cos_sq, texture_data.shininess[2] / 2);

	if (indirect) {
		Num n(1 - abs(face_angle_cos));

		r[0] *= n;
		r[1] *= n;
		r[2] *= n;
	}

	return r;
}

}

#undef B