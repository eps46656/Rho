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

	RHO__cuda const Space* root() const;

	RHO__cuda DomainUnion& add_domain();
	RHO__cuda DomainUnion& sub_domain() const;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda DomainUnion();

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda const Domain* Refresh() const override;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda bool Contain(const Num* root_point) const override;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda RayCastData RayCast(const Ray& ray) const override;
	RHO__cuda bool RayCastFull(RayCastDataVector& rcdv,
							   const Ray& ray) const override;

private:
	RBT<Domain*> domain_raw_;
	mutable cntr::Vector<Domain*> domain_;

	mutable const Space* root_;

	RHO__cuda static void RayCast_(RayCastDataVector& dst, RayCastDataVector& a,
								   RayCastDataVector& b);
};

}

#endif