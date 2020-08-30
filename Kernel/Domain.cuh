#ifndef RHO__define_guard__Kernel__Domain_cuh
#define RHO__define_guard__Kernel__Domain_cuh

#include "init.cuh"

namespace rho {

class Domain {
public:
	enum Type { universe, sole, complex };

	enum struct RayCastPairReturn : int {
		no_change = 0b00,
		first_change = 0b01,
		second_change = 0b10,
		both_change = 0b11
	};

	enum struct RayCastFullReturn : int {
		normal,
		out_phase,
		in_phase,
	};

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

	const Type type;

	RHO__cuda virtual Space* root() const = 0;
	RHO__cuda virtual dim_t dim_r() const;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Domain(Type type);
	RHO__cuda virtual ~Domain();

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda virtual bool Refresh() const = 0;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda virtual bool Contain(const Num* root_point) const = 0;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda virtual bool RayCastB(const Ray& ray) const;
	RHO__cuda virtual RayCastData RayCast(const Ray& ray) const;
	RHO__cuda virtual void RayCastPair(RayCastDataPair& rcdp,
									   const Ray& ray) const;
	RHO__cuda virtual bool RayCastFull(RayCastDataVector& rcdv,
									   const Ray& ray) const = 0;

	/*

	only rcdv.size() does not changed after calling RayCastFull
	RayCastDataFull's return value meaning :
	true  : ray is totally     in phase
	false : ray is totally not in phase

	*/

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda virtual void GetTodTan(Num* dst, const RayCastData& rcd,
									 const Num* root_direct) const = 0;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda virtual size_t Complexity() const = 0;

private:
	Manager* manager_;
};

}

/*

			 +--------+
			 | Domain |
			 +--------+
			 |        |
+------------+        +---------------+
| DomainSole |        | DomainComplex |
+------------+        +---------------+

*/

#endif