#ifndef RHO__define_guard__Kernel__Ray_cuh
#define RHO__define_guard__Kernel__Ray_cuh

#include "init.cuh"

namespace rho {

struct Ray {
	NumVector origin;
	NumVector direct;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda void point(Num* dst, Num t) const;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda void
	RayCastForRender(RayCastDataPair& dst,
					 const cntr::Vector<ComponentCollider*>& cmpt) const;

	RHO__cuda bool
	RayCastFull(RayCastDataVector& rcdv,
				const cntr::Vector<ComponentCollider*>& cmpt) const;
};

}

#endif