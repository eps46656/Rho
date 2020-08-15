#if false

#include "define.cuh"
#include "Kernel.cuh"

namespace rho {

Space* DomainUniverse::root() const { return this->ref_->root(); }

#///////////////////////////////////////////////////////////////////////////////

DomainUniverse::DomainUniverse(Space* ref): Domain(Type::universe), ref_(ref) {}

#///////////////////////////////////////////////////////////////////////////////

bool DomainUniverse::Contain(const Num* root_point) const { return true; }

#///////////////////////////////////////////////////////////////////////////////

bool DomainUniverse::RayCastB(const Ray& ray) const { return false; }

RayCastData DomainUniverse::RayCast(const Ray& ray) const {
	return RayCastData();
}

void DomainUniverse::RayCastForRender(RayCastDataPair& rcdp,
									  ComponentCollider* cmpt_collider,
									  const Ray& ray) const {
	return;
}

bool DomainUniverse::RayCastFull(RayCastDataVector& dst, const Ray& ray) const {
	return true;
}

#///////////////////////////////////////////////////////////////////////////////

void DomainUniverse::GetTodTan(Num* dst, const RayCastData& rcd,
							   const Num* root_direct) const {
	Vector::Copy(dst, root_direct);
}

#///////////////////////////////////////////////////////////////////////////////

size_t DomainUniverse::Complexity() const { return 0; }

}

#endif