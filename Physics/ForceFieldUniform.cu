#include "ForceFieldUniform.cuh"

namespace rho {

ForceFieldUniform::ForceFieldUniform() {}
ForceFieldUniform::ForceFieldUniform(const Vector& force_): force(force_) {}

#////////////////////////////////////////////////

Vector ForceFieldUniform::GetForce(const Vector& root_point) const {
	return this->force;
}

}