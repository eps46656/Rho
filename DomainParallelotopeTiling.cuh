#ifndef RHO__define_guard__DomainParallelotopeTiling_cuh
#define RHO__define_guard__DomainParallelotopeTiling_cuh

#include "Kernel/Kernel.cuh"

namespace rho {

class DomainParallelotopeTiling: public DomainSole {
public:
	RHO__cuda DomainParallelotopeTiling(Space* ref);

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda bool Refresh() const override;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda bool Contain_s(const Num* point) const override;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda bool RayCastB(const Ray& ray) const override;
	RHO__cuda RayCastData RayCast(const Ray& ray) const override;
	RHO__cuda void RayCastForRender(RayCastDataPair& rcdp,
									const ComponentCollider* cmpt_collider,
									const Ray& ray) const override;
	RHO__cuda bool RayCastFull(RayCastDataVector& dst,
							   const Ray& ray) const override;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda void GetTodTan(Num* dst, const RayCastData& rcd,
							 const Num* root_direct) const override;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda size_t Complexity() const override;

private:
	mutable Matrix tod_matrix_;

	RHO__cuda Num RayCast_(const Ray& ray) const;
};

}

#endif