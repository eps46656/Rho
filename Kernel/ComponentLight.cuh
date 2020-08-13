#ifndef RHO__define_guard__Kernel__ComponentLight_cuh
#define RHO__define_guard__Kernel__ComponentLight_cuh

#include "init.cuh"
#include "Component.cuh"
#include "Texture.cuh"

namespace rho {

class ComponentLight: public Component {
public:
	RHO__cuda const Num3& intensity() const;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda ComponentLight(Object* object);
	RHO__cuda ComponentLight(Object* object, const Num3& intensity);

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda virtual bool Refresh() const = 0;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda virtual Num3
	intensity(const Vector& root_point, const Tod& tod,
			  const cntr::Vector<ComponentCollider*>& cmpt_collider,
			  const Vector& reflection_vector,
			  const Texture::Data& texture_data, Ray& ray,
			  Num pre_distance) const = 0;

protected:
	Num3 intensity_;
};

}

#endif