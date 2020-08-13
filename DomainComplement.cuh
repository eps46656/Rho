#ifndef RHO__define_guard__DomainComplement_cuh
#define RHO__define_guard__DomainComplement_cuh

#include "Kernel/Kernel.cuh"

namespace rho {

class DomainComplement: public DomainComplex {
public:
	RHO__cuda Domain* domain() const;
	RHO__cuda void domain(Domain* domain);

#////////////////////////////////////////////////

	RHO__cuda DomainComplement(Domain* domain = nullptr);

#////////////////////////////////////////////////

	RHO__cuda void Refresh() const override;
	RHO__cuda bool ReadyForRendering() const override;

#////////////////////////////////////////////////

	RHO__cuda bool Contain(const Vector& root_point) const override;

#////////////////////////////////////////////////

	RHO__cuda RayCastData RayCast(const Ray& ray) const override;
	RHO__cuda RayCastDataVector RayCastFull(const Ray& ray) const override;
	RHO__cuda void RayCastForRender(pair<RayCastData>& rcdp,
									ComponentCollider* cmpt_collider,
									const Ray& ray) const override;

private:
	Domain* domain_;
};

}

#endif
