#include "ForceField.cuh"

namespace rho {

class ForceFieldUniform: public ForceField {
public:
	Vector force;

#////////////////////////////////////////////////

	ForceFieldUniform();
	ForceFieldUniform(const Vector& force);

#////////////////////////////////////////////////

	RHO__cuda Vector GetForce(const Vector& root_point) const override;
};

}