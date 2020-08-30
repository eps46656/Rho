#ifndef RHO__define_guard__DomainUnion_cuh
#define RHO__define_guard__DomainUnion_cuh

#include "Kernel/Kernel.cuh"

namespace rho {

class DomainUnion: public DomainComplex {
public:
	struct RayCastTemp {
		cntr::Vector<cntr::Vector<RayCastData>> rcdvv;
		cntr::Vector<RayCastData*> rcdv_a;
		cntr::Vector<RayCastData*> rcdv_b;
	};

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Space* root() const;

	RHO__cuda RBT<Domain*>& domain();
	RHO__cuda const RBT<Domain*>& domain() const;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda DomainUnion();

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda bool Refresh() const override;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda bool Contain(const Num* root_point) const override;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda RayCastData RayCast(const Ray& ray) const override;
	RHO__cuda bool RayCastFull(RayCastDataVector& rcdv,
							   const Ray& ray) const override;

private:
	RBT<Domain*> domain_;

	RHO__cuda static void RayCast_(RayCastDataVector& dst, RayCastDataVector& a,
								   RayCastDataVector& b);
};

}

#endif