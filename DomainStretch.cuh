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

	RHO__cuda Space* ref() const;
	RHO__cuda Domain* domain() const;

	RHO__cuda void ref(Space* ref);
	RHO__cuda void domain(Domain* domain);

	RHO__cuda Space* root() const override;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda DomainStretch(Space* ref, Domain* domain);

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda bool Refresh() const override;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda bool Contain(const Num* root_point) const override;

#///////////////////////////////////////////////////////////////////////////////

	//RHO__cuda bool RayCastB(const Ray& ray)const override;
	//RHO__cuda RayCastData RayCast(const Ray& ray)const override;
	/*RHO__cuda void RayCastForRender(
		RayCastDataPair& rcdp,
		ComponentCollider* cmpt_collider,
		const Ray& ray)const override;*/
	RHO__cuda bool RayCastFull(RayCastDataVector& dst,
							   const Ray& ray) const override;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda void GetTodTan(Num* dst, const RayCastData& rcd,
							 const Num* root_direct) const override;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda size_t Complexity() const override;

private:
	Space* ref_;
	Space* eff_;
	Domain* domain_;

	mutable Mat eff_todm_;
	mutable Mat ref_todm_;

	RHO__cuda int RayCast_(const Ray& ray, RayCastTemp& rct) const;
};

}

#endif