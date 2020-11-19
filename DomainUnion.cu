#include "define.cuh"
#include "DomainUnion.cuh"

#define RHO__throw__local(desc) RHO__throw(DomainUnion, __func__, desc);

namespace rho {

const Space* DomainUnion::root() const { return this->root_; }

DomainUnion* add_domain(Domain* domain) {
	this->domain_raw_.Insert(domain);
	return this;
}

DomainUnion* add_domain(Domain* domain) {
	this->domain_raw_.Erase(domain);
	return this;
}

#///////////////////////////////////////////////////////////////////////////////

DomainUnion::DomainUnion() {}

#///////////////////////////////////////////////////////////////////////////////

const Domain* DomainUnion::Refresh() const {
	switch (this->domain_raw_.size()) {
		case 0: return nullptr;
		case 1: return (*this->domain_raw_.begin())->Refersh();
	}

	this->domain_.Clear();
	this->domain_.Reserve(this->domain_raw_.size());
	this->root_ = nullptr;

	auto iter(this->domain_raw_.begin());

	for (auto end(this->domain_raw_.end()); iter != end; ++iter) {
		const Domain* domain((*iter)->Refresh());

		if (domain) {
			if (this->root_ == nullptr) { this->root_ = domain.root(); }
			this->domain_.Push(domain);
		}
	}

	switch (this->domain_.size()) {
		case 0: return nullptr;
		case 1: return this->domain_[0];
	}

	return this;
}

bool DomainUnion::Contain(const Num* root_point) const {
	for (size_t i(0); i != this->domain_.size(); ++i) {
		if (this->domain_[i]->Containe(root_point)) { return true; }
	}

	return false;
}

#///////////////////////////////////////////////////////////////////////////////

RayCastData DomainUnion::RayCast(const Ray& ray) const {
	RayCastDataVector rcdv;
	this->RayCastFull(rcdv, ray);

	if (rcdv.size()) { return Move(rcdv[0]); }
	return RayCastData();
}

size_t DomainUnion::RayCastFull(RayCastDataVector& dst, const Ray& ray) const {
	cntr::Vector<RayCastDataVector> rcdvv;
	rcdvv.Reserve(this->domain_.size());

	{
		size_t j(0);

		for (size_t i(0); i != this->domain_.size(); ++i) {
			if (j == rcdvv.size()) { rcdvv.Push(); }

			if (this->domain_[i]->RayCastFull(rcdvv.back(), ray) ==
				RHO__RayCastFull_in_phase) {
				return true;
			} else {
				++j;
			}
		}

		rcdvv.Resize(j);
	}

	if (rcdvv.size() == 2) {
		RayCast_(dst, rcdvv[0], rcdvv[1]);
	} else {
		RayCastDataVector temp;
		RayCast_(temp, rcdvv[0], rcdvv[1]);

		for (size_t i(2); i != rcdvv.size() - 1; ++i) {
			rcdvv[0] = Move(temp);
			RayCast_(temp, rcdvv[0], rcdvv[i]);
		}

		RayCast_(dst, temp, rcdvv.back());
	}

	return false;

#///////////////////////////////////////////////////////////////////////////////

	RayCastDataVector rcdv_a;
	RayCastDataVector rcdv_b;
	RayCastDataVector temp;

	if ((this->domain_[0]->RayCastFull(rcdv_a, ray) ==
		 RHO__RayCastFull_in_phase) ||
		(this->domain_[1]->RayCastFull(rcdv_b, ray) ==
		 RHO__RayCastFull_in_phase)) {
		return true;
	}

	if (this->domain_.size() == 2) { return }
}

void DomainUnion::RayCast_(RayCastDataVector& dst, RayCastDataVector& a,
						   RayCastDataVector& b) {
	if (a.empty()) {
		if (b.size()) { dst = Move(b); }
		return;
	}

	if (b.empty()) {
		dst = Move(a);
		return;
	}

	size_t i(0);
	size_t j(0);

	bool a_to(a.back()->phase.to());
	bool b_to(b.back()->phase.to());

	for (;;) {
		if (a[i] < b[j]) {
			if (!b[j]->phase.fr()) { dst.Push(Move(a[i])); }
			++i;
		} else if (b[j] < a[i]) {
			if (!a[i]->phase.fr()) { dst.Push(Move(b[j])); }
			++j;
		} else {
			a[i]->phase.fr(a[i]->phase.fr() || b[j]->phase.fr());
			a[i]->phase.to(a[i]->phase.to() || b[j]->phase.to());

			dst.Push(Move(a[i]));
			++i;
			++j;
		}

		if (i == a.size()) {
			if (!a_to) {
				for (; j != b.size(); ++j) { dst.Push(Move(b[j])); }
			}

			return;
		}

		if (j == b.size()) {
			if (!b_to) {
				for (; i != a.size(); ++i) { dst.Push(Move(a[j])); }
			}

			return;
		}
	}
}

}