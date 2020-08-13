#ifndef RHO__define_guard__DomainIntersection_cuh
#define RHO__define_guard__DomainIntersection_cuh

#include "Kernel/Kernel.cuh"

namespace rho {

class DomainIntersection: public DomainComplex {
public:
	RHO__cuda cntr::RBT<Domain*>& domain();
	RHO__cuda const cntr::RBT<Domain*>& domain() const;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda DomainIntersection(Space* root);

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda bool Refresh() const override;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda bool Contain(const Num* root_point) const override;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda RayCastData RayCast(const Ray& ray) const override;
	RHO__cuda RayCastDataVector RayCastFull(const Ray& ray) const override;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda void GetTodTan(Num* dst, const RayCastData& rcd,
							 const Num* root_direct) const;

private:
	cntr::RBT<Domain*> domain_;
};

}

#endif