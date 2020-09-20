#include "define.cuh"
#include "Kernel.cuh"

namespace rho {

const Space* ComponentLightAmbience::ref() const { return this->ref_; }
const Space* ComponentLightAmbience::root() const { return this->ref_->root(); }

dim_t ComponentLightAmbience::root_dim() const {
	return this->ref_->root_dim();
}

Num3& ComponentLightAmbience::intensity() { return this->intensity_; }
const Num3& ComponentLightAmbience::intensity() const {
	return this->intensity_;
}

ComponentLightAmbience* ComponentLightAmbience::set_ref(const Space* ref) {
	this->ref_ = ref;
	return this;
}

#///////////////////////////////////////////////////////////////////////////////

ComponentLightAmbience::ComponentLightAmbience(const Space* ref,
											   const Num3& intensity):
	ref_(ref),
	intensity_(intensity) {}

#///////////////////////////////////////////////////////////////////////////////

bool ComponentLightAmbience::Refresh() const {
	return this->intensity_[0].ge<0>() && this->intensity_[1].ge<0>() &&
		   this->intensity_[2].ge<0>();
}

#///////////////////////////////////////////////////////////////////////////////

Num3 ComponentLightAmbience::intensity(
	const Num* root_point, const Tod& tod,
	const cntr::Vector<const ComponentCollider*>& cmpt_collider,
	const Num* reflection_vector, const Texture::Data& texture_data, Ray& ray,
	Num pre_dist) const {
	Num a(pow(pre_dist, 0.1));
	Num3 r;

	r[0] = this->intensity_[0] / a;
	r[1] = this->intensity_[1] / a;
	r[2] = this->intensity_[2] / a;

	return r;
}

}