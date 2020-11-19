#include "define.cuh"
#include "Kernel.cuh"

namespace rho {

dim_t Domain::root_dim() const { return this->root()->root_dim(); }

#///////////////////////////////////////////////////////////////////////////////

Domain::Domain(Type type_): type(type_) {}
Domain::~Domain() {}

#///////////////////////////////////////////////////////////////////////////////

bool Domain::RayCast(RayCastData& dst, const Ray& ray) const {
	RayCastDataVector rcdv;

	if (this->RayCastFull(rcdv, ray) == 0) { return false; }

	dst = rcdv[0];
	return true;
}

bool Domain::RayCastB(const Ray& ray) const {
	RayCastData rcd;
	return this->RayCast(rcd, ray) && rcd.t.lt<1>();
}

void Domain::RayCastPair(RayCastDataPair& dst, const Ray& ray) const {
	RayCastDataVector rcdv;

	switch (this->RayCastFull(rcdv, ray)) {
		case RHO__Domain__RayCastFull_in_phase: return;
		case 0: return;
		case 1: {
			if (rcdv[0] < dst[0]) {
				dst[1] = dst[0];
				dst[0] = rcdv[0];
			} else if (rcdv[0] < dst[1]) {
				dst[1] = rcdv[0];
			}

			return;
		}
	}

	if (rcdv[1] < dst[0]) {
		dst[0] = rcdv[0];
		dst[1] = rcdv[1];
	} else if (rcdv[0] < dst[0]) {
		dst[1] = dst[0];
		dst[0] = rcdv[0];
	} else if (rcdv[0] < dst[1]) {
		dst[1] = rcdv[0];
	}
}

void Domain::RayCastDataDeleter(RayCastData& rcd) const {}

}