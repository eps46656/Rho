#include "define.cuh"
#include "Kernel.cuh"

namespace rho {

const Num3& ComponentLight::intensity() const { return this->intensity_; }

#///////////////////////////////////////////////////////////////////////////////

ComponentLight::ComponentLight(Object* object):
	Component(Type::light, object) {}

ComponentLight::ComponentLight(Object* object, const Num3& intensity):
	Component(Type::light, object), intensity_(intensity) {}

}