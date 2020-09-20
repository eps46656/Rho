#include "define.cuh"
#include "Kernel.cuh"

namespace rho {

dim_t Domain::root_dim() const { return this->root()->root_dim(); }

#///////////////////////////////////////////////////////////////////////////////

Domain::Domain(Type type_): type(type_) {}
Domain::~Domain() {}

#///////////////////////////////////////////////////////////////////////////////

RayCastData Domain::RayCast(const Ray& ray) const {
	RayCastDataVector rcdv;
	return this->RayCastFull(rcdv, ray) == 0 ? RayCastData() : Move(rcdv[0]);
}

bool Domain::RayCastB(const Ray& ray) const {
	auto rcd(this->RayCast(ray));
	return rcd && rcd->t.lt<1>();
}

void Domain::RayCastPair(RayCastDataPair& rcdp, const Ray& ray) const {
	RayCastDataVector rcdv;

	switch (this->RayCastFull(rcdv, ray)) {
		case RHO__Domain__RayCastFull_in_phase: return;
		case 0: return;
		case 1:
			if (rcdv[0] < rcdp[0]) {
				rcdp[1] = Move(rcdp[0]);
				rcdp[0] = Move(rcdv[0]);
			} else if (rcdv[0] < rcdp[1]) {
				rcdp[1] = Move(rcdv[0]);
			}

			return;
	}

	if (rcdv[1] < rcdp[0]) {
		rcdp[0] = Move(rcdv[0]);
		rcdp[1] = Move(rcdv[1]);
	} else if (rcdv[0] < rcdp[0]) {
		rcdp[1] = Move(rcdp[0]);
		rcdp[0] = Move(rcdv[0]);
	} else if (rcdv[0] < rcdp[1]) {
		rcdp[1] = Move(rcdv[0]);
	}
}

}