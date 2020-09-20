#ifndef RHO__define_guard__ComponentLightAmbience_cuh
#define RHO__define_guard__ComponentLightAmbience_cuh

#include "init.cuh"
#include "ComponentLight.cuh"

namespace rho {

class ComponentLightAmbience: public ComponentLight {
public:
	RHO__cuda const Space* ref() const;
	RHO__cuda const Space* root() const override;

	RHO__cuda dim_t root_dim() const override;

	RHO__cuda Num3& intensity();
	RHO__cuda const Num3& intensity() const;

	RHO__cuda ComponentLightAmbience* set_ref(const Space* ref);

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda ComponentLightAmbience(const Space* ref, const Num3& intensity);

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda bool Refresh() const override;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Num3
	intensity(const Num* root_point, const Tod& tod,
			  const cntr::Vector<const ComponentCollider*>& cmpt_collider,
			  const Num* reflection_vector, const Texture::Data& texture_data,
			  Ray& ray, Num pre_dist) const override;

private:
	const Space* ref_;
	Num3 intensity_;
};

}

#endif