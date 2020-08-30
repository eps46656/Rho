#include "define.cuh"
#include "Kernel.cuh"

namespace rho {

void Ray::point(Num* dst, Num t) const {
	line<RHO__max_dim>(dst, t, this->direct, this->origin);
}

}