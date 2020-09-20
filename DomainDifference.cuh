#ifndef RHO__define_guard__DomainDifference_cuh
#define RHO__define_guard__DomainDifference_cuh

#include "Kernel/Kernel.cuh"

namespace rho {

class DomainDifference: public DomainComplex {
public:
	struct RayCastTemp {
		RayCastDataVector rcdv_a;
		RayCastDataVector rcdv_b;
	};

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda const Space* root() const override;

	RHO__cuda Domain* domain_a() const;
	RHO__cuda Domain* domain_b() const;

	RHO__cuda void doamin_a(Domain* domain_a);
	RHO__cuda void doamin_b(Domain* domain_b);

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda DomainDifference(Domain* domain_a = nullptr,
							   Domain* domain_b = nullptr);

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda const Domain* Refresh() const override;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda bool Contain(const Num* root_point) const override;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda size_t RayCastComplexity() const override;
	RHO__cuda RayCastData RayCast(const Ray& ray) const override;
	RHO__cuda void RayCastPair(RayCastDataPair& rcdp,
							   const Ray& ray) const override;
	RHO__cuda size_t RayCastFull(RayCastData* dst,
								 const Ray& ray) const override;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda void GetTodTan(Num* dst, const RayCastData& rcd,
							 const Num* root_direct) const override;

private:
	Domain* domain_a_raw_;
	Domain* domain_b_raw_;

	mutable const Domain* domain_a_;
	mutable const Domain* domain_b_;
};

}

#endif
