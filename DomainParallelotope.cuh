#ifndef RHO__define_guard__DomainParallelotope_cuh
#define RHO__define_guard__DomainParallelotope_cuh

#include "Kernel/Kernel.cuh"

namespace rho {

class DomainParallelotope: public DomainSole {
public:
	using ContainFlag = size_t;

	struct RayCastTemp {
		Num t[2];
		ContainFlag contain_flag[2];
	};

	struct RayCastDataCore_: public RayCastDataCore {
		ContainFlag contain_flag;
	};

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda DomainParallelotope(Space* ref);

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
	mutable cntr::Vector<Matrix> tod_matrix_;

	RHO__cuda bool RayCast_(const Ray& ray, RayCastTemp& rct) const;
};

}

#endif