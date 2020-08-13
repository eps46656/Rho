#ifndef RHO__define_guard__Kernel__RefractionData_cuh
#define RHO__define_guard__Kernel__RefractionData_cuh

#include"init.cuh"

namespace rho {

struct RefractionData {
	Num transmittance;
	Num parallel_ratio;

#////////////////////////////////////////////////

	RHO__cuda RefractionData(
		const RayCastData& rcd,
		const Tod& tod,
		const Material* x,
		const Material* y);
};

}

#endif