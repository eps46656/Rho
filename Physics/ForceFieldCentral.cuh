#ifndef RHO__define_guard__Physics__ForceFieldCentral_cuh
#define RHO__define_guard__Physics__ForceFieldCentral_cuh

#include "init.cuh"
#include "ForceField.cuh"

namespace rho {

class ForceFieldCentral: public ForceField {
public:
	Space* ref() const;
	Num force() const;

	void set_ref(Space* ref);
	void set_force(Num force);

#////////////////////////////////////////////////

	Vector GetForce(const Vector& point) const override;

private:
	Space* ref_;
	Num force_;
};

}

#endif