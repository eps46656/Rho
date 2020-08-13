#ifndef RHO__define_guard__Kernel__Material_cuh
#define RHO__define_guard__Kernel__Material_cuh

#include"init.cuh"

namespace rho {

class Material {

public:
	Num refraction_index;
	Num3 transmittance;

	RHO__cuda bool Check()const;
};

}

#endif