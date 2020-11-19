#include "define.cuh"
#include "DomainParallelotope.cuh"

#define RHO__throw__local(desc) RHO__throw(DomainParallelotope, __func__, desc)

namespace rho {

DomainParallelotope::DomainParallelotope(Space* ref): DomainSole(ref) {}

#///////////////////////////////////////////////////////////////////////////////

const Domain* DomainParallelotope::Refresh() const {
	if (!this->ref_) { return nullptr; }

	this->ref_->Refresh();

	size_t flag(0);
	size_t flag_end(1);
	flag_end <<= this->ref_->dim();

	this->tod_matrix_.Resize(flag_end);

	Mat temp;

	for (; flag != flag_end; ++flag) {
		const Num* a_i(this->ref_->root_axis());
		Num* m_i(temp);

		for (size_t reader(1); reader != flag_end;
			 reader <<= 1, a_i += RHO__max_dim) {
			if (!(flag & reader)) {
				Vector::Copy(m_i, a_i);
				m_i += RHO__max_dim;
			}
		}

		Tod::TanMatrix((m_i - temp) / RHO__max_dim, this->ref_->root_dim(),
					   this->tod_matrix_[flag], temp);
	}

	return this;
}

#///////////////////////////////////////////////////////////////////////////////

bool DomainParallelotope::Contain_s(const Num* point) const {
	for (dim_t i(0); i != this->ref_->dim(); ++i) {
		if (point[i].lt<-1>() || point[i].gt<1>()) { return false; }
	}

	return true;
}

#///////////////////////////////////////////////////////////////////////////////

size_t DomainParallelotope::RayCastComplexity() const {
	return 10 * this->ref_->dim() + 5 * this->ref_->root_codim();
}

bool DomainParallelotope::RayCast(RayCastData& dst, const Ray& ray) const {
	RayCastTemp rct;

	if (this->RayCast_(ray, rct)) {
		if (rct.t[0].ne<0>()) {
			dst.domain = this;
			dst.t = rct.t[0];
			dst.phase.set(false, rct.t[0] != rct.t[1]);
			dst.spare[0] = rct.contain_flag[0];

			return true;
		}

		if (rct.t[1].ne<0>()) {
			dst.domain = this;
			dst.t = rct.t[1];
			dst.phase.set(true, false);
			dst.spare[0] = rct.contain_flag[1];

			return true;
		}
	}

	return false;
}

bool DomainParallelotope::RayCastB(const Ray& ray) const {
	RayCastTemp rct;
	if (!this->RayCast_(ray, rct)) { return false; }

	if (rct.t[0].eq<0>()) { return rct.t[1].ne<0>() && rct.t[1].lt<1>(); }

	return rct.t[0].lt<1>();
}

void DomainParallelotope::RayCastPair(RayCastDataPair& dst,
									  const Ray& ray) const {
	RayCastTemp rct;
	if (!this->RayCast_(ray, rct)) { return; }

	if (rct.t[0].ne<0>()) {
		if (dst[1] <= rct.t[0]) { return; }

		if (dst[0] <= rct.t[0]) {
			dst[1].Destroy();

			dst[1].domain = this;
			dst[1].t = rct.t[0];
			dst[1].phase.set(false, rct.t[0] != rct.t[1]);
			dst[1].spare[0] = rct.contain_flag[0];

			return;
		}

		dst[1] = dst[0];

		dst[0].domain = this;
		dst[0].t = rct.t[0];
		dst[0].phase.set(false, rct.t[0] != rct.t[1]);
		dst[0].spare[0] = rct.contain_flag[0];
	}

	if (rct.t[0] == rct.t[1] || dst[1] <= rct.t[1]) { return; }

	dst[1].Destroy();

	dst[1].domain = this;
	dst[1].t = rct.t[0];
	dst[1].phase.set(true, false);
	dst[1].spare[0] = rct.contain_flag[0];
}

size_t DomainParallelotope::RayCastFull(RayCastData* dst,
										const Ray& ray) const {
	RayCastTemp rct;
	if (!this->RayCast_(ray, rct)) { return 0; }

	size_t size(0);

	if (rct.t[0].ne<0>()) {
		dst[size].domain = this;
		dst[size].t = rct.t[0];
		dst[size].phase.set(false, rct.t[0] != rct.t[1]);
		dst[size].spare[0] = rct.contain_flag[0];

		++size;
	}

	if (rct.t[0] != rct.t[1]) {
		dst[size].domain = this;
		dst[size].t = rct.t[1];
		dst[size].phase.set(true, false);
		dst[size].spare[0] = rct.contain_flag[1];

		++size;
	}

	return size;
}

bool DomainParallelotope::RayCast_(const Ray& ray, RayCastTemp& rct) const {
	rct.t[0] = 0;
	rct.t[1] = RHO__inf;
	rct.contain_flag[0] = rct.contain_flag[1] = 0;

	Vec origin;
	Vec direct;

	this->ref_->MapPointFromRoot_rr(origin, ray.origin);
	this->ref_->MapVectorFromRoot_rr(direct, ray.direct);

#///////////////////////////////////////////////////////////////////////////////

	if (this->ref_->root_codim() != 0) {
		dim_t i(this->ref_->dim());
		do {
			if (direct[i].eq<0>()) {
				if (origin[i].eq<0>()) { continue; }
				return false;
			}

			Num t(-origin[i] / direct[i]);
			if (t < rct.t[0] || rct.t[1] < t) { return false; }
			rct.t[0] = rct.t[1] = t;
		} while (++i != this->ref_->root_dim());
	}

#///////////////////////////////////////////////////////////////////////////////

	for (dim_t i(0); i != this->ref_->dim(); ++i) {
		if (direct[i].eq<0>()) {
			if (origin[i].lt<-1>() || origin[i].gt<1>()) { return false; }
			continue;
		}

		Num t[]{ (-1 - origin[i]) / direct[i], (1 - origin[i]) / direct[i] };

		if (t[1] < t[0]) { Swap(t[0], t[1]); }
		if (t[1] < rct.t[0] || rct.t[1] < t[0]) { return false; }

		if (rct.t[0] < t[0]) {
			rct.t[0] = t[0];
			rct.contain_flag[0] = size_t(1) << i;
		} else if (rct.t[0] == t[0]) {
			rct.contain_flag[0] |= size_t(1) << i;
		}

		if (t[1] < rct.t[1]) {
			rct.t[1] = t[1];
			rct.contain_flag[1] = size_t(1) << i;
		} else if (t[1] == rct.t[1]) {
			rct.contain_flag[1] |= size_t(1) << i;
		}
	}

	return true;
}

#///////////////////////////////////////////////////////////////////////////////

void DomainParallelotope::GetTodTan(Num* dst, const RayCastData& rcd,
									const Num* root_direct) const {
	dot(this->root_dim(), this->root_dim(), dst, root_direct,
		this->tod_matrix_[rcd.spare[0]]);
}

}