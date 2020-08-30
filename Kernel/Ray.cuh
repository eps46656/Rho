#ifndef RHO__define_guard__Kernel__Ray_cuh
#define RHO__define_guard__Kernel__Ray_cuh

#include "init.cuh"

namespace rho {

struct Ray {
	Vec origin;
	Vec direct;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda void point(Num* dst, Num t) const;
};

}

#endif