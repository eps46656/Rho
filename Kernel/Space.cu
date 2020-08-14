#include "define.cuh"
#include "Kernel.cuh"

#define RHO__throw__local(desc) RHO__throw(Space, __func__, desc)

#define RHO_ParentCheck                                                        \
	RHO__debug_if(!this->parent_)                                              \
		RHO__throw__local("Space " << this->id_ << " parent space error");

#define RHO__BranchCheck(branch)                                               \
	RHO__debug_if(this->root_ != branch->root_)                                \
		RHO__throw__local("Space " << branch->id_ << " is not a branch of "    \
								   << this->root_->id << ".");

#define RHO__SetOriginAxisCheck                                                \
	RHO__debug_if(!this->parent_) RHO__throw__local(                           \
		("Space " << this->id_                                                 \
				  << ", a root space, can not be set origin or axis."));

#define RHO__dim_check(x, y)                                                   \
	RHO__debug_if((x) != (y)) RHO__throw__local("dim error");

#define RHO__dim_check2(x1, y1, x2, y2)                                        \
	RHO__debug_if((x1) != (y1) || (x2) != (y2)) RHO__throw__local("dim "       \
																  "error");

namespace rho {

bool Space::latest() const {
	for (const Space* s(this); s; s = s->parent_) {
		if (!s->latest_) { return false; }
	}

	return true;
}

bool Space::is_root() const { return !this->parent_; }

#////////////////////////////////////////////////

Manager* Space::manager() { return this->manager_; }
const Manager* Space::manager() const { return this->manager_; }

Space* Space::root() { return this->root_; }
const Space* Space::root() const { return this->root_; }

Space* Space::parent() { return this->parent_; }
const Space* Space::parent() const { return this->parent_; }

const cntr::Vector<Space*>& Space::child() { return this->child_; }
const cntr::Vector<const Space*>& Space::child() const {
	return this->child_const_;
}

size_t Space::depth() const { return this->depth_; }

#////////////////////////////////////////////////

RHO__cuda const Num* Space::origin() const { return this->origin_; }
RHO__cuda const Num* Space::axis() const { return this->axis_; }

RHO__cuda const Num* Space::root_origin() const { return this->root_origin_; }
RHO__cuda const Num* Space::root_axis() const { return this->root_axis_; }

RHO__cuda const Num* Space::i_origin() const { return this->i_origin_; }
RHO__cuda const Num* Space::i_axis() const { return this->i_axis_; }

RHO__cuda const Num* Space::i_root_origin() const {
	return this->i_root_origin_;
}
RHO__cuda const Num* Space::i_root_axis() const { return this->i_root_axis_; }

#////////////////////////////////////////////////
#////////////////////////////////////////////////
#////////////////////////////////////////////////

dim_t Space::dim_s() const { return this->dim_s_; }
dim_t Space::dim_p() const { return this->dim_p_; }
dim_t Space::dim_r() const { return this->dim_r_; }
dim_t Space::dim_cp() const { return this->dim_cp_; }
dim_t Space::dim_cr() const { return this->dim_cr_; }

#////////////////////////////////////////////////

Space::Space(dim_t dim):
	latest_(false),

	manager_(new Manager(this)), root_(this), parent_(nullptr),

	depth_(0),

	dim_s_(dim), dim_p_(dim), dim_r_(dim), dim_cp_(0), dim_cr_(0) {
	RHO__debug_if(RHO__max_dim < dim) RHO__throw__local("dim error");
}

Space::Space(dim_t dim, Space* parent):
	latest_(false),

	manager_(parent->manager_), root_(parent->root_), parent_(parent),

	depth_(parent->depth_ + 1),

