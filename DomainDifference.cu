#include "DomainDifference.cuh"
#include "define.cuh"

#define RHO__throw__local(desc) RHO__throw(DomainDefference, __func__, desc)

namespace rho {

const Space* DomainDifference::root() const {
	const Space* r(this->domain_a_ ? this->domain_a_->root() : nullptr);

	if (this->domain_a_) {}

	const Space* space[]{ this->domain_a_->root(), this->domain_b_->root() };
	return (space[0] == space[1]) ? space[0] : nullptr;
}

#///////////////////////////////////////////////////////////////////////////////

Domain* DomainDifference::domain_a() const { return this->domain_a_raw_; }
Domain* DomainDifference::domain_b() const { return this->domain_b_raw_; }

#///////////////////////////////////////////////////////////////////////////////

void DomainDifference::doamin_a(Domain* domain_a) {
	this->domain_a_raw_ = domain_a;
}
void DomainDifference::doamin_b(Domain* domain_b) {
	this->domain_b_raw_ = domain_b;
}

#///////////////////////////////////////////////////////////////////////////////

DomainDifference::DomainDifference(Domain* domain_a, Domain* domain_b):
	domain_a_raw_(domain_a), domain_b_raw_(domain_b) {}

#///////////////////////////////////////////////////////////////////////////////

const Domain* DomainDifference::Refresh() const {
	if (!this->domain_a_raw_ ||
		!(this->domain_a_ = this->domain_a_raw_->Refresh())) {
		return nullptr;
	}

	if (!this->domain_b_raw_ ||
		!(this->domain_b_ = this->domain_b_raw_->Refresh())) {
		return this->domain_a_;
	}

	return this;
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

bool DomainDifference::RayCast(RayCastData& dst, const Ray& ray) const {
	RayCastDataVector rcdv_b;
	size_t rcdv_b_size(this->domain_b_->RayCastFull(rcdv_b, ray));

	switch (rcdv_b_size) {
		case 0: return this->domain_a_->RayCast(dst, ray);
		case RHO__Domain__RayCastFull_in_phase: RayCastData();
	}

	bool rcdv_b_to(rcdv_b[rcdv_b_size - 1].phase.to());

	RayCastDataVector rcdv_a;
	size_t rcdv_a_size(this->domain_a_->RayCastFull(rcdv_a, ray));

	if (rcdv_a_size == 0) { return RayCastData(); }

	size_t i(0);
	size_t j(0);

	while (i != rcdv_a_size) {
		if (rcdv_a[i] < rcdv_b[j]) {
			if (!rcdv_b[j].phase.fr()) {
				dst = rcdv_a[i];
				return true;
			}

			++i;
		} else if (rcdv_b[j] < rcdv_a[i]) {
			if (rcdv_a[i].phase.fr()) {
				rcdv_b[j].phase.set(!rcdv_b[j].phase.fr(), true);
				dst = rcdv_b[j];
				return true;
			}

			++j;
		} else {
			bool fr(rcdv_a[i].phase.fr() && !rcdv_b[j].phase.fr());
			bool to(rcdv_a[i].phase.to() && !rcdv_b[j].phase.to());

			if (fr || to) {
				rcdv_a[i].phase.set(fr, to);
				dst = rcdv_a[i];
				return true;
			}

			++i;
			++j;
		}

		if (j == rcdv_b_size) {
			if (rcdv_b_to || i == rcdv_a_size) { return false; }
			dst = rcdv_a[i];
			return true;
		}
	}

	return false;
}

void DomainDifference::RayCastPair(RayCastDataPair& dst, const Ray& ray) const {
	RayCastDataVector rcdv_b;
	size_t rcdv_b_size(this->domain_b_->RayCastFull(rcdv_b, ray));

	switch (rcdv_b_size) {
		case 0: this->domain_a_->RayCastPair(dst, ray); return;
		case RHO__Domain__RayCastFull_in_phase: return;
	}

	bool rcdv_b_to(rcdv_b[rcdv_b_size - 1].phase.to());

	RayCastDataVector rcdv_a;
	size_t rcdv_a_size(this->domain_a_->RayCastFull(rcdv_a, ray));

	if (rcdv_a_size == 0) { return; }

	size_t i(0);
	size_t j(0);

	while (i != rcdv_a_size) {
		if (rcdv_a[i] < rcdv_b[j]) {
			if (dst[1] <= rcdv_a[i]) { return; }

			if (!rcdv_b[j].phase.fr()) {
				if (rcdv_a[i] < dst[0]) {
					dst[1] = dst[0];
					dst[0] = rcdv_a[i];
				} else {
					dst[1] = rcdv_a[i];
				}
			}

			++i;
		} else if (rcdv_b[j] < rcdv_a[i]) {
			if (dst[1] <= rcdv_b[j]) { return; }

			if (rcdv_a[i].phase.fr()) {
				rcdv_b[j].phase.set(!rcdv_b[j].phase.fr(), true);

				if (rcdv_b[j] < dst[0]) {
					dst[1] = dst[0];
					dst[0] = rcdv_b[j];
				} else {
					dst[1] = rcdv_b[j];
				}
			}

			++j;
		} else {
			if (dst[1] <= rcdv_a[i]) { return; }

			bool fr(rcdv_a[i].phase.fr() && !rcdv_b[j].phase.fr());
			bool to(rcdv_a[i].phase.to() && !rcdv_b[j].phase.to());

			if (fr || to) {
				rcdv_a[i].phase.set(fr, to);

				if (rcdv_a[i] < dst[0]) {
					dst[1] = dst[0];
					dst[0] = rcdv_a[i];
				} else {
					dst[1] = rcdv_a[i];
				}
			}

			++i;
			++j;
		}

		if (j == rcdv_b_size) {
			if (!rcdv_b_to) {
				for (; i != rcdv_a_size; ++i) {
					if (dst[1] <= rcdv_a[i]) { return; }

					if (dst[0] <= rcdv_a[i]) {
						dst[1] = rcdv_a[i];
						return;
					}

					dst[1] = dst[0];
					dst[0] = rcdv_a[i];
				}
			}

			return;
		}
	}
}

size_t DomainDifference::RayCastFull(RayCastData* dst, const Ray& ray) const {
	RayCastDataVector rcdv_b;
	size_t rcdv_b_size(this->domain_b_->RayCastFull(rcdv_b, ray));

	switch (rcdv_b_size) {
		case 0: return this->domain_a_->RayCastFull(dst, ray);
		case RHO__Domain__RayCastFull_in_phase: return 0;
	}

	bool rcdv_b_to(rcdv_b[rcdv_b_size - 1].phase.to());

	RayCastDataVector rcdv_a;
	uint rcdv_a_size(this->domain_a_->RayCastFull(rcdv_a, ray));

	if (rcdv_a_size == 0) { return 0; }

	uint i(0);
	uint j(0);
	uint size(0);

	while (i != rcdv_a_size) {
		if (rcdv_a[i] < rcdv_b[j]) {
			if (!rcdv_b[j].phase.fr()) {
				dst[size] = rcdv_a[i];

				if (++size == RHO__Domain__RayCastFull_max_rcd) {
					return RHO__Domain__RayCastFull_max_rcd;
				}
			}

			++i;
		} else if (rcdv_b[j] < rcdv_a[i]) {
			if (rcdv_a[i].phase.fr()) {
				rcdv_b[j].phase.set(!rcdv_b[j].phase.fr(),
									!rcdv_b[j].phase.to());
				dst[size] = rcdv_b[j];

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

			bool fr(rcdv_a[i].phase.fr() && !rcdv_b[j].phase.fr());
			bool to(rcdv_a[i].phase.to() && !rcdv_b[j].phase.to());

			if (fr || to) {
				rcdv_a[i].phase.set(fr, to);
				dst[size] = rcdv_a[i];

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
					dst[size] = rcdv_a[i];

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