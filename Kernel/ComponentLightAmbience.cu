#include "define.cuh"
#include "ComponentLightAmbience.cuh"

namespace rho {

Num3& ComponentLightAmbience::intensity() { return this->intensity_; }
const Num3& ComponentLightAmbience::intensity() const {
	return this->intensity_;
}

#///////////////////////////////////////////////////////////////////////////////

ComponentLightAmbience::ComponentLightAmbience(Object* object,
											   const Num3& intensity):
	ComponentLight(object),
	intensity_(intensity) {}

#///////////////////////////////////////////////////////////////////////////////

bool ComponentLightAmbience::Refresh() const {
	return this->intensity_[0].ge<0>() && this->intensity_[1].ge<0>() &&
		   this->intensity_[2].ge<0>();
}

#///////////////////////////////////////////////////////////////////////////////

Num3 ComponentLightAmbience::intensity(
	const Num* root_point, const Tod& tod,
	const cntr::Vector<ComponentCollider*>& cmpt_collider,
	const Num* reflection_vector, const Texture::Data& texture_data, Ray& ray,
	Num pre_distance) const {
	Num a(pow(pre_distance, 0.1));
	Num3 r;

	r[0] = this->intensity_[0] / a;
	r[1] = this->intensity_[1] / a;
	r[2] = this->intensity_[2] / a;

	return r;
}

}