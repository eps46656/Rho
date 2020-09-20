#ifndef RHO__define_guard__Kernel__Space_cuh
#define RHO__define_guard__Kernel__Space_cuh

#include "init.cuh"

namespace rho {

class Space {
public:
	RHO__cuda dim_t dim() const;
	RHO__cuda dim_t parent_dim() const;
	RHO__cuda dim_t root_dim() const;
	RHO__cuda dim_t parent_codim() const;
	RHO__cuda dim_t root_codim() const;

	RHO__cuda const Space* parent() const;
	RHO__cuda const Space* root() const;

	RHO__cuda size_t depth() const;

	RHO__cuda bool is_root() const;

	RHO__cuda const Num* origin() const;
	RHO__cuda const Num* axis() const;

	RHO__cuda const Num* root_origin() const;
	RHO__cuda const Num* root_axis() const;

	RHO__cuda const Num* i_origin() const;
	RHO__cuda const Num* i_axis() const;

	RHO__cuda const Num* i_root_origin() const;
	RHO__cuda const Num* i_root_axis() const;

	RHO__cuda bool latest_arch() const;
	RHO__cuda bool latest() const;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Space(dim_t dim = 0, const Space* parent = nullptr);

#///////////////////////////////////////////////////////////////////////////////

	// the last 1~2 character represent its size

	// s:this->dim_
	// p:this->dim_p_
	// r:this->dim_r_

#///////////////////////////////////////////////////////////////////////////////

	// To ensure clients completely know what the following functinos return,
	// them ask clients to call complete function name with matrix's size returned
	// instead of convinent omission

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

	RHO__cuda Space* SetParent(const Space* parent);
	RHO__cuda Space* SetDim(dim_t dim);

	RHO__cuda Space* SetOrigin(const Num* origin);
	RHO__cuda Space* SetAxis(const Num* axis);

	RHO__cuda Space* SetOrigin(const Vector& origin);
	RHO__cuda Space* SetAxis(const Matrix& axis);

	template<typename... Args> RHO__cuda Space* EnumSetOrigin(Args&&... args) {
		RHO__debug_if(sizeof...(args) != this->parent_dim_) {
			RHO__throw(Space, __func__, "dim error");
		}

		Assign<sizeof...(args)>(this->origin_, Forward<Args>(args)...);
		this->latest_ = false;

		return this;
	}

	template<typename... Args> RHO__cuda Space* EnumSetAxis(Args&&... args) {
		RHO__debug_if(sizeof...(args) != this->dim_ * this->parent_dim_) {
			RHO__throw(Space, __func__, "dim error");
		}

		Num axis[sizeof...(args)];
		Assign<sizeof...(args)>(axis, Forward<Args>(args)...);

		for (size_t i(0); i != sizeof...(args); ++i) {
			size_t a(i / this->parent_dim_);
			this->axis_[RHO__max_dim * a + i - a * this->parent_dim_] = axis[i];
		}

		this->latest_ = false;

		return this;
	}

	RHO__cuda void SetLatestFalse() const;

	RHO__cuda Space* RefreshArch();
	RHO__cuda const Space* RefreshArch() const;
	RHO__cuda Space* Refresh();
	RHO__cuda const Space* Refresh() const;

private:
	dim_t dim_;
	mutable dim_t parent_dim_;
	mutable dim_t root_dim_;
	mutable dim_t parent_codim_;
	mutable dim_t root_codim_;

	const Space* parent_;
	mutable const Space* root_;

	size_t depth_;

#///////////////////////////////////////////////////////////////////////////////

	mutable Vec origin_;
	mutable Mat axis_;

	mutable Vec root_origin_;
	mutable Mat root_axis_;

	mutable Vec i_origin_;
	mutable Mat i_axis_;

	mutable Vec i_root_origin_;
	mutable Mat i_root_axis_;

#///////////////////////////////////////////////////////////////////////////////

	mutable Mat proj_root_axis_rs_;
	mutable Mat proj_root_axis_rr_;

#///////////////////////////////////////////////////////////////////////////////

	mutable bool latest_arch_;
	mutable bool latest_;

#///////////////////////////////////////////////////////////////////////////////

	mutable const Space* temp_;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda void RefreshArch_() const;
	RHO__cuda void Refresh_() const;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda bool Include_(const Space* branch) const;
};

}

#endif