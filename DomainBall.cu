#include "define.cuh"
#include "DomainBall.cuh"

#define RHO__throw__local(desc) RHO__throw(DomainBall, __func__, desc)

namespace rho {

DomainBall::DomainBall(Space* ref): DomainSole(ref) {}

#///////////////////////////////////////////////////////////////////////////////

const Domain* DomainBall::Refresh() const {
	if (!this->ref_) { return nullptr; }
	this->ref_->Refresh();
	return this;
}

#///////////////////////////////////////////////////////////////////////////////

bool DomainBall::Contain_s(const Num* point) const {
	return sq(this->dim(), point).le<1>();
}

#///////////////////////////////////////////////////////////////////////////////

size_t DomainBall::RayCastComplexity() const {
	return 15 * this->dim() + 5 * this->root_codim();
}

bool DomainBall::RayCast(RayCastData& dst, const Ray& ray) const {
	RayCastTemp rct;

	if (this->RayCast_(ray, rct)) {
		if (rct.t[0].ne<0>()) {
			dst.domain = this;
			dst.t = rct.t[0];
			dst.phase.set(false, rct.t[0] != rct.t[1]);
			line<RHO__max_dim>(reinterpret_cast<Num*>(dst.spare), rct.t[0],
							   rct.direct, rct.origin);

			return true;
		}

		if (rct.t[0] != rct.t[1]) {
			dst.domain = this;
			dst.t = rct.t[1];
			dst.phase.set(true, false);
			line<RHO__max_dim>(reinterpret_cast<Num*>(dst.spare), rct.t[1],
							   rct.direct, rct.origin);

			return true;
		}
	}

	return false;
}

bool DomainBall::RayCastB(const Ray& ray) const {
	RayCastTemp rct;

	if (!this->RayCast_(ray, rct)) { return false; }
	if (rct.t[0].ne<0>()) { return rct.t[0].lt<1>(); }
	if (rct.t[1].ne<0>()) { return rct.t[1].lt<1>(); }

	return false;
}

void DomainBall::RayCastPair(RayCastDataPair& dst, const Ray& ray) const {
	RayCastTemp rct;
	if (!this->RayCast_(ray, rct)) { return; }

	if (rct.t[0].ne<0>()) {
		if (dst[1] <= rct.t[0]) { return; }

		if (dst[0] <= rct.t[0]) {
			dst[1].Destroy();

			dst[1].domain = this;
			dst[1].t = rct.t[0];
			dst[1].phase.set(false, rct.t[0] != rct.t[1]);
			line<RHO__max_dim>(reinterpret_cast<Num*>(dst[1].spare), rct.t[0],
							   rct.direct, rct.origin);

			return;
		}

		dst[1] = dst[0];

		dst[0].domain = this;
		dst[0].t = rct.t[0];
		dst[0].phase.set(false, rct.t[0] != rct.t[1]);
		line<RHO__max_dim>(reinterpret_cast<Num*>(dst[0].spare), rct.t[0],
						   rct.direct, rct.origin);
	}

	if (rct.t[0] == rct.t[1] || dst[1] <= rct.t[1]) { return; }

	dst[1].Destroy();

	dst[1].domain = this;
	dst[1].t = rct.t[0];
	dst[1].phase.set(true, false);
	line<RHO__max_dim>(reinterpret_cast<Num*>(dst[1].spare), rct.t[1],
					   rct.direct, rct.origin);
}

size_t DomainBall::RayCastFull(RayCastData* dst, const Ray& ray) const {
	RayCastTemp rct;
	if (!this->RayCast_(ray, rct)) { return 0; }

	size_t size(0);

	if (rct.t[0].ne<0>()) {
		dst[size].domain = this;
		dst[size].t = rct.t[0];
		dst[size].phase.set(false, rct.t[0] != rct.t[1]);
		line<RHO__max_dim>(reinterpret_cast<Num*>(dst[size].spare), rct.t[0],
						   rct.direct, rct.origin);

		++size;
	}

	if (rct.t[0] != rct.t[1]) {
		dst[size].domain = this;
		dst[size].t = rct.t[1];
		dst[size].phase.set(true, false);
		line<RHO__max_dim>(reinterpret_cast<Num*>(dst[size].spare), rct.t[1],
						   rct.direct, rct.origin);

		++size;
	}

	return size;
}

bool DomainBall::RayCast_(const Ray& ray, RayCastTemp& rct) const {
	this->ref_->MapPointFromRoot_rr(rct.origin, ray.origin);
	this->ref_->MapVectorFromRoot_rr(rct.direct, ray.direct);

#///////////////////////////////////////////////////////////////////////////////

	Num a(0);
	Num b(0);
	Num c(-1);

	for (dim_t i(0); i != this->dim(); ++i) {
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

#///////////////////////////////////////////////////////////////////////////////

	if (this->ref_->root_codim() != 0) {
		dim_t i(this->dim());
		do {
			if (rct.direct[i].eq<0>()) {
				if (rct.origin[i].eq<0>()) { continue; }
				return false;
			}

			Num t(-rct.origin[i] / rct.direct[i]);
			if (t < rct.t[0] || rct.t[1] < t) { return false; }
			rct.t[0] = rct.t[1] = t;
		} while (++i != this->ref_->root_dim());
	}

	return true;
}

#///////////////////////////////////////////////////////////////////////////////

Matrix DomainBall::GetParallelVector_s(const Vector& point) const {
	RHO__debug_if(this->root_dim() != point.dim() &&
				  this->dim() != point.dim()) {
		RHO__throw__local("dim error");
	}

	Num a(sq(this->dim(), point));

	if (a.ne<1>()) {
		Matrix r(this->dim(), this->root_dim());
		Matrix::identity(r, this->root_dim());

		return r;
	}

	Matrix orth(1, this->dim());
	Copy(this->dim(), orth, point);

	Complement(orth);

	Matrix tan(this->dim() - 1, this->root_dim());
	dot(this->dim() - 1, this->dim(), this->root_dim(), tan, orth + this->dim(),
		this->ref_->root_axis());

	return tan;
}

#///////////////////////////////////////////////////////////////////////////////

void DomainBall::GetTodTan(Num* dst, const RayCastData& rcd,
						   const Num* root_direct) const {
	RHO__debug_if(this != rcd.domain) {
		RHO__throw__local("domain sole error");
	}

	const Num* point(reinterpret_cast<const Num*>(rcd.spare));

	Mat m;
	Mat temp;

	if (sq(this->dim(), point).ne<1>()) {
		Matrix::identity(temp, this->root_dim());
		Tod::TanMatrix(this->dim(), this->root_dim(), m, temp);
	} else {
		Copy<RHO__max_dim>(m, point);
		Complement(1, this->dim(), m);

		dot(this->dim() - 1, this->dim(), this->root_dim(), temp,
			m + RHO__max_dim, this->ref_->root_axis());

		Tod::TanMatrix(this->dim() - 1, this->root_dim(), m, temp);
	}

	dot(this->root_dim(), this->root_dim(), dst, root_direct, m);
}

}