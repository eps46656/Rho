#include "define.cuh"
#include "DomainStretch.cuh"

#define RHO__throw__local(desc) RHO__throw(DomainStretch, __func__, desc)

#define RHO__fail 0
#define RHO__nm 1
#define RHO__tan 2
#define RHO__co 3

namespace rho {

Space* DomainStretch::ref() const { return this->ref_; }
Domain* DomainStretch::domain() const { return this->domain_; }

void DomainStretch::ref(Space* ref) { this->ref_ = ref; }
void DomainStretch::domain(Domain* domain) { this->domain_ = domain; }

Space* DomainStretch::root() const {
	return (this->ref_->root() == this->domain_->root()) ? this->ref_->root()
														 : nullptr;
}

#///////////////////////////////////////////////////////////////////////////////

DomainStretch::DomainStretch(Space* ref, Domain* domain):
	ref_(ref), eff_(New<Space>(ref->dim_s() - 1, ref->root())),
	domain_(domain) {}

#///////////////////////////////////////////////////////////////////////////////

bool DomainStretch::Refresh() const {
	if (this->root() != this->domain_->root() ||
		this->root() != this->ref_->root() || !this->domain_->Refresh() ||
		!this->ref_->RefreshSelf()) {
		return false;
	}

	this->eff_->SetOrigin(this->ref_->root_origin());
	this->eff_->SetAxis(this->ref_->root_axis());
	this->eff_->RefreshSelf();

#///////////////////////////////////////////////////////////////////////////////

	Tod::TanMatrix(this->ref_->dim_s(), this->ref_->dim_r(), this->ref_todm_,
				   this->ref_->root_axis());

	Tod::TanMatrix(this->eff_->dim_s(), this->eff_->dim_r(), this->eff_todm_,
				   this->eff_->root_axis());

	return true;
}

#///////////////////////////////////////////////////////////////////////////////

bool DomainStretch::Contain(const Num* root_point) const {
	Vec temp;
	this->ref_->MapPointFromRoot_rr(temp, root_point);

	if (temp[this->eff_->dim_s()].lt<0>() ||
		temp[this->eff_->dim_s()].gt<1>()) {
		return false;
	}

	for (dim_t i(this->ref_->dim_s()); i != this->dim_r(); ++i) {
		if (temp[i].ne<0>()) { return false; }
	}

	Vec temp_;
	this->eff_->MapPointToRoot_sr(temp_, temp);

	return this->domain_->Contain(temp_);
}

#///////////////////////////////////////////////////////////////////////////////

#define RHO__F                                                                 \
	{                                                                          \
		if (rct.t[0].ne<0>()) {                                                \
			auto rcd(New<RayCastDataCore_>());                                 \
			rcd->domain = this;                                                \
			rcd->t = rct.t[0];                                                 \
			rcd->phase.set(false, true);                                       \
			dst.Push(rcd);                                                     \
		}                                                                      \
		auto rcd(New<RayCastDataCore_>());                                     \
		rcd->domain = this;                                                    \
		rcd->t = rct.t[1];                                                     \
		rcd->phase.set(true, false);                                           \
		dst.Push(rcd);                                                         \
	}

bool DomainStretch::RayCastFull(RayCastDataVector& dst, const Ray& ray) const {
	RayCastTemp rct;
	switch (this->RayCast_(ray, rct)) {
		case RHO__fail: {
			return false;
		}

		case RHO__co: {
			Vec point;
			rct.proj_eff_ray.point(point, rct.t[0]);

			if (this->domain_->Contain(point)) {
				auto rcd(New<RayCastDataCore_>());
				rcd->domain = this;
				rcd->t = rct.t[0];
				rcd->phase.set(false, false);
				dst.Push(rcd);
			}

			return false;
		}

		case RHO__tan: return this->domain_->RayCastFull(dst, rct.proj_eff_ray);
	}

	RayCastDataVector rcdv;
	bool phase(this->domain_->RayCastFull(rcdv, rct.proj_eff_ray));

	if (rcdv.empty()) {
		if (phase) { RHO__F; }
		return false;
	}

	bool rcdv_fr(rcdv[0]->phase.fr());

	while (rct.t[1] < rcdv.back()->t) {
		rcdv.Pop();
		if (rcdv.empty()) {
			if (rcdv_fr) { RHO__F; }
			return false;
		}
	}

	bool rcdv_to(rcdv.back()->phase.to());

	size_t i(0);

	while (rcdv[i]->t < rct.t[0]) {
		++i;

		if (i == rcdv.size()) {
			if (rcdv_to) { RHO__F; }
			return false;
		}
	}

	if (rct.t[0] == rcdv[i]->t) {
		auto rcd(New<RayCastDataCore_>());
		rcd->domain = this;
		rcd->t = rct.t[0];
		rcd->phase = rcdv[i]->phase;
		rcd->rcd = Move(rcdv[i]);
		dst.Push(rcd);

		++i;
		if (i == rcdv.size()) { return false; }
	} else if (rcdv[i]->phase.fr()) {
		auto rcd(New<RayCastDataCore_>());
		rcd->domain = this;
		rcd->t = rct.t[0];
		rcd->phase.set(false, true);
		dst.Push(rcd);
	}

	while (rcdv[i] < rct.t[1]) {
		auto rcd(New<RayCastDataCore_>());
		rcd->domain = this;
		rcd->t = rcdv[i]->t;
		rcd->rcd = Move(rcdv[i]);

		dst.Push(rcd);

		++i;

		if (i == rcdv.size()) {
			if (rcdv_to) {
				auto rcd(New<RayCastDataCore_>());
				rcd->domain = this;
				rcd->t = rct.t[1];

				dst.Push(rcd);
			}

			return false;
		}
	}

	// when here is executed, indicate the i != rcdv.size()
	// we have eliminated rcdv[i]->t > rct.t[1] begining
	// and also rcdv[i]-t < rct.t[1] above
	// => rcdv[i]->t == rct.t[1]

	auto rcd(New<RayCastDataCore_>());
	rcd->domain = this;
	rcd->t = rct.t[1];
	rcd->rcd = Move(rcdv[i]);

	dst.Push(rcd);

	return false;
}

int DomainStretch::RayCast_(const Ray& ray, RayCastTemp& rct) const {
	rct.t[0] = 0;
	rct.t[1] = RHO__inf;

	this->ref_->MapPointFromRoot_rr(rct.ref_origin, ray.origin);
	this->ref_->MapVectorFromRoot_rr(rct.ref_direct, ray.direct);

	dim_t ref_dim(this->ref_->dim_s());
	dim_t eff_dim(this->eff_->dim_s());

#///////////////////////////////////////////////////////////////////////////////

	for (dim_t i(ref_dim); i != this->dim_r(); ++i) {
		if (rct.ref_direct[i].eq<0>()) {
			if (rct.ref_origin[i].eq<0>()) { continue; }
			return false;
		}

		Num t(-rct.ref_origin[i] / rct.ref_direct[i]);
		if (t < rct.t[0] || rct.t[1] < t) { return RHO__fail; }
		rct.t[0] = rct.t[1] = t;
	}

	if (rct.t[0].eq<0>() && rct.t[1].eq<0>()) { return RHO__fail; }
	if (rct.t[0] == rct.t[1]) { return RHO__co; }

	if (rct.ref_direct[eff_dim].eq<0>()) {
		if (rct.ref_origin[eff_dim].lt<0>() ||
			rct.ref_origin[eff_dim].gt<1>()) {
			return RHO__fail;
		}

		return RHO__tan;
	}

	{
		Num t[]{ -rct.ref_origin[eff_dim] / rct.ref_direct[eff_dim],
				 (1 - rct.ref_origin[eff_dim]) / rct.ref_direct[eff_dim] };

		if (t[1] < t[0]) { Swap(t[0], t[1]); }
		if (t[1] < rct.t[0] || rct.t[1] < t[0]) { return RHO__fail; }
		if (rct.t[0] < t[0]) { rct.t[0] = t[0]; }
		if (t[1] < rct.t[1]) { rct.t[1] = t[1]; }
	}

	this->eff_->MapPointToRoot_sr(rct.proj_eff_ray.origin, rct.ref_origin);
	this->eff_->MapVectorToRoot_sr(rct.proj_eff_ray.direct, rct.ref_direct);

	return RHO__nm;
}

#///////////////////////////////////////////////////////////////////////////////

void DomainStretch::GetTodTan(Num* dst, const RayCastData& rcd,
							  const Num* root_direct) const {
	RHO__debug_if(this != rcd->domain) RHO__throw__local("domain error");

	RayCastData& a(rcd.Get<RayCastDataCore_*>()->rcd);

	if (a) {
		Vec temp;
		a->domain->GetTodTan(temp, a, root_direct);
		dot(this->ref_->dim_r(), this->ref_->dim_r(), dst, temp,
			this->ref_todm_);
	} else {
		dot(this->ref_->dim_r(), this->ref_->dim_r(), dst, root_direct,
			this->eff_todm_);
	}
}

#///////////////////////////////////////////////////////////////////////////////

size_t DomainStretch::Complexity() const {
	return this->domain_->Complexity() + 100;
}

}