#include "DomainDifference.cuh"
#include "define.cuh"

#define RHO__throw__local(description)                                         \
	RHO__throw(DomainDefference, __func__, description);

namespace rho {

Domain* DomainDifference::domain_a() const { return this->domain_a_; }
Domain* DomainDifference::domain_b() const { return this->domain_b_; }

#///////////////////////////////////////////////////////////////////////////////

void DomainDifference::doamin_a(Domain* domain_a) {
	this->domain_a_ = domain_a;
}
void DomainDifference::doamin_b(Domain* domain_b) {
	this->domain_b_ = domain_b;
}

#///////////////////////////////////////////////////////////////////////////////

DomainDifference::DomainDifference(Domain* domain_a, Domain* domain_b):
	DomainComplex(domain_a->root()), domain_a_(domain_a), domain_b_(domain_b) {
	RHO__debug_if(domain_a->root() != domain_b->root())
		RHO__throw__local("root error");
}

#///////////////////////////////////////////////////////////////////////////////

bool DomainDifference::Refresh() const {
	return this->domain_a_->Refresh() && this->domain_b_->Refresh();
}

#///////////////////////////////////////////////////////////////////////////////

bool DomainDifference::Contain(const Num* root_point) const {
	return this->domain_a_->Contain(root_point) &&
		   !this->domain_b_->Contain(root_point);
}

#///////////////////////////////////////////////////////////////////////////////

RayCastData DomainDifference::RayCast(const Ray& ray) const {
	RayCastDataVector rcdv_b;
	bool phase_b(this->domain_b_->RayCastFull(rcdv_b, ray));

	if (rcdv_b.empty())
		return phase_b ? RayCastData() : this->domain_a_->RayCast(ray);

	RayCastDataVector rcdv_a;
	this->domain_a_->RayCastFull(rcdv_a, ray);

	if (rcdv_a.empty()) { return RayCastData(); }

	size_t i(0);
	size_t j(0);

	bool last_rcdv_b_to(rcdv_b.back()->type.to());

	while (i != rcdv_a.size()) {
		if (rcdv_a[i] < rcdv_b[j]) {
			if (!rcdv_b[j]->type.fr()) return Move(rcdv_a[i]);
			++i;
		} else if (rcdv_b[j] < rcdv_a[i]) {
			if (rcdv_a[i]->type.fr()) {
				rcdv_b[j]->type.set(!rcdv_b[j]->type.fr(), true);
				return Move(rcdv_b[j]);
			}

			++j;
		} else {
			bool fr(rcdv_a[i]->type.fr() && !rcdv_b[j]->type.fr());
			bool to(rcdv_a[i]->type.to() && rcdv_b[j]->type.to());

			if (fr || to) {
				rcdv_a[i]->type.set(fr, to);
				return Move(rcdv_a[i]);
			}

			++i;
			++j;
		}

		if (j == rcdv_b.size()) {
			if (!last_rcdv_b_to && i != rcdv_a.size()) return Move(rcdv_a[i]);

			break;
		}
	}

	return RayCastData();
}

void DomainDifference::RayCastForRender(RayCastDataPair& rcdp,
	ComponentCollider* cmpt_collider, const Ray& ray) const {
	RayCastDataVector rcdv_b;
	this->domain_b_->RayCastFull(rcdv_b, ray);

	if (rcdv_b.empty()) {
		this->domain_a_->RayCastForRender(rcdp, cmpt_collider, ray);
		return;
	}

	RayCastDataVector rcdv_a;
	this->domain_a_->RayCastFull(rcdv_a, ray);

	if (rcdv_a.empty()) { return; }

	size_t i(0);
	size_t j(0);

	bool last_rcdv_b_to(rcdv_b.back()->type.to());

	while (i != rcdv_a.size()) {
		if (rcdv_a[i] < rcdv_b[j]) {
			if (rcdp[1] <= rcdv_a[i]) { return; }

			if (!rcdv_b[j]->type.fr()) {
				if (rcdv_a[i] < rcdp[0]) {
					rcdp[1] = Move(rcdp[0]);
					rcdp[0] = Move(rcdv_a[i]);
				} else {
					rcdp[1] = Move(rcdv_a[i]);
				}
			}

			++i;
		} else if (rcdv_b[j] < rcdv_a[i]) {
			if (rcdp[1] <= rcdv_b[j]) { return; }

			if (rcdv_a[i]->type.fr()) {
				rcdv_b[j]->type.set(!rcdv_b[j]->type.fr(), true);

				if (rcdv_b[j] < rcdp[0]) {
					rcdp[1] = Move(rcdp[0]);
					rcdp[0] = Move(rcdv_b[j]);
				} else {
					rcdp[1] = Move(rcdv_b[j]);
				}
			}

			++j;
		} else {
			if (rcdp[1] <= rcdv_a[i]) { return; }

			bool fr(rcdv_a[i]->type.fr() && !rcdv_b[j]->type.fr());
			bool to(rcdv_a[i]->type.to() && rcdv_b[j]->type.to());

			if (fr || to) {
				rcdv_a[i]->type.set(fr, to);

				if (rcdv_a[i] < rcdp[0]) {
					rcdp[1] = Move(rcdp[0]);
					rcdp[0] = Move(rcdv_a[i]);
				} else {
					rcdp[1] = Move(rcdv_a[i]);
				}
			}

			++i;
			++j;
		}

		if (j == rcdv_b.size()) {
			if (!last_rcdv_b_to) {
				for (; i != rcdv_a.size(); ++i) {
					if (rcdp[1] <= rcdv_a[i]) { return; }

					if (rcdp[0] <= rcdv_a[i]) {
						rcdp[1] = Move(rcdv_a[i]);
						return;
					}

					rcdp[1] = Move(rcdp[0]);
					rcdp[0] = Move(rcdv_a[i]);
				}
			}

			return;
		}
	}

	return;
}

bool DomainDifference::RayCastFull(
	RayCastDataVector& dst, const Ray& ray) const {
	RayCastDataVector rcdv_a;
	bool phase_a(this->domain_a_->RayCastFull(rcdv_a, ray));

	if (rcdv_a.empty()) { return phase_a; }

	RayCastDataVector rcdv_b;
	this->domain_b_->RayCastFull(rcdv_b, ray);

	if (rcdv_b.empty()) {
		dst.Reserve(dst.size() + rcdv_a.size());

		for (size_t i(0); i != rcdv_a.size(); ++i) dst.Push(Move(rcdv_a[i]));

		return phase_a;
	}

	dst.MoreReserve(rcdv_a.size() + rcdv_b.size());

	size_t i(0);
	size_t j(0);

	bool rcdv_b_to(rcdv_b.back()->type.to());

	while (i != rcdv_a.size()) {
		if (rcdv_a[i] < rcdv_b[j]) {
			if (!rcdv_b[j]->type.fr()) dst.Push(Move(rcdv_a[i]));
			++i;
		} else if (rcdv_b[j] < rcdv_a[i]) {
			if (rcdv_a[i]->type.fr()) {
				rcdv_b[j]->type.set(
					!rcdv_b[j]->type.fr(), !rcdv_b[j]->type.to());
				dst.Push(Move(rcdv_b[j]));
			}

			++j;
		} else {
			/*
			+------+------+-------+--------+
			| a_fr | b_fr | !b_fr | result |
			+------+------+-------+--------+
			| 0    | 0    | 1     | 0      |
			| 0    | 1    | 0     | 0      |
			| 1    | 0    | 1     | 1      |
			| 1    | 1    | 0     | 0      |
			+------+------+-------+--------+
			*/

			bool fr(rcdv_a[i]->type.fr() && !rcdv_b[j]->type.fr());
			bool to(rcdv_a[i]->type.to() && !rcdv_b[j]->type.to());

			if (fr || to) {
				rcdv_a[i]->type.set(fr, to);
				dst.Push(Move(rcdv_a[i]));
			}

			++i;
			++j;
		}

		if (j == rcdv_b.size()) {
			if (!rcdv_b_to) {
				for (; i != rcdv_a.size(); ++i) dst.Push(Move(rcdv_a[i]));
			}

			break;
		}
	}

	return phase_a;
}

#///////////////////////////////////////////////////////////////////////////////

void DomainDifference::GetTodTan(
	Num* dst, const RayCastData& rcd, const Num* root_direct) const {
	::printf("error\n");
	assert(false);
}

#///////////////////////////////////////////////////////////////////////////////

size_t DomainDifference::Complexity() const {
	return this->domain_a_->Complexity() + this->domain_b_->Complexity();
}

}