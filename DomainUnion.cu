#include"define.cuh"
#include"DomainUnion.cuh"

#define RHO__throw__local(description) \
	RHO__throw(DomainUnion, __func__, description);

namespace rho {

cntr::Vector<Domain*>&
DomainUnion::domain() { return this->domain_; }

const cntr::Vector<Domain*>&
DomainUnion::domain()const { return this->domain_; }

#////////////////////////////////////////////////

DomainUnion* DomainUnion::add_domain(Domain* domain) {
	RHO__debug_if(std::find(
		this->domain_.begin(),
		this->domain_.end(),
		domain) != this->domain_.end()) {

		RHO__throw__local("");
	}

	this->domain_.Push(domain);
	return this;
}

DomainUnion* DomainUnion::sub_domain(Domain* domain) {
	auto iter = std::find(
		this->domain_.begin(),
		this->domain_.end(),
		domain);

	if (iter != this->domain_.end())
		this->domain_.Erase(iter);

	return this;
}

#////////////////////////////////////////////////

DomainUnion::DomainUnion(const cntr::Vector<Domain*>& domain) :
	DomainComplex(domain[0]->root()), domain_(domain) {}

DomainUnion::DomainUnion(std::initializer_list<Domain*> domain) :
	DomainComplex((*domain.begin())->root()),
	domain_(domain.begin(), domain.end()) {}

#////////////////////////////////////////////////

void DomainUnion::Refresh()const {
	auto iter(this->domain_.begin());

	for (auto end(this->domain_.end()); iter != end; ++iter)
		(*iter)->Refresh();
}

bool DomainUnion::ReadyForRendering()const {
	auto iter(this->domain_.begin());

	for (auto end(this->domain_.end()); iter != end; ++iter)
		if (!(*iter)->ReadyForRendering()) { return false; }

	return true;
}

bool DomainUnion::Contain(const Vector& root_point)const {
	auto iter(this->domain_.begin());

	for (auto end(this->domain_.end()); iter != end; ++iter)
		if ((*iter)->Contain(root_point)) { return true; }

	return false;
}

#////////////////////////////////////////////////

RayCastData DomainUnion::RayCast(const Ray& ray)const {
	RayCastData r;
	RayCastData temp;

	auto iter(this->domain_.begin());

	for (auto end(this->domain_.end()); iter != end; ++iter) {
		temp = (*iter)->RayCast(ray);
		if (temp < r) { r = Move(temp); }
	}

	return r;
}

cntr::Vector<RayCastData> DomainUnion::
RayCastFull(const Ray& ray)const {
	/*cntr::Vector<RayCastData> r;
	cntr::Vector<RayCastData> rcdv;

	auto domain_i(this->domain_.begin());

	for (auto domain_end(this->domain_.end());
		 domain_i != domain_end; ++domain_i) {

		rcdv = (*domain_i)->RayCastFull(ray);

		auto rcdv_i(rcdv.begin());

		for (auto rcdv_end(rcdv.end()); rcdv_i != rcdv_end; ++rcdv_i) {
			auto domain_j(this->domain_.begin());

			for (; domain_j != domain_i; ++domain_j)
				if ((*domain_j)->FullContain((*rcdv_i)->root_point)) {
					rcdv_i = nullptr;
					goto A;
				}

			for (++domain_j; domain_j != domain_end; ++domain_j)
				if ((*domain_j)->FullContain((*rcdv_i)->root_point)) {
					rcdv_i = nullptr;
					goto A;
				}

			r.Push(Move(*rcdv_i));
			A:;
		}
	}

	return r;*/
}

cntr::Vector<RayCastData*>
RayCastData__(
	cntr::Vector<RayCastData>& dst,
	cntr::Vector<RayCastData>& a,
	cntr::Vector<RayCastData>& b) {

	if (a.empty()) { return; }
	if (b.empty()) {
		dst = Move(a);
		return;
	}

	size_t i(0);
	size_t j(0);

	bool last_a_to(a[a.size() - 1]->type.to());
	bool last_b_to(b[b.size() - 1]->type.to());

	for (;;) {
		if (a[i] < b[j]) {
			if (!b[j]->type.fr())
				dst.Push(Move(a[i]));
			++i;
		} else if (b[j] < a[i]) {
			if (!a[i]->type.fr())
				dst.Push(Move(b[j]));
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
				for (; j != b.size(); ++j)
					dst.Push(Move(b[j]));
			}

			return;
		}

		if (j == b.size()) {
			if (!last_b_to) {
				for (; i != a.size(); ++i)
					dst.Push(Move(a[j]));
			}

			return;
		}
	}
}

DomainUnion::RayCastTemp*
DomainUnion::RayCast_(const Ray& ray)const {
	auto rct(New<RayCastTemp>(0, this->domain_.size()));

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