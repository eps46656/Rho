#include "define.cuh"
#include "DomainStretch.cuh"

#define RHO__throw__local(desc) RHO__throw(DomainStretch, __func__, desc)

#define RHO__fail 0
#define RHO__nm 1
#define RHO__tan 2
#define RHO__co 3

namespace rho {

Space* DomainStretch::ref() { return this->ref_; }
const Space* DomainStretch::ref() const { return this->ref_; }

Domain* DomainStretch::domain() { return this->domain_raw_; }
const Domain* DomainStretch::domain() const { return this->domain_raw_; }

const Space* DomainStretch::root() const { return this->root_; }

void DomainStretch::set_ref(Space* ref) { this->ref_ = ref; }
void DomainStretch::set_domain(Domain* domain) { this->domain_raw_ = domain; }

#///////////////////////////////////////////////////////////////////////////////

DomainStretch::DomainStretch(Space* ref, Domain* domain):
	ref_(ref), domain_raw_(domain), domain_(nullptr), eff_(nullptr) {}

#///////////////////////////////////////////////////////////////////////////////

const Domain* DomainStretch::Refresh() const {
	if (!this->ref_ || !this->domain_raw_ ||
		!(this->domain_ = this->domain_raw_->Refresh())) {
		return nullptr;
	}

	this->ref_->Refresh();

	RHO__debug_if((this->root_ = this->ref_->root()) != this->domain_->root()) {
		RHO__throw__local("root error");
	}

	if (!this->eff_) {
		this->eff_ = New<Space>(this->ref_->dim() - 1, this->ref_->root());
	}

	this->eff_->SetOrigin(this->ref_->root_origin());
	this->eff_->SetAxis(this->ref_->root_axis());
	this->eff_->Refresh();

	Tod::TanMatrix(this->ref_->dim(), this->ref_->root_dim(), this->ref_todm_,
				   this->ref_->root_axis());

	Tod::TanMatrix(this->eff_->dim(), this->eff_->root_dim(), this->eff_todm_,
				   this->eff_->root_axis());

	return this;
}

#///////////////////////////////////////////////////////////////////////////////

bool DomainStretch::Contain(const Num* root_point) const {
	Vec temp;
	this->ref_->MapPointFromRoot_rr(temp, root_point);

	if (temp[this->eff_->dim()].lt<0>() || temp[this->eff_->dim()].gt<1>()) {
		return false;
	}

	for (dim_t i(this->ref_->dim()); i != this->ref_->root_dim(); ++i) {
		if (temp[i].ne<0>()) { return false; }
	}

	Vec temp_;
	this->eff_->MapPointToRoot_sr(temp_, temp);

	return this->domain_->Contain(temp_);
}

#///////////////////////////////////////////////////////////////////////////////

#define RHO__F                                                                 \
	{                                                                          \
		dst[size].domain = this;                                               \
                                                                               \
		if (rct.t[0].ne<0>()) {                                                \
			dst[size].t = rct.t[0];                                            \
			dst[size].phase.set(false, true);                                  \
		} else {                                                               \
			dst[size].t = rct.t[1];                                            \
			dst[size].phase.set(true, false);                                  \
		}                                                                      \
                                                                               \
		dst[size].spare[0] = reinterpret_cast<size_t>(nullptr);                \
                                                                               \
		if (++size == RHO__Domain__RayCastFull_max_rcd) {                      \
			return RHO__Domain__RayCastFull_max_rcd;                           \
		}                                                                      \
	}

size_t DomainStretch::RayCastComplexity() const {
	return this->domain_->RayCastComplexity() + 100;
}

size_t DomainStretch::RayCastFull(RayCastData* dst, const Ray& ray) const {
	RayCastTemp rct;
	switch (this->RayCast_(ray, rct)) {
		case RHO__fail: return 0;

		case RHO__co: {
			Vec point;
			rct.proj_eff_ray.point(point, rct.t[0]);

			if (!this->domain_->Contain(point)) { return 0; }

			dst[0].domain = this;
			dst[0].t = rct.t[0];
			dst[0].phase.set(false, false);
			dst[0].spare[0] = reinterpret_cast<size_t>(nullptr);

			return 1;
		}

		case RHO__tan: return this->domain_->RayCastFull(dst, rct.proj_eff_ray);
	}

	RayCastDataVector rcdv;
	size_t rcdv_size(this->domain_->RayCastFull(rcdv, rct.proj_eff_ray));

	switch (rcdv_size) {
		case 0: return 0;
		case RHO__Domain__RayCastFull_in_phase:
			return RHO__Domain__RayCastFull_in_phase;
	}

	bool rcdv_fr(rcdv[0].phase.fr());
	size_t size(0);

	while (rct.t[1] < rcdv[--rcdv_size].t) {
		if (rcdv_size == 0) {
			if (rcdv_fr) { RHO__F; }
			return size;
		}
	}

	bool rcdv_to(rcdv[rcdv_size].phase.to());
	++rcdv_size;

	size_t i(0);

	while (rcdv[i].t < rct.t[0]) {
		if (++i == rcdv_size) {
			if (rcdv_to) { RHO__F; }
			return size;
		}
	}

	if (rct.t[0] == rcdv[i].t) {
		dst[size].domain = this;
		dst[size].t = rct.t[0];
		dst[size].phase = rcdv[i].phase;
		dst[size].spare[0] =
			reinterpret_cast<size_t>(New<RayCastData>(rcdv[i]));

		if (++size == RHO__Domain__RayCastFull_max_rcd) {
			return RHO__Domain__RayCastFull_max_rcd;
		}

		if (++i == rcdv_size) { return size; }
	} else if (rcdv[i].phase.fr()) {
		dst[size].domain = this;
		dst[size].t = rct.t[0];
		dst[size].phase.set(false, true);
		dst[size].spare[0] = reinterpret_cast<size_t>(nullptr);

		if (++size == RHO__Domain__RayCastFull_max_rcd) {
			return RHO__Domain__RayCastFull_max_rcd;
		}
	}

	while (rcdv[i] < rct.t[1]) {
		dst[size].domain = this;
		dst[size].t = rcdv[i].t;
		dst[size].phase = rcdv[i].phase;
		dst[size].spare[0] =
			reinterpret_cast<size_t>(New<RayCastData>(rcdv[i]));

		if (++size == RHO__Domain__RayCastFull_max_rcd) {
			return RHO__Domain__RayCastFull_max_rcd;
		}

		if (++i == rcdv_size) {
			if (rcdv_to) {
				dst[size].domain = this;
				dst[size].t = rct.t[1];
				dst[size].phase.set(true, false);
				dst[size].spare[0] = reinterpret_cast<size_t>(nullptr);

				++size;
			}

			return size;
		}
	}

	// when here is executed, indicate i != rcdv_size
	// we have eliminated rcdv[i]->t > rct.t[1] begining
	// and also rcdv[i]-t < rct.t[1] above
	// => rcdv[i]->t == rct.t[1]

	dst[size].domain = this;
	dst[size].t = rct.t[1];
	dst[size].phase.set(true, false);
	dst[size].spare[0] = reinterpret_cast<size_t>(New<RayCastData>(rcdv[i]));

	return size + 1;
}

int DomainStretch::RayCast_(const Ray& ray, RayCastTemp& rct) const {
	rct.t[0] = 0;
	rct.t[1] = RHO__inf;

	this->ref_->MapPointFromRoot_rr(rct.ref_origin, ray.origin);
	this->ref_->MapVectorFromRoot_rr(rct.ref_direct, ray.direct);

	dim_t ref_dim(this->ref_->dim());
	dim_t eff_dim(this->eff_->dim());

#///////////////////////////////////////////////////////////////////////////////

	if (this->ref_->root_codim()) {
		dim_t i(ref_dim);

		do {
			if (rct.ref_direct[i].eq<0>()) {
				if (rct.ref_origin[i].eq<0>()) { continue; }
				return false;
			}

			Num t(-rct.ref_origin[i] / rct.ref_direct[i]);
			if (t < rct.t[0] || rct.t[1] < t) { return RHO__fail; }
			rct.t[0] = rct.t[1] = t;
		} while (++i != this->ref_->root_dim());

		if (rct.t[0].eq<0>() && rct.t[1].eq<0>()) { return RHO__fail; }
		if (rct.t[0] == rct.t[1]) { return RHO__co; }
	}

	if (rct.ref_direct[eff_dim].eq<0>()) {
		if (rct.ref_origin[eff_dim].lt<0>() ||
			rct.ref_origin[eff_dim].gt<1>()) {
			return RHO__fail;
		}

		return RHO__tan;
	}

	Num t[]{ -rct.ref_origin[eff_dim] / rct.ref_direct[eff_dim],
			 (1 - rct.ref_origin[eff_dim]) / rct.ref_direct[eff_dim] };

	if (t[1] < t[0]) { Swap(t[0], t[1]); }
	if (t[1] < rct.t[0] || rct.t[1] < t[0]) { return RHO__fail; }
	if (rct.t[0] < t[0]) { rct.t[0] = t[0]; }
	if (t[1] < rct.t[1]) { rct.t[1] = t[1]; }

	this->eff_->MapPointToRoot_sr(rct.proj_eff_ray.origin, rct.ref_origin);
	this->eff_->MapVectorToRoot_sr(rct.proj_eff_ray.direct, rct.ref_direct);

	return RHO__nm;
}

void DomainStretch::RayCastDataDeleter(RayCastData& rcd) const {
	Delete(reinterpret_cast<RayCastData*>(rcd.spare[0]));
}

#///////////////////////////////////////////////////////////////////////////////

void DomainStretch::GetTodTan(Num* dst, const RayCastData& rcd,
							  const Num* root_direct) const {
	RHO__debug_if(this != rcd.domain) { RHO__throw__local("domain error"); }

	RayCastData* a(reinterpret_cast<RayCastData*>(rcd.spare[0]));

	if (a) {
		Vec temp;
		a->domain->GetTodTan(temp, *a, root_direct);
		dot(this->ref_->root_dim(), this->ref_->root_dim(), dst, temp,
			this->ref_todm_);
	} else {
		dot(this->ref_->root_dim(), this->ref_->root_dim(), dst, root_direct,
			this->eff_todm_);
	}
}

}