#include "DomainDifference.cuh"
#include "define.cuh"

#define RHO__throw__local(desc) RHO__throw(DomainDefference, __func__, desc)

namespace rho {

Space* DomainDifference::root() const {
	Space* r(this->domain_a_ ? this->domain_a_->root() : nullptr);

	if (this->domain_a_) {}

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
	RHO__debug_if(domain_a && domain_b &&
				  (domain_a->root() != domain_b->root())) {
		RHO__throw__local("root error");
	}
}

#///////////////////////////////////////////////////////////////////////////////

bool DomainDifference::Refresh() const {
	return this->domain_a_ && this->domain_a_->Refresh() && this->domain_b_ &&
		   this->domain_b_->Refresh();
}

#///////////////////////////////////////////////////////////////////////////////

bool DomainDifference::Contain(const Num* root_point) const {
	return (this->domain_a_ && this->domain_a_->Contain(root_point)) &&
		   !(this->domain_b_ && this->domain_b_->Contain(root_point));
}

#///////////////////////////////////////////////////////////////////////////////

size_t DomainDifference::RayCastComplexity() const {
	if (!this->domain_a_ || this->domain_a_ == this->domain_b_) { return 0; }
	size_t a(this->domain_a_->RayCastComplexity());
	return this->domain_b_ ? a + this->domain_b_->RayCastComplexity() : a;
}

RayCastData DomainDifference::RayCast(const Ray& ray) const {
	if (!this->domain_a_) { return RayCastData(); }
	if (!this->domain_b_) { return this->domain_a_->RayCast(ray); }

	RayCastDataVector rcdv_b;
	size_t rcdv_b_size(this->domain_b_->RayCastFull(rcdv_b, ray));

	switch (rcdv_b_size) {
		case 0: return this->domain_a_->RayCast(ray);
		case RHO__Domain__RayCastFull_in_phase: RayCastData();
	}

	bool rcdv_b_to(rcdv_b[rcdv_b_size - 1]->phase.to());

	RayCastDataVector rcdv_a;
	size_t rcdv_a_size(this->domain_a_->RayCastFull(rcdv_a, ray));

	if (rcdv_a_size == 0) { return RayCastData(); }

	size_t i(0);
	size_t j(0);

	while (i != rcdv_a_size) {
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

		if (j == rcdv_b_size) {
			if (!rcdv_b_to && i != rcdv_a_size) { return Move(rcdv_a[i]); }
			break;
		}
	}

	return RayCastData();
}

void DomainDifference::RayCastPair(RayCastDataPair& rcdp,
								   const Ray& ray) const {
	if (!this->domain_a_) { return; }

	if (!this->domain_b_) {
		this->domain_a_->RayCastPair(rcdp, ray);
		return;
	}

	RayCastDataVector rcdv_b;
	size_t rcdv_b_size(this->domain_b_->RayCastFull(rcdv_b, ray));

	switch (rcdv_b_size) {
		case 0: this->domain_a_->RayCastPair(rcdp, ray); return;
		case RHO__Domain__RayCastFull_in_phase: return;
	}

	// Print() << rcdv_b_size << "\n";

	bool rcdv_b_to(rcdv_b[rcdv_b_size - 1]->phase.to());

	RayCastDataVector rcdv_a;
	size_t rcdv_a_size(this->domain_a_->RayCastFull(rcdv_a, ray));

	if (rcdv_a_size == 0) { return; }

	size_t i(0);
	size_t j(0);

	while (i != rcdv_a_size) {
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

		if (j == rcdv_b_size) {
			if (!rcdv_b_to) {
				for (; i != rcdv_a_size; ++i) {
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

size_t DomainDifference::RayCastFull(RayCastData* dst, const Ray& ray) const {
	if (!this->domain_a_) { return 0; }
	if (!this->domain_b_) { return this->domain_a_->RayCastFull(dst, ray); }

	RayCastDataVector rcdv_b;
	size_t rcdv_b_size(this->domain_b_->RayCastFull(rcdv_b, ray));

	switch (rcdv_b_size) {
		case 0: return this->domain_a_->RayCastFull(dst, ray);
		case RHO__Domain__RayCastFull_in_phase: return 0;
	}

	bool rcdv_b_to(rcdv_b[rcdv_b_size - 1]->phase.to());

	RayCastDataVector rcdv_a;
	size_t rcdv_a_size(this->domain_a_->RayCastFull(rcdv_a, ray));

	if (rcdv_a_size == 0) { return 0; }

	size_t i(0);
	size_t j(0);
	size_t size(0);

	while (i != rcdv_a_size) {
		if (rcdv_a[i] < rcdv_b[j]) {
			if (!rcdv_b[j]->phase.fr()) {
				dst[size] = Move(rcdv_a[i]);

				if (++size == RHO__Domain__RayCastFull_max_rcd) {
					return RHO__Domain__RayCastFull_max_rcd;
				}
			}

			++i;
		} else if (rcdv_b[j] < rcdv_a[i]) {
			if (rcdv_a[i]->phase.fr()) {
				rcdv_b[j]->phase.set(!rcdv_b[j]->phase.fr(),
									 !rcdv_b[j]->phase.to());
				dst[size] = Move(rcdv_b[j]);

				if (++size == RHO__Domain__RayCastFull_max_rcd) {
					return RHO__Domain__RayCastFull_max_rcd;
				}
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
				dst[size] = Move(rcdv_a[i]);

				if (++size == RHO__Domain__RayCastFull_max_rcd) {
					return RHO__Domain__RayCastFull_max_rcd;
				}
			}

			++i;
			++j;
		}

		if (j == rcdv_b_size) {
			if (!rcdv_b_to) {
				for (; i != rcdv_a_size; ++i) {
					dst[size] = Move(rcdv_a[i]);

					if (++size == RHO__Domain__RayCastFull_max_rcd) {
						return RHO__Domain__RayCastFull_max_rcd;
					}
				}
			}

			break;
		}
	}

	return size;
}

#///////////////////////////////////////////////////////////////////////////////

void DomainDifference::GetTodTan(Num* dst, const RayCastData& rcd,
								 const Num* root_direct) const {
	RHO__throw__local("call error");
}

}