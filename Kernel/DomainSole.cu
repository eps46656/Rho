#include "define.cuh"
#include "Kernel.cuh"

namespace rho {

Space* DomainSole::ref() { return this->ref_; }
const Space* DomainSole::ref() const { return this->ref_; }

const Space* DomainSole::root() const {
	return this->ref_ ? this->ref_->root() : nullptr;
}

dim_t DomainSole::dim() const { return this->ref_->dim(); }
dim_t DomainSole::root_dim() const { return this->ref_->root_dim(); }
dim_t DomainSole::root_codim() const { return this->ref_->root_codim(); }

DomainSole* DomainSole::set_ref(Space* ref) {
	this->ref_ = ref;
	return this;
}

#///////////////////////////////////////////////////////////////////////////////

DomainSole::DomainSole(Space* ref): Domain(Type::sole), ref_(ref) {}

#///////////////////////////////////////////////////////////////////////////////

bool DomainSole::Contain(const Num* root_point) const {
	if (this->ref_->is_root()) { return this->Contain_s(root_point); }

	Vec point;
	this->ref_->MapPointFromRoot_rr(point, root_point);

	for (dim_t i(this->dim()); i != this->ref_->root_dim(); ++i) {
		if (point[i].ne<0>()) { return false; }
	}

	return this->Contain_s(point);
}

}