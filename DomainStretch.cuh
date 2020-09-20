#ifndef RHO__define_guard__DomainStrech_cuh
#define RHO__define_guard__DomainStrech_cuh

#include "Kernel/Kernel.cuh"

namespace rho {

class DomainStretch: public DomainComplex {
public:
	struct RayCastTemp {
		Num t[2];
		Vec ref_origin;
		Vec ref_direct;
		Ray proj_eff_ray;
	};

	struct RayCastDataCore_: public RayCastDataCore {
		RayCastData rcd;
	};

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Space* ref();
	RHO__cuda const Space* ref() const;

	RHO__cuda Domain* domain();
	RHO__cuda const Domain* domain() const;

	RHO__cuda const Space* root() const override;

	RHO__cuda void set_ref(Space* ref);
	RHO__cuda void set_domain(Domain* domain);

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda DomainStretch(Space* ref = nullptr, Domain* domain = nullptr);

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda const Domain* Refresh() const override;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda bool Contain(const Num* root_point) const override;

#///////////////////////////////////////////////////////////////////////////////

	//RHO__cuda bool RayCastB(const Ray& ray)const override;
	//RHO__cuda RayCastData RayCast(const Ray& ray)const override;
	/*RHO__cuda void RayCastForRender(
		RayCastDataPair& rcdp,
		ComponentCollider* cmpt_collider,
		const Ray& ray)const override;*/

	RHO__cuda size_t RayCastComplexity() const override;
	RHO__cuda size_t RayCastFull(RayCastData* dst,
								 const Ray& ray) const override;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda void GetTodTan(Num* dst, const RayCastData& rcd,
							 const Num* root_direct) const override;

private:
	Space* ref_;

	Domain* domain_raw_;
	mutable const Domain* domain_;

	mutable Space* eff_;
	mutable const Space* root_;

	mutable Mat eff_todm_;
	mutable Mat ref_todm_;

	RHO__cuda int RayCast_(const Ray& ray, RayCastTemp& rct) const;
};

}

#endif