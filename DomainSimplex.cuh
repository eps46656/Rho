#ifndef RHO__define_guard__DomainSimplex_h
#define RHO__define_guard__DomainSimplex_h

#include "Kernel/Kernel.cuh"

namespace rho {

class DomainSimplex: public DomainSole {
public:
	using ContainFlag = std::uint16_t;
	static constexpr ContainFlag contain_flag_header = ContainFlag(1) << 15;

	struct RayCastTemp {
		Vector origin;
		Vector direct;
		Num t[2];
		ContainFlag contain_flag[2];
	};

	struct RayCastDataCore_: public RayCastDataCore {
		ContainFlag contain_flag;
	};

#///////////////////////////////////////////////////////////////////////////////

	DomainSimplex(Space* parent = nullptr);

#///////////////////////////////////////////////////////////////////////////////

	void Refresh() const override;
	bool ReadyForRendering() const override;

#///////////////////////////////////////////////////////////////////////////////

	bool Contain_s(const Vector& point) const override;

#///////////////////////////////////////////////////////////////////////////////

	ContainFlag GetContainFlag(const Vector& point) const;

#///////////////////////////////////////////////////////////////////////////////

	RayCastData RayCast(const Ray& ray) const override;
	bool RayCastFull(RayCastDataVector& dst, const Ray& ray) const override;
	void RayCastPair(pair<RayCastData>& rcd_p, const Ray& ray) const override;

#///////////////////////////////////////////////////////////////////////////////

	void GetTodTan(Num* dst, const RayCastData& rcd,
				   const Num* root_direct) const override;

private:
	mutable cntr::Vector<Matrix> tod_matrix_;

	RayCastTemp* RayCast_(const Ray& ray) const;
};

}

// ContainFlag
// if (!contain_flag) domain do not contain point
// if (contain_flag & 1 << n) point[n] == 0
// if (contain_flag & 1 << (this->dim_s() + 1)) sum(point) == 1
//

#endif