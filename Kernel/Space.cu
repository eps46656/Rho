#include "define.cuh"
#include "Kernel.cuh"

#define RHO__throw__local(desc) RHO__throw(Space, __func__, desc)

#define RHO_ParentCheck                                                        \
	RHO__debug_if(!this->parent_) { RHO__throw__local("parent error"); }

#define RHO__BranchCheck(branch)                                               \
	RHO__debug_if(this->root_ != branch->root_) {                              \
		RHO__throw__local("branch error");                                     \
	}

#define RHO__SetOriginAxisCheck                                                \
	RHO__debug_if(!this->parent_) {                                            \
		RHO__throw__local(("Space a root space, can not "                      \
						   "be set origin or axis."));                         \
	}

#define RHO__dim_check(x, y)                                                   \
	RHO__debug_if((x) != (y)) { RHO__throw__local("dim error"); }

#define RHO__dim_check2(x1, y1, x2, y2)                                        \
	RHO__debug_if((x1) != (y1) || (x2) != (y2)) {                              \
		RHO__throw__local("dim error");                                        \
	}

namespace rho {

dim_t Space::dim() const { return this->dim_; }
dim_t Space::parent_dim() const { return this->parent_dim_; }
dim_t Space::root_dim() const { return this->root_dim_; }
dim_t Space::parent_codim() const { return this->parent_codim_; }
dim_t Space::root_codim() const { return this->root_codim_; }

#///////////////////////////////////////////////////////////////////////////////

const Space* Space::root() const { return this->root_; }
const Space* Space::parent() const { return this->parent_; }

size_t Space::depth() const { return this->depth_; }

bool Space::is_root() const { return !this->parent_; }

#///////////////////////////////////////////////////////////////////////////////

const Num* Space::origin() const { return this->origin_; }
const Num* Space::axis() const { return this->axis_; }

const Num* Space::root_origin() const { return this->root_origin_; }
const Num* Space::root_axis() const { return this->root_axis_; }

const Num* Space::i_origin() const { return this->i_origin_; }
const Num* Space::i_axis() const { return this->i_axis_; }

const Num* Space::i_root_origin() const { return this->i_root_origin_; }
const Num* Space::i_root_axis() const { return this->i_root_axis_; }

#///////////////////////////////////////////////////////////////////////////////

bool Space::latest_arch() const {
	for (const Space* s(this); s; s = s->parent_) {
		if (!s->latest_arch_) {
			return this->latest_arch_ = this->latest_ = false;
		}
	}

	return true;
}

bool Space::latest() const {
	for (const Space* s(this); s; s = s->parent_) {
		if (!s->latest_) { return this->latest_ = false; }
	}

	return true;
}

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

Space::Space(dim_t dim, const Space* parent):
	dim_(dim), parent_(parent), parent_dim_(parent ? parent->dim_ : dim),
	parent_codim_(this->parent_dim_ - this->dim_), latest_arch_(false),
	latest_(false) {}

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#/////////////////////////////////////////////////////////////////////

#define RHO__args Num *dst, const Num *src

#define RHO__F(x, y)                                                           \
	RHO_ParentCheck;                                                           \
	dot(this->x##dim_, this->y##dim_, dst, src, this->axis_);                  \
	for (dim_t i(0); i != this->y##dim_; ++i) { dst[i] += this->origin_[i]; }

void Space::MapPointToParent_sp(RHO__args) const { RHO__F(, parent_); }
void Space::MapPointToParent_sr(RHO__args) const { RHO__F(, root_); }
void Space::MapPointToParent_rp(RHO__args) const { RHO__F(root_, parent_); }
void Space::MapPointToParent_rr(RHO__args) const { RHO__F(root_, root_); }

#undef RHO__F

#define RHO__F(x, y)                                                           \
	RHO_ParentCheck;                                                           \
	dot(this->x##dim_, this->y##dim_, dst, src, this->axis_);

void Space::MapVectorToParent_sp(RHO__args) const { RHO__F(, parent_); }
void Space::MapVectorToParent_sr(RHO__args) const { RHO__F(, root_); }
void Space::MapVectorToParent_rp(RHO__args) const { RHO__F(root_, parent_); }
void Space::MapVectorToParent_rr(RHO__args) const { RHO__F(root_, root_); }

#undef RHO__F

#///////////////////////////////////////////////////////////////////////////////

#define RHO__F(x, y)                                                           \
	RHO_ParentCheck;                                                           \
	dot(this->x##dim_, this->y##dim_, dst, src, this->i_axis_);                \
	for (dim_t i(0); i != this->y##dim_; ++i) { dst[i] -= this->i_origin_[i]; }

void Space::MapPointFromParent_ps(RHO__args) const { RHO__F(parent_, ); }
void Space::MapPointFromParent_rs(RHO__args) const { RHO__F(root_, ); }
void Space::MapPointFromParent_pr(RHO__args) const { RHO__F(parent_, root_); }
void Space::MapPointFromParent_rr(RHO__args) const { RHO__F(root_, root_); }

#undef RHO__F

#define RHO__F(x, y)                                                           \
	RHO_ParentCheck;                                                           \
	dot(this->x##dim_, this->y##dim_, dst, src, this->i_axis_);

void Space::MapVectorFromParent_ps(RHO__args) const { RHO__F(parent_, ); }
void Space::MapVectorFromParent_rs(RHO__args) const { RHO__F(root_, ); }
void Space::MapVectorFromParent_pr(RHO__args) const { RHO__F(parent_, root_); }
void Space::MapVectorFromParent_rr(RHO__args) const { RHO__F(root_, root_); }

#undef RHO__F

#///////////////////////////////////////////////////////////////////////////////

#define RHO__F(x)                                                              \
	dot(this->x##dim_, this->root_dim_, dst, src, this->root_axis_);           \
	for (dim_t i(0); i != this->root_dim_; ++i) {                              \
		dst[i] += this->root_origin_[i];                                       \
	}

void Space::MapPointToRoot_sr(RHO__args) const { RHO__F(); }
void Space::MapPointToRoot_rr(RHO__args) const { RHO__F(root_); }

#undef RHO__F

#define RHO__F(x)                                                              \
	dot(this->x##dim_, this->root_dim_, dst, src, this->root_axis_);

void Space::MapVectorToRoot_sr(RHO__args) const { RHO__F(); }
void Space::MapVectorToRoot_rr(RHO__args) const { RHO__F(root_); }

#undef RHO__F

#///////////////////////////////////////////////////////////////////////////////

#define RHO__F(x)                                                              \
	dot(this->root_dim_, this->x##dim_, dst, src, this->i_root_axis_);         \
	for (dim_t i(0); i != this->x##dim_; ++i) {                                \
		dst[i] -= this->i_root_origin_[i];                                     \
	}

void Space::MapPointFromRoot_rs(RHO__args) const { RHO__F(); }
void Space::MapPointFromRoot_rr(RHO__args) const { RHO__F(root_); }

#undef RHO__F

#define RHO__F(x)                                                              \
	dot(this->root_dim_, this->x##dim_, dst, src, this->i_root_axis_);

void Space::MapVectorFromRoot_rs(RHO__args) const { RHO__F(); }
void Space::MapVectorFromRoot_rr(RHO__args) const { RHO__F(root_); }

#undef RHO__F
#undef RHO__args

#///////////////////////////////////////////////////////////////////////////////

#define RHO__args Num *dst, const Num *src, const Space *branch

#define RHO__F(x, y)                                                           \
	RHO__debug_if(this->root_ != branch->root_) {                              \
		RHO__throw__local("root error");                                       \
	}                                                                          \
	Vec temp;                                                                  \
	this->MapPointToRoot_##x##r(temp, src);                                    \
	branch->MapPointFromRoot_r##y(dst, temp);

void Space::MapPointToBranch_sb(RHO__args) const { RHO__F(s, s) }
void Space::MapPointToBranch_sr(RHO__args) const { RHO__F(s, r) }
void Space::MapPointToBranch_rb(RHO__args) const { RHO__F(r, s) }
void Space::MapPointToBranch_rr(RHO__args) const { RHO__F(r, r) }

#undef RHO__F

#define RHO__F(x, y)                                                           \
	RHO__debug_if(this->root_ != branch->root_) {                              \
		RHO__throw__local("root error");                                       \
	}                                                                          \
	Vec temp;                                                                  \
	this->MapVectorToRoot_##x##r(temp, src);                                   \
	branch->MapVectorFromRoot_r##y(dst, temp);

void Space::MapVectorToBranch_sb(RHO__args) const { RHO__F(s, s); }
void Space::MapVectorToBranch_sr(RHO__args) const { RHO__F(s, r); }
void Space::MapVectorToBranch_rb(RHO__args) const { RHO__F(r, s); }
void Space::MapVectorToBranch_rr(RHO__args) const { RHO__F(r, r); }

#undef RHO__F

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

bool Space::IncludePointFromRoot_r(const Num* src) const {
	if (!this->root_codim_) { return true; }

	Vec temp;

	dot(this->root_dim_, this->root_codim_, temp, src,
		this->i_root_axis_ + this->dim_);

	return Equal(this->root_codim_, temp, this->i_root_origin_ + this->dim_);
}

bool Space::IncludeVectorFromRoot_r(const Num* src) const {
	if (!this->root_codim_) { return true; }

	Vec temp;

	dot(this->root_dim_, this->root_codim_, temp, src,
		this->i_root_axis_ + this->dim_);

	for (dim_t i(0); i != this->root_codim_; ++i) {
		if (temp[i].ne<0>()) { return false; }
	}

	return true;
}

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

bool Space::Overlap(const Space* branch) const {
	RHO__debug_if(this->root_ != branch->root_) {
		RHO__throw__local("root error");
	}

	return this->dim_ == branch->dim_ && this->Include_(branch);
}

bool Space::Include(const Space* branch) const {
	RHO__debug_if(this->root_ != branch->root_) {
		RHO__throw__local("root error");
	}

	return branch->dim_ <= this->dim_ && this->Include_(branch);
}

bool Space::Include_(const Space* branch) const {
	if (!this->IncludePointFromRoot_r(branch->root_origin_)) { return false; }

	for (dim_t i(0); i != branch->dim_; ++i) {
		if (!this->IncludeVectorFromRoot_r(branch->root_axis_ +
										   RHO__max_dim * i)) {
			return false;
		}
	}

	return true;
}

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

void Space::SetLatestFalse() const { this->latest_ = false; }

Space* Space::SetDim(dim_t dim) {
	if (this->dim_ != dim) {
		RHO__debug_if(RHO__max_dim < dim) { RHO__throw__local("dim error"); }

		this->dim_ = dim;
		this->latest_arch_ = this->latest_ = false;
	}

	return this;
}

Space* Space::SetParent(const Space* parent) {
	if (this->parent_ == parent) { return this; }

#if RHO__debug_flag

	if (parent && this->root_ == parent->root_ &&
		this->depth_ < parent->depth_) {
		for (const Space* s(parent); s; s = s->parent_) {
			if (s == this) { RHO__throw__local("arch error"); }
		}
	}

#endif

	this->parent_ = parent;
	this->latest_arch_ = this->latest_ = false;

	return this;
}

#///////////////////////////////////////////////////////////////////////////////

Space* Space::SetOrigin(const Num* origin) {
	Vector::Copy(this->origin_, origin);
	this->latest_ = false;
	return this;
}

Space* Space::SetAxis(const Num* axis) {
	Matrix::Copy(this->axis_, axis);
	this->latest_ = false;
	return this;
}

Space* Space::SetOrigin(const Vector& origin) {
	RHO__dim_check(this->parent_dim_, origin.dim());
	return this->SetOrigin(&origin[0]);
}

Space* Space::SetAxis(const Matrix& axis) {
	RHO__dim_check(this->dim_, axis.col_dim());
	RHO__dim_check(this->parent_dim_, axis.row_dim());
	return this->SetAxis(&axis[0]);
}

#///////////////////////////////////////////////////////////////////////////////

Space* Space::RefreshArch() {
	const Space* s(nullptr);
	const Space* i(this);

	for (const Space* j; j = i->parent_; i = j) {
		j->temp_ = i;
		if (!j->latest_arch_) { s = j; }
	}

	if (s) {
		for (; s != this; s = s->temp_) { s->RefreshArch_(); }
		this->RefreshArch_();
	}

	if (this->latest_arch_) { this->RefreshArch_(); }

	return this;
}

const Space* Space::RefreshArch() const {
	return const_cast<Space*>(this)->RefreshArch();
}

void Space::RefreshArch_() const {
	if (this->parent_) {
		this->root_ = this->parent_->root_;
		this->root_dim_ = this->parent_->root_dim_;
		this->root_codim_ = this->root_dim_ - this->dim_;
	} else {
		this->root_ = this;
		this->root_dim_ = this->dim_;
		this->root_codim_ = 0;
	}

	this->latest_arch_ = true;
}

Space* Space::Refresh() {
	const Space* s(nullptr);
	const Space* t(nullptr);
	const Space* i(this);

	for (const Space* j; j = i->parent_; i = j) {
		j->temp_ = i;
		if (!j->latest_arch_) {
			s = t = j;
		} else if (!j->latest_) {
			s = j;
		}
	}

	if (s) {
		for (; s != t; s = s->temp_) { s->Refresh_(); }

		for (; s != this; s = s->temp_) {
			s->RefreshArch_();
			s->Refresh_();
		}

		this->RefreshArch_();
		this->Refresh_();
		return this;
	} else if (this->latest_arch_) {
		if (!this->latest_) { this->Refresh_(); }
	} else {
		this->RefreshArch_();
		this->Refresh_();
	}

	return this;
}

const Space* Space::Refresh() const {
	return const_cast<Space*>(this)->Refresh();
}

void Space::Refresh_() const {
	if (this->parent_) {
		for (dim_t i(this->parent_dim_); i != this->root_dim_; ++i) {
			this->origin_[i] = 0;
		}

		for (dim_t i(0); i != this->dim_; ++i) {
			for (dim_t j(this->parent_dim_); j != this->root_dim_; ++j) {
				this->axis_[RHO__max_dim * i + j] = 0;
			}
		}

		dot(this->parent_dim_, this->root_dim_, this->root_origin_,
			this->origin_, this->parent_->root_axis_);

#pragma unroll
		for (dim_t i(0); i != RHO__max_dim; ++i) {
			this->root_origin_[i] += this->parent_->root_origin_[i];
		}

		dot(this->dim_, this->parent_dim_, this->root_dim_, this->root_axis_,
			this->axis_, this->parent_->root_axis_);

#if RHO__debug_flag
		if (!Complement(this->dim_, this->root_dim_, this->root_axis_)) {
			RHO__throw__local("linear dependent error");
		}
#else
		Complement(this->dim_, this->root_dim_, this->root_axis_);
#endif

		inverse(this->root_dim_, this->i_root_axis_, this->root_axis_);

		dot(this->root_dim_, this->root_dim_, this->i_root_origin_,
			this->root_origin_, this->i_root_axis_);

		dot(this->root_codim_, this->root_dim_, this->root_dim_,
			this->axis_ + RHO__max_dim * this->dim_,
			this->root_axis_ + RHO__max_dim * this->dim_,
			this->parent_->i_root_axis_);
	} else {
		Fill<RHO__max_dim>(this->origin_, 0);
		Matrix::identity(this->axis_);

		Fill<RHO__max_dim>(this->root_origin_, 0);
		Matrix::identity(this->root_axis_);

		Fill<RHO__max_dim>(this->i_origin_, 0);
		Matrix::identity(this->i_axis_);

		Fill<RHO__max_dim>(this->i_root_origin_, 0);
		Matrix::identity(this->i_root_axis_);
	}

	this->latest_ = true;
}

}