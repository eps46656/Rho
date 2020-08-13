#include "define.cuh"
#include "Kernel.cuh"

namespace rho {

Space* DomainSole::ref() const { return this->ref_; }
void DomainSole::set_ref(Space* ref) { this->ref_ = ref; }

dim_t DomainSole::dim_s() const { return this->ref_->dim_s(); }
dim_t DomainSole::dim_cr() const { return this->ref_->dim_cr(); }

#///////////////////////////////////////////////////////////////////////////////

DomainSole::DomainSole(Space* ref): Domain(ref->root()), ref_(ref) {}

#///////////////////////////////////////////////////////////////////////////////

bool DomainSole::Contain(const Num* root_point) const {
	if (this->root() == this->ref_) { return this->Contain_s(root_point); }

	NumVector point;
	this->ref_->MapPointFromRoot_rr(point, root_point);

	for (dim_t i(this->dim_s()); i != this->dim_r(); ++i) {
		if (point[i].ne<0>()) { return false; }
	}

	return this->Contain_s(point);
}

}