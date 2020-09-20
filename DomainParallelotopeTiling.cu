#include "DomainParallelotopeTiling.cuh"
#include "define.cuh"

#define RHO__throw__local(desc)                                                \
	RHO__throw(DomainParallelotopeTiling, __func__, desc);

namespace rho {

DomainParallelotopeTiling::DomainParallelotopeTiling(Space* ref):
	DomainSole(ref) {}

#///////////////////////////////////////////////////////////////////////////////

const Domain* DomainParallelotopeTiling::Refresh() const {
	if (!this->ref_) { return nullptr; }

	this->ref_->Refresh();

	Tod::TanMatrix(this->ref_->dim(), this->ref_->root_dim(), this->tod_matrix_,
				   this->ref_->root_axis());

	return this;
}

#///////////////////////////////////////////////////////////////////////////////

bool DomainParallelotopeTiling::Contain_s(const Num* point) const {
	for (dim_t i(this->ref_->dim()); i != this->ref_->root_dim(); ++i) {
		if (point[i].ne<0>()) { return false; }
	}

	return true;
}

#///////////////////////////////////////////////////////////////////////////////

size_t DomainParallelotopeTiling::RayCastComplexity() const {
	return this->ref_->root_codim() * 5;
}

RayCastData DomainParallelotopeTiling::RayCast(const Ray& ray) const {
	Num t(this->RayCast_(ray));
	RayCastData r;

	if (t.gt<0>()) {
		r = New<RayCastDataCore>();
		r->domain = this;
		r->t = t;
	}

	return r;
}

bool DomainParallelotopeTiling::RayCastB(const Ray& ray) const {
	Num t(this->RayCast_(ray));
	return t.ne<0>() && t.lt<1>();
}

void DomainParallelotopeTiling::RayCastPair(RayCastDataPair& rcdp,
											const Ray& ray) const {
	Num t(this->RayCast_(ray));

	if (t.gt<0>() && t < rcdp[1]) {
		auto rcd(New<RayCastDataCore>());
		rcd->domain = this;
		rcd->t = t;

		if (t < rcdp[0]) {
			rcdp[1] = Move(rcdp[0]);
			rcdp[0] = rcd;
		} else {
			rcdp[1] = rcd;
		}
	}
}

size_t DomainParallelotopeTiling::RayCastFull(RayCastData* dst,
											  const Ray& ray) const {
	Num t(this->RayCast_(ray));

	if (t.lt<0>()) { return RHO__Domain__RayCastFull_in_phase; }

	if (t.gt<0>()) {
		auto rcd(New<RayCastDataCore>());
		rcd->domain = this;
		rcd->t = t;
		dst[0] = rcd;

		return 1;
	}

	return 0;
}

Num DomainParallelotopeTiling::RayCast_(const Ray& ray) const {
	Vec origin;
	Vec direct;

	this->ref_->MapPointFromRoot_rr(origin, ray.origin);
	this->ref_->MapVectorFromRoot_rr(direct, ray.direct);

#///////////////////////////////////////////////////////////////////////////////

	for (dim_t i(this->ref_->dim()); i != this->ref_->root_dim(); ++i) {
		if (direct[i].eq<0>()) {
			if (origin[i].eq<0>()) { continue; }
			return 0;
		}

		Num t(-origin[i] / direct[i]);

		if (t.le<0>()) { return 0; }

		for (++i; i != this->ref_->root_dim(); ++i) {
			if (origin[i] != t * direct[i]) { return 0; }
		}

		return t;
	}

	return -1;
}

#///////////////////////////////////////////////////////////////////////////////

void DomainParallelotopeTiling::GetTodTan(Num* dst, const RayCastData& rcd,
										  const Num* root_direct) const {
	dot(this->ref_->root_dim(), this->ref_->root_dim(), dst, root_direct,
		this->tod_matrix_);
}

}