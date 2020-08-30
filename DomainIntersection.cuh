#ifndef RHO__define_guard__DomainIntersection_cuh
#define RHO__define_guard__DomainIntersection_cuh

#include "Kernel/Kernel.cuh"

namespace rho {

class DomainIntersection: public DomainComplex {
public:
	RHO__cuda Space* root() const override;

	RHO__cuda RBT<Domain*>& domain();
	RHO__cuda const RBT<Domain*>& domain() const;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda DomainIntersection();

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda bool Refresh() const override;

	RHO__cuda bool Contain(const Num* root_point) const override;

	RHO__cuda bool RayCastFull(RayCastDataVector& rcdv,
							   const Ray& ray) const override;

	RHO__cuda void GetTodTan(Num* dst, const RayCastData& rcd,
							 const Num* root_direct) const;

private:
	RBT<Domain*> domain_;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda static void RayCast_(RayCastDataVector& dst, RayCastDataVector& a,
								   RayCastDataVector& b);
};

}

#endif