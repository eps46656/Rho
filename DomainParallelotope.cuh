#ifndef RHO__define_guard__DomainParallelotope_cuh
#define RHO__define_guard__DomainParallelotope_cuh

#include "Kernel/Kernel.cuh"

namespace rho {

class DomainParallelotope: public DomainSole {
public:
	struct RayCastTemp {
		Num t[2];
		size_t contain_flag[2];
	};

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda DomainParallelotope(Space* ref = nullptr);

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
	mutable cntr::Vector<Mat> tod_matrix_;

	RHO__cuda bool RayCast_(const Ray& ray, RayCastTemp& rct) const;
};

}

#endif