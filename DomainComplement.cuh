#ifndef RHO__define_guard__DomainComplement_cuh
#define RHO__define_guard__DomainComplement_cuh

#include "Kernel/Kernel.cuh"

namespace rho {

class DomainComplement: public DomainComplex {
public:
	RHO__cuda Domain* domain() const;
	RHO__cuda void domain(Domain* domain);

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda DomainComplement(Space* root);
	RHO__cuda DomainComplement(Domain* domain);

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda bool Refresh() const override;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda bool Contain(const Num* root_point) const override;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda RayCastData RayCast(const Ray& ray) const override;
	RHO__cuda void RayCastForRender(RayCastDataPair& rcdp,
									ComponentCollider* cmpt_collider,
									const Ray& ray) const override;
	RHO__cuda bool RayCastFull(RayCastDataVector& rcdv,
							   const Ray& ray) const override;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda void GetTodTan(Num* dst, const RayCastData& rcd,
							 const Num* root_direct) const override;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda size_t Complexity() const override;

private:
	Domain* domain_;
};

}

#endif
