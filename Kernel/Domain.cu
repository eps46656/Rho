#include "define.cuh"
#include "Kernel.cuh"

namespace rho {

Manager* Domain::manager() const { return this->manager_; }
Space* Domain::root() const { return this->root_; }

dim_t Domain::dim_r() const { return this->root_->dim_r(); }

#///////////////////////////////////////////////////////////////////////////////

Domain::Domain(Space* root): manager_(root->manager()), root_(root) {
	RHO__debug_if(root->parent()) RHO__throw(Domain, __func__, "root error");
}

Domain::~Domain() {}

#///////////////////////////////////////////////////////////////////////////////

bool Domain::RayCastB(const Ray& ray) const {
	auto rcd(this->RayCast(ray));
	return rcd && rcd->t.lt<1>();
}

RayCastData Domain::RayCast(const Ray& ray) const {
	RayCastDataVector rcdv;
	this->RayCastFull(rcdv, ray);
	return rcdv.empty() ? RayCastData() : Move(rcdv[0]);
}

void Domain::RayCastForRender(RayCastDataPair& rcdp,
							  ComponentCollider* cmpt_collider,
							  const Ray& ray) const {
	RayCastDataVector rcdv;
	this->RayCastFull(rcdv, ray);

	if (rcdv.empty()) { return; }

	if (rcdv.size() == 1) {
		if (rcdv[0] < rcdp[0]) {
			rcdp[1] = Move(rcdp[0]);
			rcdp[0] = Move(rcdv[0]);

			rcdp[0]->cmpt_collider = cmpt_collider;
		} else if (rcdv[0] < rcdp[1]) {
			rcdp[1] = Move(rcdv[0]);

			rcdp[1]->cmpt_collider = cmpt_collider;
		}
	} else {
		if (rcdv[1] < rcdp[0]) {
			rcdp[0] = Move(rcdv[0]);
			rcdp[1] = Move(rcdv[1]);

			rcdp[0]->cmpt_collider = cmpt_collider;
			rcdp[1]->cmpt_collider = cmpt_collider;
		} else if (rcdv[0] < rcdp[0]) {
			rcdp[1] = Move(rcdp[0]);
			rcdp[0] = Move(rcdv[0]);

			rcdp[0]->cmpt_collider = cmpt_collider;
		} else if (rcdv[0] < rcdp[1]) {
			rcdp[1] = Move(rcdv[0]);

			rcdp[1]->cmpt_collider = cmpt_collider;
		}
	}
}

}