	dim_s_(dim), dim_p_(parent->dim_s_), dim_r_(parent->dim_r_),
	dim_cp_(this->dim_p_ - this->dim_s_), dim_cr_(this->dim_r_ - this->dim_s_) {
	RHO__debug_if(RHO__max_dim < dim) { RHO__throw__local("dim error"); }

	this->manager_->AddSpace_(this);

	this->manager_->space_.Insert(this);

	this->parent_->child_.Push(this);
}

#////////////////////////////////////////////////

void Space::Check() const {}

void Space::Refresh() const {
	RHO__throw__local("do not call this func\n");

	/*cntr::Vector<const Space*> stack;

	if (!this->latest_) {
		stack.Reserve(this->child_const_.size() < this->depth_ ?
					  this->depth_ : this->child_const_.size());
		stack.Push(this);

		for (auto i(this->parent_); i && !i->latest_; i = i->parent_)
			stack.Push(i);

		for (size_t i(stack.size() - 1); i; --i)
			stack[i]->RefreshMain_();

		this->RefreshMain_();
	}

	stack = this->child_const_;

	while (stack.size()) {
		const Space* space(stack.back());
		stack.Pop();
		stack.Insert(stack.end(),
					 space->child_const_.begin(),
					 space->child_const_.end());
		space->RefreshMain_();
	}*/

	this->RefreshSelf();
	this->RefreshDescendant_();
}

bool Space::RefreshSelf() const {
	/*cntr::Vector<const Space*> s(this->depth_ + 1);

	Space* a(this->parent_);

	for (size_t i(s.size() - 1); i; --i, a = a->parent_)
		s[i - 1] = a;

	s.back() = this;

	for (size_t i(0); i != s.size(); ++i) {
		if (s[i]->latest_) { continue; }

		for (; i != s.size(); ++i) {
			if (!s[i]->RefreshMain_()) { return false; }
		}

		return this->RefreshMain_();
	}

	return true;*/

	cntr::Vector<const Space*> s(this->depth_ + 1);

	const Space* a(this);
	size_t j(s.size());

	for (size_t i(s.size()); i; --i, a = a->parent_) {
		if (!((s[i - 1] = a)->latest_)) { j = i - 1; }
	}

	for (; j != s.size(); ++j) {
		if (!s[j]->RefreshMain_()) { return false; }
	}

	return true;
}

void Space::RefreshDescendant_() const {
	auto iter(this->child_.begin());

	for (auto end(this->child_.end()); iter != end; ++iter) {
		(*iter)->RefreshMain_();
		(*iter)->RefreshDescendant_();
	}
}

bool Space::RefreshMain_() const {
	this->Check();

	this->latest_ = true;

	if (this->parent_) {
		for (dim_t i(this->dim_p_); i != this->dim_r_; ++i) {
			this->origin_[i] = 0;
		}

		for (dim_t i(0); i != this->dim_s_; ++i) {
			for (dim_t j(this->dim_p_); j != this->dim_r_; ++j) {
				this->axis_[RHO__max_dim * i + j] = 0;
			}
		}

		dot(this->dim_p_, this->dim_r_, this->root_origin_, this->origin_,
			this->parent_->root_axis_);

#pragma unroll
		for (dim_t i(0); i != RHO__max_dim; ++i)
			this->root_origin_[i] += this->parent_->root_origin_[i];

		dot(this->dim_s_, this->dim_p_, this->dim_r_, this->root_axis_,
			this->axis_, this->parent_->root_axis_);

		if (!Complement(this->dim_s_, this->dim_r_, this->root_axis_))
			return false;

		inverse(this->dim_r_, this->i_root_axis_, this->root_axis_);

		dot(this->dim_r_, this->dim_r_, this->i_root_origin_,
			this->root_origin_, this->i_root_axis_);

		dot(this->dim_cr_, this->dim_r_, this->dim_r_,
			this->axis_ + RHO__max_dim * this->dim_s_,
			this->root_axis_ + RHO__max_dim * this->dim_s_,
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

	return true;
}

#///////////////////////////////////////////////////////////////////////////////

void Space::SetLatestFalse_() {
	this->latest_ = false;

	auto iter(this->child_.begin());

	for (auto end(this->child_.end()); iter != end; ++iter)
		(*iter)->SetLatestFalse_();
}

#///////////////////////////////////////////////////////////////////////////////

void Space::Delete() {
	this->parent_->child_.Erase(LinearSearch(
		this->parent_->child_.begin(), this->parent_->child_.end(), this));

	cntr::Vector<Space*> stack(this->child_);

	while (stack.size()) {
		Space* space(stack.back());
		stack.Pop();
		stack.Insert(stack.end(), space->child_.begin(), space->child_.end());

		this->manager_->DeleteSpace_(this);
		rho::Delete(space);
	}
}
/*
void Space::Delete_() {
	instance_().Erase(instance_().Find(this));

	auto iter(this->child_.begin());

	for (auto end(this->child_.end()); iter != end; ++iter)
		(*iter)->Delete();

	this->manager_->DeleteSpace_(this);
	rho::Delete(this);
}*/

#////////////////////////////////////////////////

Space* Space::set_origin(const Num* origin) {
	Copy<RHO__max_dim>(this->origin_, origin);
	this->latest_ = false;
	return this;
}

Space* Space::set_axis(const Num* axis) {
	Copy<RHO__max_dim_sq>(this->axis_, axis);
	this->latest_ = false;
	return this;
}

Space* Space::set_origin(const Vector& origin) {
	RHO__dim_check(this->dim_p_, origin.dim());
	return this->set_origin(&origin[0]);
}

Space* Space::set_axis(const Matrix& axis) {
	RHO__dim_check(this->dim_s_, axis.col_dim());
	RHO__dim_check(this->dim_p_, axis.row_dim());
	return this->set_axis(&axis[0]);
}

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

#define RHO__args Num *dst, const Num *src

#define RHO__F(x, y)                                                           \
	RHO_ParentCheck;                                                           \
	dot(this->dim_##x##_, this->dim_##y##_, dst, src, this->axis_);            \
	for (dim_t i(0); i != this->dim_##y##_; ++i) { dst[i] += this->origin_[i]; }

void Space::MapPointToParent_sp(RHO__args) const { RHO__F(s, p) }
void Space::MapPointToParent_sr(RHO__args) const { RHO__F(s, r) }
void Space::MapPointToParent_rp(RHO__args) const { RHO__F(r, p) }
void Space::MapPointToParent_rr(RHO__args) const { RHO__F(r, r) }

#undef RHO__F

#define RHO__F(x, y)                                                           \
	RHO_ParentCheck;                                                           \
	dot(this->dim_##x##_, dim_##y##_, dst, src, this->axis_);

void Space::MapVectorToParent_sp(RHO__args) const { RHO__F(s, p) }
void Space::MapVectorToParent_sr(RHO__args) const { RHO__F(s, r) }
void Space::MapVectorToParent_rp(RHO__args) const { RHO__F(r, p) }
void Space::MapVectorToParent_rr(RHO__args) const { RHO__F(r, r) }

#undef RHO__F

#///////////////////////////////////////////////////////////////////////////////

#define RHO__F(x, y)                                                           \
	RHO_ParentCheck;                                                           \
	dot(this->dim_##x##_, this->dim_##y##_, dst, src, this->i_axis_);          \
	for (dim_t i(0); i != this->dim_##y##_; ++i) {                             \
		dst[i] -= this->i_origin_[i];                                          \
	}

void Space::MapPointFromParent_ps(RHO__args) const { RHO__F(p, s) }
void Space::MapPointFromParent_rs(RHO__args) const { RHO__F(r, s) }
void Space::MapPointFromParent_pr(RHO__args) const { RHO__F(p, r) }
void Space::MapPointFromParent_rr(RHO__args) const { RHO__F(r, r) }

#undef RHO__F

#define RHO__F(x, y)                                                           \
	RHO_ParentCheck;                                                           \
	dot(this->dim_##x##_, this->dim_##y##_, dst, src, this->i_axis_);

void Space::MapVectorFromParent_ps(RHO__args) const { RHO__F(p, s) }
void Space::MapVectorFromParent_rs(RHO__args) const { RHO__F(r, s) }
void Space::MapVectorFromParent_pr(RHO__args) const { RHO__F(p, r) }
void Space::MapVectorFromParent_rr(RHO__args) const { RHO__F(r, r) }

#undef RHO__F

#///////////////////////////////////////////////////////////////////////////////

#define RHO__F(x, y)                                                           \
	dot(this->dim_##x##_, dim_##y##_, dst, src, this->root_axis_);             \
	for (size_t i(0); i != this->dim_##y##_; ++i)                              \
		dst[i] += this->root_origin_[i];

void Space::MapPointToRoot_sr(RHO__args) const { RHO__F(s, r) }
void Space::MapPointToRoot_rr(RHO__args) const { RHO__F(r, r) }

#undef RHO__F

#define RHO__F(x, y)                                                           \
	dot(this->dim_##x##_, this->dim_##y##_, dst, src, this->root_axis_);

void Space::MapVectorToRoot_sr(RHO__args) const { RHO__F(s, r) }
void Space::MapVectorToRoot_rr(RHO__args) const { RHO__F(r, r) }

#undef RHO__F

#///////////////////////////////////////////////////////////////////////////////

#define RHO__F(x, y)                                                           \
	dot(this->dim_##x##_, this->dim_##y##_, dst, src, this->i_root_axis_);     \
	for (size_t i(0); i != this->dim_##y##_; ++i)                              \
		dst[i] -= this->i_root_origin_[i];

void Space::MapPointFromRoot_rs(RHO__args) const { RHO__F(r, s) }
void Space::MapPointFromRoot_rr(RHO__args) const { RHO__F(r, r) }

#undef RHO__F

#define RHO__F(x, y)                                                           \
	dot(this->dim_##x##_, this->dim_##y##_, dst, src, this->i_root_axis_);

void Space::MapVectorFromRoot_rs(RHO__args) const {
	dot(this->dim_r_, this->dim_s_, dst, src, this->i_root_axis_);
}
void Space::MapVectorFromRoot_rr(RHO__args) const {
	dot(this->dim_r_, this->dim_r_, dst, src, this->i_root_axis_);
}

#undef RHO__F

#///////////////////////////////////////////////////////////////////////////////

#define RHO__F(x, y)                                                           \
	RHO__debug_if(this->root_ != branch->root_)                                \
		RHO__throw__local("root error");                                       \
	Vec temp;                                                            \
	this->MapPointToRoot_##x##r(temp, src);                                    \
	branch->MapPointFromRoot_r##y(dst, temp);

void Space::MapPointToBranch_sb(RHO__args, const Space* branch) const {
	RHO__F(s, s)
}
void Space::MapPointToBranch_sr(RHO__args, const Space* branch) const {
	RHO__F(s, r)
}
void Space::MapPointToBranch_rb(RHO__args, const Space* branch) const {
	RHO__F(r, s)
}
void Space::MapPointToBranch_rr(RHO__args, const Space* branch) const {
	RHO__F(r, r)
}

#undef RHO__F

#define RHO__F(x, y)                                                           \
	RHO__debug_if(this->root_ != branch->root_)                                \
		RHO__throw__local("root error");                                       \
	Vec temp;                                                            \
	this->MapVectorToRoot_##x##r(temp, src);                                   \
	branch->MapVectorFromRoot_r##y(dst, temp);

void Space::MapVectorToBranch_sb(RHO__args, const Space* branch) const {
	RHO__F(s, s)
}
void Space::MapVectorToBranch_sr(RHO__args, const Space* branch) const {
	RHO__F(s, r)
}
void Space::MapVectorToBranch_rb(RHO__args, const Space* branch) const {
	RHO__F(r, s)
}
void Space::MapVectorToBranch_rr(RHO__args, const Space* branch) const {
	RHO__F(r, r)
}

#undef RHO__F

#////////////////////////////////////////////////
#////////////////////////////////////////////////
#////////////////////////////////////////////////

bool Space::IncludePointFromRoot_r(const Num* src) const {
	if (!this->dim_cr_) { return true; }

	Vec temp;

	// dot(this->dim_r_, this->dim_cr_, temp, src, this->i_root_axis_rcr_);

	dot(this->dim_r_, this->dim_cr_, temp, src,
		this->i_root_axis_ + this->dim_s_);

	return Equal(this->dim_cr_, this->i_root_origin_ + this->dim_s_, temp);
}

bool Space::IncludeVectorFromRoot_r(const Num* src) const {
	if (!this->dim_cr_) { return true; }

	Vec temp;

	// dot(this->dim_r_, this->dim_cr_, temp, src, this->i_root_axis_rcr_);

	dot(this->dim_r_, this->dim_cr_, temp, src,
		this->i_root_axis_ + this->dim_s_);

	for (size_t i(0); i != this->dim_cr_; ++i) {
		if (temp[i].ne<0>()) { return false; }
	}

	return true;
}

#////////////////////////////////////////////////
#////////////////////////////////////////////////
#////////////////////////////////////////////////

bool Space::Overlap(const Space* branch) const {
	RHO__debug_if(this->root_ != branch->root_)
		RHO__throw__local("root space error");

	return this->dim_s_ == branch->dim_s_ && this->Include_(branch);
}

bool Space::Include(const Space* branch) const {
	RHO__debug_if(this->root_ != branch->root_)
		RHO__throw__local("root space error");

	return branch->dim_s_ <= this->dim_s_ && this->Include_(branch);
}

bool Space::Include_(const Space* branch) const {
	if (!this->IncludePointFromRoot_r(branch->root_origin_)) return false;

	for (size_t i(0); i != branch->dim_s_; ++i) {
		if (!this->IncludeVectorFromRoot_r(branch->root_axis_ +
										   this->dim_r_ * i)) {
			return false;
		}
	}

	return true;
}

#////////////////////////////////////////////////

void Space::AddChild_(Space* space) {
	this->child_.Push(space);
	this->child_const_.Push(space);
}

void Space::SubChild_(Space* space) {
	this->child_.Erase(
		LinearSearch(this->child_.begin(), this->child_.end(), space));
	this->child_const_.Erase(LinearSearch(this->child_const_.begin(),
										  this->child_const_.end(), space));
}

}
