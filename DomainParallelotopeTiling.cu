#include "DomainParallelotopeTiling.cuh"
#include "define.cuh"

#define RHO__throw__local(desc)                                                \
	RHO__throw(DomainParallelotopeTiling, __func__, desc);

namespace rho {

DomainParallelotopeTiling::DomainParallelotopeTiling(Space* ref):
	DomainSole(ref) {}

#///////////////////////////////////////////////////////////////////////////////

bool DomainParallelotopeTiling::Refresh() const {
	if (!this->ref()->RefreshSelf()) { return false; }

	this->tod_matrix_.set_dim(this->dim_s(), this->dim_r());
	Copy<RHO__max_dim_sq>(this->tod_matrix_, this->ref()->root_axis());
	Tod::TanMatrix(this->tod_matrix_);

	return true;
}

#///////////////////////////////////////////////////////////////////////////////

bool DomainParallelotopeTiling::Contain_s(const Num* point) const {
	return true;
}

#///////////////////////////////////////////////////////////////////////////////

bool DomainParallelotopeTiling::RayCastB(const Ray& ray) const {
	Num t(this->RayCast_(ray));
	return t.ne<0>() && t.lt<1>();
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

bool DomainParallelotopeTiling::RayCastFull(RayCastDataVector& dst,
											const Ray& ray) const {
	Num t(this->RayCast_(ray));

	if (t.eq<-1>()) { return true; }

	if (t.ne<0>()) {
		auto rcd(New<RayCastDataCore>());
		rcd->domain = this;
		rcd->t = t;

		dst.Push(rcd);
	}

	return false;
}

void DomainParallelotopeTiling::RayCastForRender(
	RayCastDataPair& rcdp, ComponentCollider* cmpt_collider,
	const Ray& ray) const {
	Num t(this->RayCast_(ray));

	if (t.gt<0>() && t < rcdp[1]) {
		auto rcd(New<RayCastDataCore>());
		rcd->cmpt_collider = cmpt_collider;
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

Num DomainParallelotopeTiling::RayCast_(const Ray& ray) const {
	NumVector origin;
	NumVector direct;

	this->ref()->MapPointFromRoot_rr(origin, ray.origin);
	this->ref()->MapVectorFromRoot_rr(direct, ray.direct);

#///////////////////////////////////////////////////////////////////////////////

	for (size_t i(this->dim_s()); i != this->dim_r(); ++i) {
		if (direct[i].eq<0>()) {
			if (origin[i].eq<0>()) { continue; }
			return 0;
		}

		Num t(-origin[i] / direct[i]);

		if (t.le<0>()) { return 0; }

		for (++i; i != this->dim_r(); ++i) {
			if (origin[i] != t * direct[i]) { return 0; }
		}

		return t;
	}

	return -1;
}

#///////////////////////////////////////////////////////////////////////////////

void DomainParallelotopeTiling::GetTodTan(Num* dst, const RayCastData& rcd,
										  const Num* root_direct) const {
	dot(this->dim_r(), this->dim_r(), dst, root_direct, this->tod_matrix_);
}

#///////////////////////////////////////////////////////////////////////////////

size_t DomainParallelotopeTiling::Complexity() const {
	return this->dim_cr() * 5;
}

} // namespace rho
