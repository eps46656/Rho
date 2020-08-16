#ifndef RHO__define_guard__DomainBall_cuh
#define RHO__define_guard__DomainBall_cuh

#include "Kernel/Kernel.cuh"

namespace rho {

class DomainBall: public DomainSole {
public:
	struct RayCastTemp {
		Num t[2];
		Vec origin;
		Vec direct;
	};

	struct RayCastDataCore_: public RayCastDataCore {
		Vec point;
	};

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda DomainBall(Space* parent);

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

	RHO__cuda Matrix GetParallelVector_s(const Vector& point) const;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda void GetTodTan(Num* dst, const RayCastData& rcd,
							 const Num* root_direct) const override;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda size_t Complexity() const;

private:
	RHO__cuda bool RayCast_(const Ray& ray, RayCastTemp& rct) const;
};

}

#endif
