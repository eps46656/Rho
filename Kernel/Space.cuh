#ifndef RHO__define_guard__Kernel__Space_cuh
#define RHO__define_guard__Kernel__Space_cuh

#include "init.cuh"

namespace rho {

class Space {
	friend class Manager;
	friend class Component;

public:
	RHO__cuda bool latest() const;

	RHO__cuda bool is_root() const;

	RHO__cuda Space* parent();
	RHO__cuda const Space* parent() const;

	RHO__cuda Space* root();
	RHO__cuda const Space* root() const;

	RHO__cuda const cntr::Vector<Space*>& child();
	RHO__cuda const cntr::Vector<const Space*>& child() const;
	RHO__cuda const cntr::Vector<const Space*>& const_child() const;

	RHO__cuda size_t depth() const;

	// the last 1~2 character represent its size

	// s:this->dim_
	// p:this->dim_p_
	// r:this->dim_r_

	RHO__cuda dim_t dim_s() const;
	RHO__cuda dim_t dim_p() const;
	RHO__cuda dim_t dim_r() const;
	RHO__cuda dim_t dim_cp() const;
	RHO__cuda dim_t dim_cr() const;

#////////////////////////////////////////////////

	// To ensure clients completely know what the following functinos return,
	// them ask clients to call complete function name with matrix's size returned
	// instead of convinent omission

	RHO__cuda const Num* origin() const;
	RHO__cuda const Num* axis() const;

	RHO__cuda const Num* root_origin() const;
	RHO__cuda const Num* root_axis() const;

	RHO__cuda const Num* i_origin() const;
	RHO__cuda const Num* i_axis() const;

	RHO__cuda const Num* i_root_origin() const;
	RHO__cuda const Num* i_root_axis() const;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Space(dim_t dim);
	// create a root space with dim

	RHO__cuda Space(dim_t dim, Space* parent);
	// create a space added to parent as descendant

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Space& operator=(const Space& space) = delete;

#///////////////////////////////////////////////////////////////////////////////

#define RHO__args_ds Num *dest, const Num *src
#define RHO__args_dsb Num *dest, const Num *src, const Space *branch

	RHO__cuda void MapPointToParent_sp(RHO__args_ds) const;
	RHO__cuda void MapPointToParent_sr(RHO__args_ds) const;
	RHO__cuda void MapPointToParent_rp(RHO__args_ds) const;
	RHO__cuda void MapPointToParent_rr(RHO__args_ds) const;

	RHO__cuda void MapVectorToParent_sp(RHO__args_ds) const;
	RHO__cuda void MapVectorToParent_sr(RHO__args_ds) const;
	RHO__cuda void MapVectorToParent_rp(RHO__args_ds) const;
	RHO__cuda void MapVectorToParent_rr(RHO__args_ds) const;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda void MapPointFromParent_ps(RHO__args_ds) const;
	RHO__cuda void MapPointFromParent_rs(RHO__args_ds) const;
	RHO__cuda void MapPointFromParent_pr(RHO__args_ds) const;
	RHO__cuda void MapPointFromParent_rr(RHO__args_ds) const;

	RHO__cuda void MapVectorFromParent_ps(RHO__args_ds) const;
	RHO__cuda void MapVectorFromParent_rs(RHO__args_ds) const;
	RHO__cuda void MapVectorFromParent_pr(RHO__args_ds) const;
	RHO__cuda void MapVectorFromParent_rr(RHO__args_ds) const;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda void MapPointToRoot_sr(RHO__args_ds) const;
	RHO__cuda void MapPointToRoot_rr(RHO__args_ds) const;

	RHO__cuda void MapVectorToRoot_sr(RHO__args_ds) const;
	RHO__cuda void MapVectorToRoot_rr(RHO__args_ds) const;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda void MapPointFromRoot_rs(RHO__args_ds) const;
	RHO__cuda void MapPointFromRoot_rr(RHO__args_ds) const;

	RHO__cuda void MapVectorFromRoot_rs(RHO__args_ds) const;
	RHO__cuda void MapVectorFromRoot_rr(RHO__args_ds) const;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda void MapPointToBranch_sb(RHO__args_dsb) const;
	RHO__cuda void MapPointToBranch_sr(RHO__args_dsb) const;
	RHO__cuda void MapPointToBranch_rb(RHO__args_dsb) const;
	RHO__cuda void MapPointToBranch_rr(RHO__args_dsb) const;

	RHO__cuda void MapVectorToBranch_sb(RHO__args_dsb) const;
	RHO__cuda void MapVectorToBranch_sr(RHO__args_dsb) const;
	RHO__cuda void MapVectorToBranch_rb(RHO__args_dsb) const;
	RHO__cuda void MapVectorToBranch_rr(RHO__args_dsb) const;

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda void ProjectPointFromParent_ps(RHO__args_ds) const;
	RHO__cuda void ProjectPointFromParent_rs(RHO__args_ds) const;
	RHO__cuda void ProjectPointFromParent_pr(RHO__args_ds) const;
	RHO__cuda void ProjectPointFromParent_rr(RHO__args_ds) const;

