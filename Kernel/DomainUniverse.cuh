#if false

#ifndef RHO__define_guard__Kernel__DomainUniverse_cuh
#define RHO__define_guard__Kernel__DomainUniverse_cuh

#include "init.cuh"
#include "Domain.cuh"

namespace rho {

class DomainUniverse: public Domain {
public:
	RHO__cuda Space* root() const override;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda DomainUniverse(Space* root);

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda bool Contain(const Num* root_point) const override;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda bool RayCastB(const Ray& ray) const override;
	RHO__cuda RayCastData RayCast(const Ray& ray) const override;
	RHO__cuda void RayCastForRender(RayCastDataPair& rcdp,
									ComponentCollider* cmpt_collider,
									const Ray& ray) const override;
	RHO__cuda bool RayCastFull(RayCastDataVector& dst,
							   const Ray& ray) const override;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda void GetTodTan(Num* dst, const RayCastData& rcd,
							 const Num* root_direct) const override;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda size_t Complexity() const override;

private:
	Space* ref_;
};

}

#endif

#endif