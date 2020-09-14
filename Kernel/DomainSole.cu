#include "define.cuh"
#include "Kernel.cuh"

namespace rho {

Space* DomainSole::root() const { return this->ref_->root(); }
Space* DomainSole::ref() const { return this->ref_; }

dim_t DomainSole::dim() const { return this->ref_->dim(); }
dim_t DomainSole::dim_r() const { return this->ref_->dim_r(); }
dim_t DomainSole::dim_cr() const { return this->ref_->dim_cr(); }

void DomainSole::set_ref(Space* ref) { this->ref_ = ref; }

#///////////////////////////////////////////////////////////////////////////////

DomainSole::DomainSole(Space* ref): Domain(Type::sole), ref_(ref) {}

#///////////////////////////////////////////////////////////////////////////////

bool DomainSole::Contain(const Num* root_point) const {
	if (this->root() == this->ref_) { return this->Contain_s(root_point); }

	Vec point;
	this->ref_->MapPointFromRoot_rr(point, root_point);

	for (dim_t i(this->dim()); i != this->dim_r(); ++i) {
		if (point[i].ne<0>()) { return false; }
	}

	return this->Contain_s(point);
	return true;
}

}