	RHO__cuda void ProjectVectorFromParent_ps(RHO__args_ds) const;
	RHO__cuda void ProjectVectorFromParent_rs(RHO__args_ds) const;
	RHO__cuda void ProjectVectorFromParent_pr(RHO__args_ds) const;
	RHO__cuda void ProjectVectorFromParent_rr(RHO__args_ds) const;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda void ProjectPointFromRoot_rs(RHO__args_ds) const;
	RHO__cuda void ProjectPointFromRoot_rr(RHO__args_ds) const;

	RHO__cuda void ProjectVectorFromRoot_rs(RHO__args_ds) const;
	RHO__cuda void ProjectVectorFromRoot_rr(RHO__args_ds) const;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda void ProjectPointFromBranch_bs(RHO__args_ds) const;
	RHO__cuda void ProjectPointFromBranch_rs(RHO__args_ds) const;
	RHO__cuda void ProjectPointFromBranch_br(RHO__args_ds) const;
	RHO__cuda void ProjectPointFromBranch_rr(RHO__args_ds) const;

	RHO__cuda void ProjectVectorFromBranch_bs(RHO__args_ds) const;
	RHO__cuda void ProjectVectorFromBranch_rs(RHO__args_ds) const;
	RHO__cuda void ProjectVectorFromBranch_br(RHO__args_ds) const;
	RHO__cuda void ProjectVectorFromBranch_rr(RHO__args_ds) const;

#undef RHO__args_ds
#undef RHO__args_dsb

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda bool IncludePointFromRoot_r(const Num* src) const;
	RHO__cuda bool IncludeVectorFromRoot_r(const Num* src) const;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda bool Overlap(const Space* branch) const;
	RHO__cuda bool Include(const Space* branch) const;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Space* SetParent(Space* parent);

	RHO__cuda Space* SetOrigin(const Num* origin);
	RHO__cuda Space* SetAxis(const Num* axis);

	template<typename... Args> RHO__cuda Space* EnumSetOrigin(Args&&... args) {
		RHO__debug_if(sizeof...(args) != this->dim_p_) {
			RHO__throw(Space, __func__, "dim error");
		}

		Assign<sizeof...(args)>(this->origin_, Forward<Args>(args)...);
		this->latest_ = false;

		return this;
	}

	template<typename... Args> RHO__cuda Space* EnumSetAxis(Args&&... args) {
		RHO__debug_if(sizeof...(args) != this->dim_s_ * this->dim_p_) {
			RHO__throw(Space, __func__, "dim error");
		}

		Num axis[sizeof...(args)];
		Assign<sizeof...(args)>(axis, Forward<Args>(args)...);

		for (size_t i(0); i != sizeof...(args); ++i) {
			size_t a(i / this->dim_p_);
			this->axis_[RHO__max_dim * a + i - a * this->dim_p_] = axis[i];
		}

		this->latest_ = false;

		return this;
	}

	RHO__cuda Space* SetOrigin(const Vector& origin);
	RHO__cuda Space* SetAxis(const Matrix& axis);

	RHO__cuda void Refresh() const;
	// refresh its ancestor and descendant and itself
	RHO__cuda bool RefreshSelf() const;

	RHO__cuda void set_latest_false() const;

	RHO__cuda void Delete();

private:
	mutable bool latest_;

	mutable Space* root_;
	mutable Space* parent_;
	mutable cntr::Vector<Space*> child_;
	mutable cntr::Vector<const Space*> const_child_;

	size_t depth_;

	const dim_t dim_s_;
	const dim_t dim_p_;
	dim_t dim_r_;
	const dim_t dim_cp_;
	dim_t dim_cr_;

#////////////////////////////////////////////////

	mutable Vec origin_;
	mutable Mat axis_;

	mutable Vec root_origin_;
	mutable Mat root_axis_;

	mutable Vec i_origin_;
	mutable Mat i_axis_;

	mutable Vec i_root_origin_;
	mutable Mat i_root_axis_;

#////////////////////////////////////////////////

	mutable Mat proj_root_axis_rs_;
	mutable Mat proj_root_axis_rr_;

#////////////////////////////////////////////////

	RHO__cuda void Check() const;
	RHO__cuda bool RefreshMain_() const;
	RHO__cuda void RefreshDescendant_() const;
	RHO__cuda void SetLatestFalse_();

#////////////////////////////////////////////////

	RHO__cuda void AddChild_(Space* space);
	RHO__cuda void SubChild_(Space* space);

#////////////////////////////////////////////////

	RHO__cuda bool Include_(const Space* branch) const;
};

}

#endif