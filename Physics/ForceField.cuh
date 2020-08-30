#include "init.cuh"

namespace rho {

class ForceField {
public:
	RHO__cuda ForceField();
	RHO__cuda ForceField(Domain* domain);

	RHO__cuda virtual ~ForceField();

#////////////////////////////////////////////////

	RHO__cuda virtual Vector GetForce(const Vector& root_point) const = 0;
};

}