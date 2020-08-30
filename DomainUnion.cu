#include "define.cuh"
#include "DomainUnion.cuh"

#define RHO__throw__local(desc) RHO__throw(DomainUnion, __func__, desc);

namespace rho {

Space* DomainUnion::root() const {
	if (this->domain_.empty()) { return nullptr; }

	auto iter(this->domain_.begin());

	Space* root((*iter)->root());
	++iter;

	for (auto end(this->domain_.end()); iter != end; ++iter) {
		if (root != (*iter)->root()) { return nullptr; }
	}

	return root;
}

RBT<Domain*>& DomainUnion::domain() { return this->domain_; }
const RBT<Domain*>& DomainUnion::domain() const { return this->domain_; }

#///////////////////////////////////////////////////////////////////////////////

DomainUnion::DomainUnion() {}

#///////////////////////////////////////////////////////////////////////////////

bool DomainUnion::Refresh() const {
	auto iter(this->domain_.begin());

	for (auto end(this->domain_.end()); iter != end; ++iter) {
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
	this->RayCastFull(rcdv, ray);

	if (rcdv.size()) { return Move(rcdv[0]); }
	return RayCastData();
}

bool DomainUnion::RayCastFull(RayCastDataVector& dst, const Ray& ray) const {
	if (this->domain_.empty()) { return false; }

	if (this->domain_.size() == 1)
		return (*this->domain_.begin())->RayCastFull(dst, ray);

	cntr::Vector<RayCastDataVector> rcdvv;
	rcdvv.Reserve(this->domain_.size());

	{
		auto iter(this->domain_.begin());
		size_t size(0);

		for (auto end(this->domain_.end()); iter != end; ++iter) {
			if (size == rcdvv.size()) { rcdvv.Push(); }

			bool phase((*iter)->RayCastFull(rcdvv.back(), ray));

			if (rcdvv.back().empty()) {
				if (phase) { return true; }
			} else {
				++size;
			}
		}

		rcdvv.Resize(size);
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