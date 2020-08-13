#include "define.cuh"
#include "DomainComplement.cuh"

namespace rho {

Domain* DomainComplement::domain() const { return this->domain_; }

void DomainComplement::domain(Domain* domain) { this->domain_ = domain; }

#///////////////////////////////////////////////////////////////////////////////

DomainComplement::DomainComplement(Domain* domain):
	DomainComplex(domain->root()), domain_(domain) {}

#///////////////////////////////////////////////////////////////////////////////

void DomainComplement::Refresh() const {}

bool DomainComplement::ReadyForRendering() const {
	return this->root() == this->domain_->root();
}

#///////////////////////////////////////////////////////////////////////////////

bool DomainComplement::Contain(const Vector& root_point) const {
	return !this->domain_->Contain(root_point);
}

#///////////////////////////////////////////////////////////////////////////////

RayCastData DomainComplement::RayCast(const Ray& ray) const {
	RayCastData rcd(this->domain_->RayCast(ray));

	if (rcd) { rcd->type.set(!rcd->type.fr(), !rcd->type.to()); }

	return rcd;
}

cntr::Vector<RayCastData> DomainComplement::RayCastFull(const Ray& ray) const {
	cntr::Vector<RayCastData> rcdv(this->domain_->RayCastFull(ray));

	for (size_t i(0); i != rcdv.size(); ++i) rcdv[i]->type.reverse();

	return rcdv;
}

void DomainComplement::RayCastForRender(pair<RayCastData>& rcdp,
										ComponentCollider* cmpt_collider,
										const Ray& ray) const {
	RayCastDataCore* a[2] = { rcdp.first, rcdp.second };

	this->domain_->RayCastForRender(rcdp, cmpt_collider, ray);

	if (a[1] == rcdp.second) { return; }

	if (a[0] == rcdp.second) {
		a[0]->type.reverse();
	} else {
		if (a[0] != rcdp.first) { a[0]->type.reverse(); }
		if (a[1] != rcdp.second) { a[1]->type.reverse(); }
	}
}

#///////////////////////////////////////////////////////////////////////////////
/*
bool DomainComplement::IsTanVector(
	const Vector& root_point, const Vector& root_vector)const {

	switch (this->domain_->GetContainType(root_point)) {
		case ContainType::none:return true;
		case ContainType::full:return false;
	}

	return this->domain_->IsTanVector(root_point, root_vector);
}*/

}