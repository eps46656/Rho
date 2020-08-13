#ifndef RHO__define_guard__ComponentLightPoint_cuh
#define RHO__define_guard__ComponentLightPoint_cuh

#include "Kernel.cuh"

namespace rho {

class ComponentLightPoint: public ComponentLight {
public:
	RHO__cuda Space* ref() const;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda ComponentLightPoint(Object* object, Space* ref,
								  const Num3& unit_intensity);

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda bool Refresh() const override;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Num3 intensity(
		const Vector& root_point, const Tod& tod,
		const cntr::Vector<ComponentCollider*>& cmpt_collider,
		const Vector& reflection_vector, const Texture::Data& texture_data,
		Ray& ray, Num pre_distance) const override;

private:
	Space* ref_;
};

}

#endif
