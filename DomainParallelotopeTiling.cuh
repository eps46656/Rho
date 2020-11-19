#ifndef RHO__define_guard__DomainParallelotopeTiling_cuh
#define RHO__define_guard__DomainParallelotopeTiling_cuh

#include "Kernel/Kernel.cuh"

namespace rho {

class DomainParallelotopeTiling: public DomainSole {
public:
	RHO__cuda DomainParallelotopeTiling(Space* ref = nullptr);

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda const Domain* Refresh() const override;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda bool Contain_s(const Num* point) const override;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda size_t RayCastComplexity() const override;
	RHO__cuda bool RayCast(RayCastData& dst, const Ray& ray) const override;
	RHO__cuda bool RayCastB(const Ray& ray) const override;
	RHO__cuda void RayCastPair(RayCastDataPair& dst,
							   const Ray& ray) const override;
	RHO__cuda size_t RayCastFull(RayCastData* dst,
								 const Ray& ray) const override;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda void GetTodTan(Num* dst, const RayCastData& rcd,
							 const Num* root_direct) const override;

private:
	mutable Mat tod_matrix_;

	RHO__cuda Num RayCast_(const Ray& ray) const;
};

}

#endif