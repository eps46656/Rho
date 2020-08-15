#include "define.cuh"
#include "DomainParallelotope.cuh"

#define RHO__throw__local(desc) RHO__throw(DomainParallelotope, __func__, desc)

namespace rho {

DomainParallelotope::DomainParallelotope(Space* ref): DomainSole(ref) {}

#///////////////////////////////////////////////////////////////////////////////

bool DomainParallelotope::Refresh() const {
	if (!this->ref()->RefreshSelf()) { return false; }

	ContainFlag flag(0);
	ContainFlag flag_end(1);
	flag_end <<= this->dim_s();

	this->tod_matrix_.Resize(flag_end);

	for (; flag != flag_end; ++flag) {
		const Num* a_i(this->ref()->root_axis());
		Num* m_i(this->tod_matrix_[flag]);

		for (ContainFlag reader(1); reader != flag_end;
			 reader <<= 1, a_i += RHO__max_dim) {
			if (!(flag & reader)) {
				Copy(this->dim_r(), m_i, a_i);
				m_i += RHO__max_dim;
			}
		}

		this->tod_matrix_[flag].set_dim(
			(m_i - this->tod_matrix_[flag]) / RHO__max_dim, this->dim_r());
		Tod::TanMatrix(this->tod_matrix_[flag]);
	}

	return true;
}

#///////////////////////////////////////////////////////////////////////////////

bool DomainParallelotope::Contain_s(const Num* point) const {
	for (size_t i(0); i != this->dim_s(); ++i) {
		if (point[i].lt<-1>() || point[i].gt<1>()) { return false; }
	}

	return true;
}

#///////////////////////////////////////////////////////////////////////////////

bool DomainParallelotope::RayCastB(const Ray& ray) const {
	RayCastTemp rct;
	if (!this->RayCast_(ray, rct)) { return false; }

	if (rct.t[0].eq<0>()) { return rct.t[1].ne<0>() && rct.t[1].lt<1>(); }

	return rct.t[0].lt<1>();
}

RayCastData DomainParallelotope::RayCast(const Ray& ray) const {
	RayCastTemp rct;

	if (this->RayCast_(ray, rct)) {
		if (rct.t[0].ne<0>()) {
			auto rcd(New<RayCastDataCore_>());
			rcd->domain = this;
			rcd->t = rct.t[0];
			rcd->phase.set(false, rct.t[0] != rct.t[1]);
			rcd->contain_flag = rct.contain_flag[0];

			return RayCastData(rcd);
		}

		if (rct.t[1].ne<0>()) {
			auto rcd(New<RayCastDataCore_>());
			rcd->domain = this;
			rcd->t = rct.t[1];
			rcd->phase.set(true, false);
			rcd->contain_flag = rct.contain_flag[1];

			return RayCastData(rcd);
		}
	}

	return RayCastData();
}

void DomainParallelotope::RayCastForRender(RayCastDataPair& rcdp,
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
		rcd->contain_flag = rct.contain_flag[0];

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
		rcd->contain_flag = rct.contain_flag[1];

		if (rct.t[1] < rcdp[0]) {
			rcdp[1] = Move(rcdp[0]);
			rcdp[0] = rcd;
		} else {
			rcdp[1] = rcd;
		}
	}
}

bool DomainParallelotope::RayCastFull(RayCastDataVector& dst,
									  const Ray& ray) const {
	RayCastTemp rct;

	if (this->RayCast_(ray, rct)) {
		if (rct.t[0].ne<0>()) {
			auto rcd(New<RayCastDataCore_>());
			rcd->domain = this;
			rcd->t = rct.t[0];
			rcd->phase.set(false, rct.t[0] != rct.t[1]);
			rcd->contain_flag = rct.contain_flag[0];

			dst.Push(rcd);
		}

		if (rct.t[0] != rct.t[1]) {
			auto rcd(New<RayCastDataCore_>());
			rcd->domain = this;
			rcd->t = rct.t[1];
			rcd->phase.set(true, false);
			rcd->contain_flag = rct.contain_flag[1];

			dst.Push(rcd);
		}
	}

	return false;
}

bool DomainParallelotope::RayCast_(const Ray& ray, RayCastTemp& rct) const {
	rct.t[0] = 0;
	rct.t[1] = RHO__inf;
	rct.contain_flag[0] = rct.contain_flag[1] = 0;

	Vec origin;
	Vec direct;

	this->ref()->MapPointFromRoot_rr(origin, ray.origin);
	this->ref()->MapVectorFromRoot_rr(direct, ray.direct);

#///////////////////////////////////////////////////////////////////////////////

	for (dim_t i(this->dim_s()); i != this->dim_r(); ++i) {
		if (direct[i].eq<0>()) {
			if (origin[i].eq<0>()) { continue; }
			return false;
		}

		Num t(-origin[i] / direct[i]);
		if (t < rct.t[0] || rct.t[1] < t) { return false; }
		rct.t[0] = rct.t[1] = t;
	}

#///////////////////////////////////////////////////////////////////////////////

	for (dim_t i(0); i != this->dim_s(); ++i) {
		if (direct[i].eq<0>()) {
			if (origin[i].lt<-1>() || origin[i].gt<1>()) { return false; }
			continue;
		}

		Num t[]{ (-1 - origin[i]) / direct[i], (1 - origin[i]) / direct[i] };

		if (t[1] < t[0]) { Swap(t[0], t[1]); }
		if (t[1] < rct.t[0] || rct.t[1] < t[0]) { return false; }

		if (rct.t[0] < t[0]) {
			rct.t[0] = t[0];
			rct.contain_flag[0] = ContainFlag(1) << i;
		} else if (rct.t[0] == t[0]) {
			rct.contain_flag[0] |= ContainFlag(1) << i;
		}

		if (t[1] < rct.t[1]) {
			rct.t[1] = t[1];
			rct.contain_flag[1] = ContainFlag(1) << i;
		} else if (t[1] == rct.t[1]) {
			rct.contain_flag[1] |= ContainFlag(1) << i;
		}
	}

	return true;
}

#///////////////////////////////////////////////////////////////////////////////

void DomainParallelotope::GetTodTan(Num* dst, const RayCastData& rcd,
									const Num* root_direct) const {
	dot(this->dim_r(), this->dim_r(), dst, root_direct,
		this->tod_matrix_[rcd.Get<RayCastDataCore_*>()->contain_flag]);
}

#////////////////////////////////////////////////

size_t DomainParallelotope::Complexity() const {
	return 10 * this->dim_s() + 5 * this->dim_cr();
}

}