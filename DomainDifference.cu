#include "DomainDifference.cuh"
#include "define.cuh"

#define RHO__throw__local(desc) RHO__throw(DomainDefference, __func__, desc)

namespace rho {

Space* DomainDifference::root() const {
	Space* space[]{ this->domain_a_->root(), this->domain_b_->root() };
	return (space[0] == space[1]) ? space[0] : nullptr;
}

#///////////////////////////////////////////////////////////////////////////////

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
	domain_a_(domain_a), domain_b_(domain_b) {
	RHO__debug_if(domain_a->root() != domain_b->root()) {
		RHO__throw__local("root error");
	}
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

	if (rcdv_b.empty()) {
		return phase_b ? RayCastData() : this->domain_a_->RayCast(ray);
	}

	RayCastDataVector rcdv_a;
	this->domain_a_->RayCastFull(rcdv_a, ray);

	if (rcdv_a.empty()) { return RayCastData(); }

	size_t i(0);
	size_t j(0);

	bool rcdv_b_to(rcdv_b.back()->phase.to());

	while (i != rcdv_a.size()) {
		if (rcdv_a[i] < rcdv_b[j]) {
			if (!rcdv_b[j]->phase.fr()) { return Move(rcdv_a[i]); }
			++i;
		} else if (rcdv_b[j] < rcdv_a[i]) {
			if (rcdv_a[i]->phase.fr()) {
				rcdv_b[j]->phase.set(!rcdv_b[j]->phase.fr(), true);
				return Move(rcdv_b[j]);
			}

			++j;
		} else {
			bool fr(rcdv_a[i]->phase.fr() && !rcdv_b[j]->phase.fr());
			bool to(rcdv_a[i]->phase.to() && rcdv_b[j]->phase.to());

			if (fr || to) {
				rcdv_a[i]->phase.set(fr, to);
				return Move(rcdv_a[i]);
			}

			++i;
			++j;
		}

		if (j == rcdv_b.size()) {
			if (!rcdv_b_to && i != rcdv_a.size()) { return Move(rcdv_a[i]); }
			break;
		}
	}

	return RayCastData();
}

void DomainDifference::RayCastPair(RayCastDataPair& rcdp,
								   const Ray& ray) const {
	RayCastDataVector rcdv_b;
	bool phase_b(this->domain_b_->RayCastFull(rcdv_b, ray));

	if (rcdv_b.empty()) {
		if (!phase_b) { this->domain_a_->RayCastPair(rcdp, ray); }
		return;
	}

	RayCastDataVector rcdv_a;
	this->domain_a_->RayCastFull(rcdv_a, ray);

	if (rcdv_a.empty()) { return; }

	size_t i(0);
	size_t j(0);

	bool rcdv_b_to(rcdv_b.back()->phase.to());

	while (i != rcdv_a.size()) {
		if (rcdv_a[i] < rcdv_b[j]) {
			if (rcdp[1] <= rcdv_a[i]) { return; }

			if (!rcdv_b[j]->phase.fr()) {
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

			if (rcdv_a[i]->phase.fr()) {
				rcdv_b[j]->phase.set(!rcdv_b[j]->phase.fr(), true);

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

			bool fr(rcdv_a[i]->phase.fr() && !rcdv_b[j]->phase.fr());
			bool to(rcdv_a[i]->phase.to() && rcdv_b[j]->phase.to());

			if (fr || to) {
				rcdv_a[i]->phase.set(fr, to);

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
			if (!rcdv_b_to) {
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

bool DomainDifference::RayCastFull(RayCastDataVector& dst,
								   const Ray& ray) const {
	RayCastDataVector rcdv_a;
	bool phase_a(this->domain_a_->RayCastFull(rcdv_a, ray));

	if (rcdv_a.empty()) { return phase_a; }

	RayCastDataVector rcdv_b;
	bool phase_b(this->domain_b_->RayCastFull(rcdv_b, ray));

	if (rcdv_b.empty()) {
		if (!phase_b) {
			dst.Reserve(dst.size() + rcdv_a.size());

			for (size_t i(0); i != rcdv_a.size(); ++i) {
				dst.Push(Move(rcdv_a[i]));
			}
		}

		return phase_a;
	}

	dst.MoreReserve(rcdv_a.size() + rcdv_b.size());

	size_t i(0);
	size_t j(0);

	bool rcdv_b_to(rcdv_b.back()->phase.to());

	while (i != rcdv_a.size()) {
		if (rcdv_a[i] < rcdv_b[j]) {
			if (!rcdv_b[j]->phase.fr()) { dst.Push(Move(rcdv_a[i])); }
			++i;
		} else if (rcdv_b[j] < rcdv_a[i]) {
			if (rcdv_a[i]->phase.fr()) {
				rcdv_b[j]->phase.set(!rcdv_b[j]->phase.fr(),
									 !rcdv_b[j]->phase.to());
				dst.Push(Move(rcdv_b[j]));
			}

			++j;
		} else {
			/*
			+----+------+------+-------+
			| fr | a_fr | b_fr | !b_fr |
			+----+------+------+-------+
			| 0  | 0    | 0    | 1     |
			| 0  | 0    | 1    | 0     |
			| 1  | 1    | 0    | 1     |
			| 0  | 1    | 1    | 0     |
			+----+------+------+-------+

			+----+------+------+-------+
			| to | a_to | b_to | !b_to |
			+----+------+------+-------+
			| 0  | 0    | 0    | 1     |
			| 0  | 0    | 1    | 0     |
			| 1  | 1    | 0    | 1     |
			| 0  | 1    | 1    | 0     |
			+----+------+------+-------+

			*/

			bool fr(rcdv_a[i]->phase.fr() && !rcdv_b[j]->phase.fr());
			bool to(rcdv_a[i]->phase.to() && !rcdv_b[j]->phase.to());

			if (fr || to) {
				rcdv_a[i]->phase.set(fr, to);
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

void DomainDifference::GetTodTan(Num* dst, const RayCastData& rcd,
								 const Num* root_direct) const {
	RHO__throw__local("call error");
}

#///////////////////////////////////////////////////////////////////////////////

size_t DomainDifference::Complexity() const {
	return this->domain_a_->Complexity() + this->domain_b_->Complexity();
}

}