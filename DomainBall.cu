#include "define.cuh"
#include "DomainBall.cuh"

#define RHO__throw__local(desc) RHO__throw(DomainBall, __func__, desc)

namespace rho {

DomainBall::DomainBall(Space* parent): DomainSole(parent) {}

#///////////////////////////////////////////////////////////////////////////////

bool DomainBall::Refresh() const { return this->ref()->RefreshSelf(); }

#///////////////////////////////////////////////////////////////////////////////

bool DomainBall::Contain_s(const Num* point) const {
	return sq(this->dim_s(), point).le<1>();
}

#///////////////////////////////////////////////////////////////////////////////

bool DomainBall::RayCastB(const Ray& ray) const {
	RayCastTemp rct;

	if (!this->RayCast_(ray, rct)) { return false; }
	if (rct.t[0].ne<0>()) { return rct.t[0].lt<1>(); }
	if (rct.t[1].ne<0>()) { return rct.t[1].lt<1>(); }

	return false;
}

RayCastData DomainBall::RayCast(const Ray& ray) const {
	RayCastTemp rct;

	if (this->RayCast_(ray, rct)) {
		if (rct.t[0].ne<0>()) {
			auto rcd(New<RayCastDataCore_>());
			rcd->domain = this;
			rcd->t = rct.t[0];
			rcd->phase.set(false, rct.t[0] != rct.t[1]);
			line<RHO__max_dim>(rcd->point, rct.t[0], rct.direct, rct.origin);

			return RayCastData(rcd);
		}

		if (rct.t[0] != rct.t[1]) {
			auto rcd(New<RayCastDataCore_>());
			rcd->domain = this;
			rcd->t = rct.t[1];
			rcd->phase.set(true, false);
			line<RHO__max_dim>(rcd->point, rct.t[1], rct.direct, rct.origin);

			return RayCastData(rcd);
		}
	}

	return RayCastData();
}

void DomainBall::RayCastForRender(RayCastDataPair& rcdp,
								  ComponentCollider* cmpt_collider,
								  const Ray& ray) const {
	RayCastTemp rct;
	if (!this->RayCast_(ray, rct)) { return; }

	if (rct.t[0].ne<0>()) {
		if (rcdp[1] < rct.t[0]) { return; }

		auto rcd(New<RayCastDataCore_>());
		rcd->cmpt_collider = cmpt_collider;
		rcd->domain = this;
		rcd->t = rct.t[0];
		rcd->phase.set(false, rct.t[0] != rct.t[1]);
		line<RHO__max_dim>(rcd->point, rct.t[0], rct.direct, rct.origin);

		if (rct.t[0] < rcdp[0]) {
			rcdp[1] = Move(rcdp[0]);
			rcdp[0] = rcd;
		} else {
			rcdp[1] = rcd;
			return;
		}
	}

	if (rct.t[0] != rct.t[1] && rct.t[1] < rcdp[1]) {
		auto rcd(New<RayCastDataCore_>());
		rcd->cmpt_collider = cmpt_collider;
		rcd->domain = this;
		rcd->t = rct.t[1];
		rcd->phase.set(true, false);
		line<RHO__max_dim>(rcd->point, rct.t[1], rct.direct, rct.origin);

		if (rct.t[0] < rcdp[0]) {
			rcdp[1] = Move(rcdp[0]);
			rcdp[0] = rcd;
		} else {
			rcdp[1] = rcd;
		}
	}
}

bool DomainBall::RayCastFull(RayCastDataVector& dst, const Ray& ray) const {
	RayCastTemp rct;

	if (this->RayCast_(ray, rct)) {
		if (rct.t[0].ne<0>()) {
			auto rcd(New<RayCastDataCore_>());
			rcd->domain = this;
			rcd->t = rct.t[0];
			rcd->phase.set(false, rct.t[0] != rct.t[1]);
			line<RHO__max_dim>(rcd->point, rct.t[0], rct.direct, rct.origin);

			dst.Push(rcd);
		}

		if (rct.t[0] != rct.t[1]) {
			auto rcd(New<RayCastDataCore_>());
			rcd->domain = this;
			rcd->t = rct.t[1];
			rcd->phase.set(true, false);
			line<RHO__max_dim>(rcd->point, rct.t[1], rct.direct, rct.origin);

			dst.Push(rcd);
		}
	}

	return false;
}

bool DomainBall::RayCast_(const Ray& ray, RayCastTemp& rct) const {
	this->ref()->MapPointFromRoot_rr(rct.origin, ray.origin);
	this->ref()->MapVectorFromRoot_rr(rct.direct, ray.direct);

#///////////////////////////////////////////////////////////////////////////////

	{
		Num a(0);
		Num b(0);
		Num c(-1);

		for (size_t i(0); i != this->dim_s(); ++i) {
			a += sq(rct.direct[i]);
			b -= rct.origin[i] * rct.direct[i];
			c += sq(rct.origin[i]);
		}

		if (a.eq<0>()) {
			if (c.gt<0>()) { return false; }
		} else {
			if ((c = sq(b) - a * c).lt<0>()) { return false; }
			c = sqrt(c);

			rct.t[1] = (b + c) / a;
			if (rct.t[1].lt<0>()) { return false; }

			rct.t[0] = (b - c) / a;
			if (rct.t[0].lt<0>()) { rct.t[0] = 0; }
		}
	}

#///////////////////////////////////////////////////////////////////////////////

	for (size_t i(this->dim_s()); i != this->dim_r(); ++i) {
		if (rct.direct[i].eq<0>()) {
			if (rct.origin[i].eq<0>()) { continue; }
			return false;
		}

		Num t(-rct.origin[i] / rct.direct[i]);
		if (t < rct.t[0] || rct.t[1] < t) { return false; }
		rct.t[0] = rct.t[1] = t;
	}

	return true;
}

#///////////////////////////////////////////////////////////////////////////////

Matrix DomainBall::GetParallelVector_s(const Vector& point) const {
	RHO__debug_if(this->dim_r() != point.dim() &&
				  this->dim_s() != point.dim()) {
		RHO__throw__local("dim error");
	}

	Num a(sq(this->dim_s(), point));

	if (a.ne<1>()) {
		Matrix r(this->dim_s(), this->dim_r());
		Matrix::identity(r, this->dim_r());

		return r;
	}

	Matrix orth(1, this->dim_s());
	Copy(this->dim_s(), orth, point);

	Complement(orth);

	Matrix tan(this->dim_s() - 1, this->dim_r());
	dot(this->dim_s() - 1, this->dim_s(), this->dim_r(), tan,
		orth + this->dim_s(), this->ref()->root_axis());

	return tan;
}

#///////////////////////////////////////////////////////////////////////////////

void DomainBall::GetTodTan(Num* dst, const RayCastData& rcd,
						   const Num* root_direct) const {
	RHO__debug_if(this != rcd->domain) RHO__throw__local("domain sole error");

	Num* point(rcd.Get<RayCastDataCore_*>()->point);

	Mat m;
	Mat temp;

	if (sq(this->dim_s(), point).ne<1>()) {
		Matrix::identity(temp, this->dim_r());
		Tod::TanMatrix(this->dim_s(), this->dim_r(), m, temp);
	} else {
		Copy<RHO__max_dim>(m, point);
		Complement(1, this->dim_s(), m);

		dot(this->dim_s() - 1, this->dim_s(), this->dim_r(), temp,
			m + RHO__max_dim, this->ref()->root_axis());

		Tod::TanMatrix(this->dim_s() - 1, this->dim_r(), m, temp);
	}

	dot(this->dim_r(), this->dim_r(), dst, root_direct, m);
}

#//////////////////////////////////////////////////////////////////////////////

size_t DomainBall::Complexity() const {
	return 15 * this->dim_s() + 5 * this->dim_cr();
}

}
