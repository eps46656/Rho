#ifndef RHO__define_guard__ComponentLightAmbience_cuh
#define RHO__define_guard__ComponentLightAmbience_cuh

#include "init.cuh"
#include "ComponentLight.cuh"

namespace rho {

class ComponentLightAmbience: public ComponentLight {
public:
	Num3& intensity();
	const Num3& intensity() const;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda ComponentLightAmbience(Object* object, const Num3& intensity);

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda bool Refresh() const override;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Num3
	intensity(const Num* root_point, const Tod& tod,
			  const cntr::Vector<ComponentCollider*>& cmpt_collider,
			  const Num* reflection_vector, const Texture::Data& texture_data,
			  Ray& ray, Num pre_distance) const override;

private:
	Num3 intensity_;
};

}

#endif