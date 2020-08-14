#include "define.cuh"
#include "DomainComplement.cuh"

#define RHO__throw__local(desc) RHO__throw(DomainComplement, __func__, desc)

namespace rho {

Domain* DomainComplement::domain() const { return this->domain_; }

void DomainComplement::domain(Domain* domain) { this->domain_ = domain; }

#///////////////////////////////////////////////////////////////////////////////

DomainComplement::DomainComplement(Space* root):
	DomainComplex(root), domain_(nullptr) {
	RHO__debug_if(!root->is_root()) RHO__throw__local("root error");
}

DomainComplement::DomainComplement(Domain* domain):
	DomainComplex(domain->root()), domain_(domain) {}

#///////////////////////////////////////////////////////////////////////////////

bool DomainComplement::Refresh() const {
	return this->domain_ && this->root() == this->domain_->root() &&
		   this->domain_->Refresh();
}

#///////////////////////////////////////////////////////////////////////////////

bool DomainComplement::Contain(const Num* root_point) const {
	return !this->domain_->Contain(root_point);
}

#///////////////////////////////////////////////////////////////////////////////

void DomainComplement::RayCastForRender(RayCastDataPair& rcdp,
										ComponentCollider* cmpt_collider,
										const Ray& ray) const {
	RayCastDataCore* a[2]{ rcdp[0], rcdp[1] };

	this->domain_->RayCastForRender(rcdp, cmpt_collider, ray);

	if (a[1] == rcdp[1]) { return; }

	if (a[0] == rcdp[1]) {
		a[0]->phase.reverse();
	} else {
		if (a[0] != rcdp[0]) { a[0]->phase.reverse(); }
		if (a[1] != rcdp[1]) { a[1]->phase.reverse(); }
	}
}

RayCastData DomainComplement::RayCast(const Ray& ray) const {
	RayCastData rcd(this->domain_->RayCast(ray));
	if (rcd) { rcd->phase.reverse(); }
	return rcd;
}

bool DomainComplement::RayCastFull(RayCastDataVector& rcdv,
								   const Ray& ray) const {
	size_t i(rcdv.size());
	bool phase(this->domain_->RayCastFull(rcdv, ray));
	for (; i != rcdv.size(); ++i) { rcdv[i]->phase.reverse(); }

	return !phase;
}

#///////////////////////////////////////////////////////////////////////////////

void DomainComplement::GetTodTan(Num* dst, const RayCastData& rcd,
								 const Num* root_direct) const {
	RHO__throw__local("call error");
}

#///////////////////////////////////////////////////////////////////////////////

size_t DomainComplement::Complexity() const {
	return this->domain_->Complexity();
}

}