#include "define.cuh"
#include "DomainUnion.cuh"

#define RHO__throw__local(description)                                         \
	RHO__throw(DomainUnion, __func__, description);

namespace rho {

cntr::RBT<Domain*>& DomainUnion::domain() { return this->domain_; }
const cntr::RBT<Domain*>& DomainUnion::domain() const { return this->domain_; }

#///////////////////////////////////////////////////////////////////////////////

DomainUnion::DomainUnion(Space* root): DomainComplex(domain[0]->root()) {
	RHO__debug_if(!root->is_root()) RHO__throw_local("root error");
}

#///////////////////////////////////////////////////////////////////////////////

bool DomainUnion::Refresh() const {
	auto iter(this->domain_.begin());

	for (auto end(this->domain_.end()); iter != end; ++i) {
		if (this->root() != (*iter)->root() || !(*iter)->Refresh())
			return false;
	}

	return true;
}

bool DomainUnion::Contain(const Num* root_point) const {
	auto iter(this->domain_.begin());

	for (auto end(this->domain_.end()); iter != end; ++iter) {
		if ((*iter)->Contain(root_point)) { return true; }
	}

	return false;
}

#///////////////////////////////////////////////////////////////////////////////

RayCastData DomainUnion::RayCast(const Ray& ray) const {
	RayCastDataVector rcdv;
	this->RayCastDataFull(rcdv);

	if (rcdv.size()) { return rcdv[0]; }
	return RayCastData();
}

bool DomainUnion::RayCastFull(RayCastDataVector& dst, const Ray& ray) const {
	if (this->domain_.empty()) { return false; }

	if (this->domain_.size() == 1)
		return this->domain_[0].RayCastFull(dst, ray);

	cntr::Vector<RayCastDataVector> rcdvv(this->domain_.size());

	{
		auto iter(this->domain_.begin());
		size_t i(0);

		for (auto end(this->domain_.end()); iter != end; ++i) {
			bool phase((*iter)->RayCastFull(rcdvv[i]));
			if (phase && rcdvv[i].empty()) { return true; }
		}
	}

	if (this->domain_.size() == 2) {
		RayCastData__(dst, rcdvv[0], rcdvv[1]);
	} else {
		RayCastDataVector temp;
		RayCastData__(temp, rcdvv[0], rcdvv[1]);

		for (size_t i(2); i != this->domain_.size() - 1; ++i) {
			rcdvv[0] = Move(temp);
			RayCastData__(temp, rcdvv[0], rcdvv[i]);
		}

		RayCastData__(dst, temp, rcdvv.back());
	}

	return false;
}

void RayCastData__(RayCastDataVector& dst, RayCastDataVector& a,
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

	bool last_a_to(a.back()->type.to());
	bool last_b_to(b.back()->type.to());

	for (;;) {
		if (a[i] < b[j]) {
			if (!b[j]->type.fr()) { dst.Push(Move(a[i])); }
			++i;
		} else if (b[j] < a[i]) {
			if (!a[i]->type.fr()) { dst.Push(Move(b[j])); }
			++j;
		} else {
			a[i]->type.fr(a[i]->type.fr() || b[j]->type.fr());
			a[i]->type.to(a[i]->type.to() || b[j]->type.to());

			dst.Push(Move(a[i]));
			++i;
			++j;
		}

		if (i == a.size()) {
			if (!last_a_to) {
				for (; j != b.size(); ++j) { dst.Push(Move(b[j])); }
			}

			return;
		}

		if (j == b.size()) {
			if (!last_b_to) {
				for (; i != a.size(); ++i) { dst.Push(Move(a[j])); }
			}

			return;
		}
	}
}

void DomainUnion::RayCast_(RayCastTemp& rct, const Ray& ray) const {
	for (size_t i(0); i != this->domain_.size(); ++i)
		rct->rcdvv.Push(this->domain_[i]->RayCastFull(ray));

	/*

	.a..
	++b.
	F

	*/
	/*
	for (size_t a(0); a != this->domain_.size(); ++a) {
		for (size_t b(0); b != this->domain_.size(); ++b) {
			if (a == b) { continue; }

			size_t i(0);
			size_t j(0);

			for (size_t)
		}
	}*/
}

}