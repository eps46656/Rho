#include"define.cuh"
#include"DomainSimplex.h"

#define RHO__throw__local(description) \
	RHO__throw(DomainSimplex, __func__, description);

namespace rho {

DomainSimplex::DomainSimplex(Space* ref) :DomainSole(ref) {}

#////////////////////////////////////////////////

void DomainSimplex::Refresh()const {}

bool DomainSimplex::ReadyForRendering()const {
	ContainFlag flag(0);
	ContainFlag flag_end(1); --(flag <<= (this->dim_s() + 1));
	ContainFlag reader_end(1); reader_end <<= this->dim_s();

	this->tod_matrix_.Resize(flag_end);

	for (; flag != flag_end; ++flag) {
		Matrix m(this->dim_r(), this->dim_r());

		auto a_i(this->ref()->root_axis_rr().begin());
		auto m_i(m.begin());

		ContainFlag reader(1);

		for (; reader != reader_end; reader <<= 1, a_i += this->dim_r()) {
			if (!(flag & reader)) {
				Memcpy(sizeof(Num)*this->dim_r(), m_i, a_i);
				m_i += this->dim_r();
			}
		}

		if (flag & reader) {
			auto end(m_i - this->dim_r());

			for (m_i = m.begin(); m_i != end; m_i += this->dim_r()) {
				for (size_t i(0); i != this->dim_r(); ++i)
					m_i[i] -= m_i[i + this->dim_r()];
			}
		}

		m.resize((m_i - m.begin()) / this->dim_r(), this->dim_r());

		TodMatrixTan(m);

		this->tod_matrix_[flag] = Move(m);
	}

	return true;
}

#////////////////////////////////////////////////

bool DomainSimplex::
Contain_s(const Vector& point)const {
	RHO__debug_if(this->dim_s() != point.size() &&
				  this->dim_r() != point.size()) {

		RHO__throw__local("dim error");
	}

	Num r(Num::zero());
	auto iter(point.begin());
	auto end(point.begin() + this->dim_s());

	for (; iter != end; ++iter) {
		if (iter->lt<0>()) { return false; }
		r += *iter;
	}

	if (r.gt<1>()) { return false; }

	for (end = point.end(); iter != end; ++iter)
		if (iter->ne<0>()) { return false; }

	return true;
}

bool DomainSimplex::
EdgeContain_s(const Vector& point)const {
	RHO__debug_if(this->dim_s() != point.size() &&
				  this->dim_r() != point.size()) {

		RHO__throw__local("dim error");
	}

	if (this->dim_cr()) { return this->Contain_s(point); }

	Num r(Num::zero());
	auto iter(point.begin());
	auto end(point.begin() + this->dim_s());

	for (; iter != end; ++iter) {
		if (iter->lt<0>()) { return false; }
		if (iter->eq<0>()) { goto A; }
		r += *iter;
	}

	return r.eq<1>();

A:;

	for (; iter != end; ++iter) {
		if (iter->lt<0>()) { return false; }
		r += *iter;
	}

	return r.le<1>();
}

bool DomainSimplex::
FullContain_s(const Vector& point)const {
	RHO__debug_if(this->dim_s() != point.size() &&
				  this->dim_r() != point.size()) {

		RHO__throw__local("dim error");
	}

	if (this->dim_cr()) { return false; }

	Num r(Num::zero());
	auto iter(point.begin());

	for (auto end(point.begin() + this->dim_s());
		 iter != end; ++iter) {

		if (iter->lt<0>()) { return false; }
		r += *iter;
	}

	return r.lt<1>();
}

Domain::ContainType DomainSimplex::
GetContainType_s(const Vector& point)const {
	RHO__debug_if(this->dim_s() != point.size() &&
				  this->dim_r() != point.size()) {

		RHO__throw__local("dim error");
	}

	if (this->dim_cr())
		return this->Contain_s(point) ?
		ContainType::edge : ContainType::none;

	Num r(Num::zero());
	auto iter(point.begin());
	auto end(point.end());

	for (; iter != end; ++iter) {
		if (iter->lt<0>()) { return ContainType::none; }
		if (iter->eq<0>()) { goto A; }
		r += *iter;
	}

	if (r.lt<1>()) { return ContainType::full; }
	if (r.gt<1>()) { return ContainType::none; }
	return ContainType::edge;

A:;

	isum(r, iter, end);
	return r.gt<1>() ? ContainType::none : ContainType::edge;
}

#////////////////////////////////////////////////

DomainSimplex::ContainFlag DomainSimplex::
GetContainFlag(const Vector& point) const {
	RHO__debug_if(this->dim_s() != point.size() &&
				  this->dim_r() != point.size()) {

		RHO__throw__local("dim error");
	}

	ContainFlag r(contain_flag_header);
	ContainFlag writer(1);

	Num sum(Num::zero());
	auto iter(point.begin());
	auto end(point.begin() + this->dim_s());

	for (; iter != end; ++iter, writer <<= 1) {
		if (iter->lt<0>()) { return 0; }
		if (iter->eq<-1>() || iter->eq<1>()) { r |= writer; }
		sum += *iter;
	}

	for (end = point.end(); iter != end; ++iter)
		if (iter->ne<0>()) { return 0; }

	if (sum.gt<1>()) { return 0; }
	if (sum.eq<1>()) { r |= writer; }

	return r;
}

#////////////////////////////////////////////////

RayCastData DomainSimplex::
RayCast(const Ray& ray)const {
	auto rct(this->RayCast_(ray));

	if (!rct) { return RayCastData(); }

	if (rct->t[0].ne<0>()) {
		auto rcd(New<RayCastDataCore_>());
		rcd->domain = this;
		rcd->t = rct->t[0];
		rcd->root_point = ray.root_point(rct->t[0]);
		rcd->contain_flag = rct->contain_flag[0];

		Delete(rct); return RayCastData(rcd);
	}

	if (rct->t[1].ne<0>()) {
		auto rcd(New<RayCastDataCore_>());
		rcd->domain = this;
		rcd->t = rct->t[1];
		rcd->root_point = ray.root_point(rct->t[1]);
		rcd->contain_flag = rct->contain_flag[1];

		Delete(rct); return RayCastData(rcd);
	}

	Delete(rct); return RayCastData();
}

cntr::Vector<RayCastData> DomainSimplex::
RayCastFull(const Ray& ray)const {
	RayCastTemp* rct(this->RayCast_(ray));

	cntr::Vector<RayCastData> r;

	if (!rct) { return r; }

	if (rct->t[0].ne<0>()) {
		auto rcd(New<RayCastDataCore_>());
		rcd->domain = this;
		rcd->t = rct->t[0];
		rcd->root_point = ray.root_point(rct->t[0]);
		rcd->contain_flag = rct->contain_flag[0];

		r.Push(rcd);
	}

	if (rct->t[0] != rct->t[1]) {
		auto rcd(New<RayCastDataCore_>());
		rcd->domain = this;
		rcd->t = rct->t[1];
		rcd->root_point = ray.root_point(rct->t[1]);
		rcd->contain_flag = rct->contain_flag[1];

		r.Push(rcd);
	}

	Delete(rct); return r;
}

void DomainSimplex::RayCastForRender(
	pair<RayCastData>& rcd_p,
	ComponentCollider* cmpt_collider,
	const Ray& ray)const {

	RayCastTemp* rct(this->RayCast_(ray));

	if (!rct) { return; }

	if (rct->t[0].ne<0>()) {
		if (rcd_p.second < rct->t[0]) { return; }

		auto rcd(New<RayCastDataCore_>());
		rcd->cmpt_collider = cmpt_collider;
		rcd->domain = this;
		rcd->t = rct->t[0];
		rcd->root_point = ray.root_point(rct->t[0]);
		rcd->contain_flag = rct->contain_flag[0];

		if (rct->t[0] < rcd_p.first) {
			rcd_p.second = Move(rcd_p.first);
			rcd_p.first = rcd;
		} else {
			rcd_p.second = rcd;
			return;
		}
	}

	if (rct->t[0] != rct->t[1] && rct->t[1] < rcd_p.second) {
		auto rcd(New<RayCastDataCore_>());
		rcd->cmpt_collider = cmpt_collider;
		rcd->domain = this;
		rcd->t = rct->t[1];
		rcd->root_point = ray.root_point(rct->t[1]);
		rcd->contain_flag = rct->contain_flag[1];

		if (rct->t[1] < rcd_p.first) {
			rcd_p.second = Move(rcd_p.first);
			rcd_p.first = rcd;
		} else {
			rcd_p.second = rcd;
		}
	}

	Delete(rct);
}

#////////////////////////////////////////////////

bool DomainSimplex::IsTanVector(
	const Vector& root_point, const Vector& root_vector)const {

	RHO__debug_if(this->dim_r() != root_point.size() ||
				  this->dim_r() != root_vector.size()) {

		RHO__throw__local("dim error");
	}

	Vector point(this->dim_r());
	this->ref()->MapPointFromRoot_rr(
		point.begin(), root_point.begin());

	auto contain_flag(this->GetContainFlag(root_point));

	if (!contain_flag) { return false; }
	if (!(contain_flag & (contain_flag - 1))) { return true; }

	return root_vector == root_vector * this->tod_matrix_[contain_flag];
}

#////////////////////////////////////////////////

DomainSimplex::RayCastTemp* DomainSimplex::
RayCast_(const Ray& ray) const {
	RHO__debug_if(this->root() != ray.root())
		RHO__throw__local("root space error");

#define RHO__fail {Delete(rct); return nullptr; }

	auto rct(New<RayCastTemp>());

	rct->origin.resize(this->dim_r());
	rct->direct.resize(this->dim_r());

	auto origin_i(rct->origin.begin());
	auto direct_i(rct->direct.begin());

	this->ref()->MapPointFromRoot_rr(
		origin_i, ray.root_origin_r().begin());

	this->ref()->MapVectorFromRoot_rr(
		direct_i, ray.root_direct_r().begin());

	rct->t[0] = Num::zero();
	rct->t[1] = Num::inf();
	rct->contain_flag[0] = rct->contain_flag[1] = 0;

#////////////////////////////////////////////////

	if (this->dim_cr()) {
		origin_i += this->dim_s();
		direct_i += this->dim_s();

		for (auto end(rct->origin.end());
			 origin_i != end; ++origin_i, ++direct_i) {

			if (direct_i->eq<0>()) {
				if (origin_i->ne<0>()) { RHO__fail }
				continue;
			}

			Num a(-(*origin_i) / (*direct_i));

			if (a < rct->t[0] || rct->t[1] < a) { RHO__fail }
			rct->t[0] = rct->t[1] = a;
		}

		origin_i = rct->origin.begin();
		direct_i = rct->direct.begin();
	}

#////////////////////////////////////////////////

	Num origin_sum(Num::one());
	Num direct_sum(Num::zero());

	ContainFlag writer(1);

	for (ContainFlag end(ContainFlag(1) << this->dim_s());
		 writer != end; writer <<= 1, ++origin_i, ++direct_i) {

		if (direct_i->eq<0>()) {
			if (origin_i->lt<0>() || origin_i->gt<1>()) { RHO__fail }
			continue;
		}

		Num a(-(*origin_i) / (*direct_i));

		if (direct_i->lt<0>()) {
			if (a < rct->t[0]) { RHO__fail }
			if (a < rct->t[1]) {
				rct->t[1] = a;
				rct->contain_flag[1] = writer;
			} else if (a == rct->t[1]) {
				rct->contain_flag[1] |= writer;
			}
		} else {
			if (rct->t[1] < a) { RHO__fail }
			if (rct->t[0] < a) {
				rct->t[0] = a;
				rct->contain_flag[0] = writer;
			} else if (rct->t[0] == a) {
				rct->contain_flag[0] |= writer;
			}
		}

		origin_sum -= (*origin_i);
		direct_sum += (*direct_i);
	}

	if (direct_sum.eq<0>()) {
		if (origin_sum.lt<0>()) { RHO__fail }
		return rct;
	}

	Num a(origin_sum / direct_sum);

	if (direct_sum.lt<0>()) {
		if (rct->t[1] < a) { RHO__fail }
		if (rct->t[0] < a) {
			rct->t[0] = a;
			rct->contain_flag[0] = writer;
		} else if (rct->t[0] == a) {
			rct->contain_flag[0] |= writer;
		}
	} else {
		if (a < rct->t[0]) { RHO__fail }
		if (a < rct->t[1]) {
			rct->t[1] = a;
			rct->contain_flag[1] = writer;
		} else if (a == rct->t[1]) {
			rct->contain_flag[1] |= writer;
		}
	}

	return rct;
}

#////////////////////////////////////////////////

TodData DomainSimplex::
Tod(const RayCastData& rcd, const Vector& root_direct)const {
	TodData r;

	r.orth = root_direct -
		(r.tan = root_direct *
		 this->tod_matrix_[
			 rcd.Get<RayCastDataCore_*>()->contain_flag]);

	return r;
}

}