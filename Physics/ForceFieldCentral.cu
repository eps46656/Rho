#include "ForceFieldCentral.cuh"

namespace rho {

Space* ForceFieldCentral::ref() const { return this->ref_; }
Num ForceFieldCentral::force() const { return this->force_; }

void ForceFieldCentral::set_ref(Space* ref) { this->ref_ = ref; }
void ForceFieldCentral::set_force(Num force) { this->force_ = force; }

#////////////////////////////////////////////////

Vector ForceFieldCentral::GetForce(const Vector& point) const {
	RHO__debug_if(this->ref_->dim_r() != point.size())
		RHO__throw(ForceFieldCentral, __func__, "dim error");

	Vector direct(this->ref_->dim_r());
	Num direct_sq(0);

	for (size_t i(0); i != this->ref_->dim_r(); ++i) {
		direct[i] = point[i] - this->ref_->root_origin_r()[i];
		direct_sq += sq(point[i] - this->ref_->root_origin_r()[i]);
	}

	return direct *=
		   this->force_ / pow(direct_sq, Num(this->ref_->dim_r()) / 2);
}

}