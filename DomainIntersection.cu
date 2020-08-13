#include "define.cuh"
#include "DomainIntersection.h"

#define RHO__throw__local(description)                                         \
	RHO__throw(DomainIntersection, __func__, description);

namespace rho {

const cntr::Vector<Domain*>& DomainIntersection::domain() const {
	return this->domain_;
}

void DomainIntersection::add_domain(Domain* domain) {
	this->domain_.Push(domain);
}

#////////////////////////////////////////////////

DomainIntersection::DomainIntersection(const cntr::Vector<Domain*>& domain):
	DomainComplex(domain[0]->root()), domain_(domain) {}

DomainIntersection::DomainIntersection(std::initializer_list<Domain*> domain):
	DomainComplex((*domain.begin())->root()),
	domain_(domain.begin(), domain.end()) {}

#///////////////////////////////////////////////////////////////////////////////

void DomainIntersection::Refresh() const {
	auto iter(this->domain_.begin());
	auto end(this->domain_.end());

	Sort(iter, end);

	for (; iter != end; ++iter) {
		RHO__debug_if(std::count(iter + 1, end, *iter))
			RHO__throw__local("domain error");

		(*iter)->Refresh();
	}
}

bool DomainIntersection::ReadyForRendering() const {
	auto iter(this->domain_.begin());
	auto end(this->domain_.end());

	Sort(iter, end);

	for (; iter != end; ++iter) {
		RHO__debug_if(rho::Contain(iter + 1, end, *iter)) return false;

		if (!(*iter)->ReadyForRendering()) { return false; }
	}

	return true;
}

#///////////////////////////////////////////////////////////////////////////////

bool DomainIntersection::Contain(const Vector& root_point) const {
	if (this->domain_.empty()) { return false; }

	auto iter(this->domain_.begin());

	for (auto end(this->domain_.end()); iter != end; ++iter)
		if (!(*iter)->Contain(root_point)) { return false; }

	return true;
}

bool DomainIntersection::EdgeContain(const Vector& root_point) const {
	if (this->domain_.empty()) { return false; }

	auto iter(this->domain_.begin());
	auto end(this->domain_.end());

	for (; iter != end; ++iter) {
		ContainType contain_type = (*iter)->GetContainType(root_point);
		if (contain_type == ContainType::none) { return false; }
		if (contain_type == ContainType::edge) { break; }
	}

	for (end = this->domain_.end(); iter != end; ++iter)
		if (!(*iter)->EdgeContain(root_point)) { return false; }

	return true;
}

bool DomainIntersection::FullContain(const Vector& root_point) const {
	if (this->domain_.empty()) { return false; }

	auto iter(this->domain_.begin());

	for (auto end(this->domain_.end()); iter != end; ++iter)
		if (!(*iter)->EdgeContain(root_point)) { return false; }

	return true;
}

Domain::ContainType DomainIntersection::GetContainType(
	const Vector& root_point) const {
	ContainType cont(ContainType::none);

	auto iter(this->domain_.begin());

	for (auto end(this->domain_.end()); iter != end; ++iter) {
		cont = (*iter)->GetContainType(root_point);
		if (cont == ContainType::none) { return ContainType::none; }

		if (cont == ContainType::edge) {
			for (++iter; iter != end; ++iter) {
				if (!(*iter)->Contain(root_point)) return ContainType::none;
			}
		}
	}

	return cont;
}

#///////////////////////////////////////////////////////////////////////////////

RayCastData DomainIntersection::RayCast(const Ray& ray) const {
	switch (this->domain_.size()) {
		case 0: return RayCastData(false);
		case 1: return this->domain_[0]->RayCast(ray);
	}

	RayCastData r;

	auto domain_i(this->domain_.begin());

	for (auto domain_end(this->domain_.end()); domain_i != domain_end;
		 ++domain_i) {
		cntr::Vector<RayCastData> rcdv((*domain_i)->RayCastFull(ray));

		if (rcdv.empty()) { continue; }

		auto rcdv_iter(rcdv.begin());
		auto rcdv_end(rcdv.end());

		Sort(rcdv_iter, rcdv_end);

		for (; rcdv_iter != rcdv_end && (*rcdv_iter) < r; ++rcdv_iter) {
			auto domain_j(this->domain_.begin());

			for (; domain_j != domain_i; ++domain_j)
				if (!(*domain_j)->Contain((*rcdv_iter)->root_point)) goto A;

			for (++domain_j; domain_j != domain_end; ++domain_j)
				if (!(*domain_j)->Contain((*rcdv_iter)->root_point)) goto A;

			r = Move(*rcdv_iter);
			break;
		A:;
		}
	}

	return r;
}

cntr::Vector<RayCastData> DomainIntersection::RayCastFull(
	const Ray& ray) const {
	switch (this->domain_.size()) {
		case 0: return {};
		case 1: return this->domain_[0]->RayCastFull(ray);
	}

	cntr::Vector<RayCastData> r;

	auto domain_i(this->domain_.begin());

	for (auto domain_end(this->domain_.end()); domain_i != domain_end;
		 ++domain_i) {
		cntr::Vector<RayCastData> rcdv((*domain_i)->RayCastFull(ray));

		if (rcdv.empty()) { continue; }

		auto rcd_i(rcdv.begin());

		for (auto rcd_end(rcdv.end()); rcd_i != rcd_end; ++rcd_i) {
			auto domain_j(this->domain_.begin());

			for (; domain_j != domain_i; ++domain_j)
				if (!(*domain_j)->Contain((*rcd_i)->root_point)) goto A;

			for (++domain_j; domain_j != domain_end; ++domain_j)
				if (!(*domain_j)->Contain((*rcd_i)->root_point)) goto A;

			r.Push(Move(*rcd_i));
		A:;
		}
	}

	return r;
}

#///////////////////////////////////////////////////////////////////////////////

bool DomainIntersection::IsTanVector(
	const Vector& root_point, const Vector& root_vector) const {
	RHO__debug_if(this->dim_r() != root_point.size() ||
				  this->dim_r() != root_vector.size()) {
		RHO__throw__local("dim error");
	}

	auto iter(this->domain_.begin());

	for (auto end(this->domain_.end()); iter != end; ++iter) {
		switch ((*iter)->GetContainType(root_point)) {
			case ContainType::none: return false;
			case ContainType::edge:
				return (*iter)->IsTanVector(root_point, root_vector);
		}
	}

	return true;
}

}