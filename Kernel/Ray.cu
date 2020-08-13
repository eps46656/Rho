#include "define.cuh"
#include "Kernel.cuh"

namespace rho {

void Ray::point(Num* dst, Num t) const {
	line<RHO__max_dim>(dst, t, this->direct, this->origin);
}

bool Ray::RayCastFull(RayCastDataVector& rcdv,
					  const cntr::Vector<ComponentCollider*>& cmpt) const {
	for (size_t i(0); i != cmpt.size(); ++i) cmpt[i]->RayCastFull(rcdv, *this);

	return false;
}

void Ray::RayCastForRender(RayCastDataPair& dst,
						   const cntr::Vector<ComponentCollider*>& cmpt) const {
	dst[0] = nullptr;
	dst[1] = nullptr;

	for (size_t i(0); i != cmpt.size(); ++i)
		cmpt[i]->RayCastForRender(dst, *this);
}

}