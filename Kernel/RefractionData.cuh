#ifndef RHO__define_guard__Kernel__RefractionData_cuh
#define RHO__define_guard__Kernel__RefractionData_cuh

#include "init.cuh"
#include "ComponentCollider.cuh"

namespace rho {

struct RefractionData {
	Num transmittance;
	Num parallel_ratio;

#////////////////////////////////////////////////

	RHO__cuda RefractionData(const RayCastData& rcd, const Tod& tod,
							 const ComponentCollider::Material* x,
							 const ComponentCollider::Material* y);
};

}

#endif