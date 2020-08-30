#include "define.cuh"
#include "Kernel.cuh"

namespace rho {

ComponentLight::ComponentLight(Object* object):
	Component(Type::light, object) {}

}