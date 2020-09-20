#ifndef RHO__define_guard__Kernel__Domain_cuh
#define RHO__define_guard__Kernel__Domain_cuh

#include "init.cuh"

namespace rho {

class Domain {
public:
	enum Type { universe, sole, complex };

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

	const Type type;

	RHO__cuda virtual const Space* root() const = 0;
	RHO__cuda virtual dim_t root_dim() const;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Domain(Type type);
	RHO__cuda virtual ~Domain();

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda virtual const Domain* Refresh() const = 0;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda virtual bool Contain(const Num* root_point) const = 0;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda virtual size_t RayCastComplexity() const = 0;
	RHO__cuda virtual RayCastData RayCast(const Ray& ray) const;
	RHO__cuda virtual bool RayCastB(const Ray& ray) const;
	RHO__cuda virtual void RayCastPair(RayCastDataPair& rcdp,
									   const Ray& ray) const;
	RHO__cuda virtual size_t RayCastFull(RayCastData* dst,
										 const Ray& ray) const = 0;

	/*

	only rcdv.size() does not changed after calling RayCastFull
	RayCastDataFull's return value meaning :
	0 : ray is tot

	0 : rcd size, ray is totally not in phase
	1 ~ RHO__RayCastFull_max_rcd : rcd size
	RHO__Domain__RayCastFull_in_phase : ray is totally in phase

	*/

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda virtual void GetTodTan(Num* dst, const RayCastData& rcd,
									 const Num* root_direct) const = 0;

#///////////////////////////////////////////////////////////////////////////////

	// RHO__cuda virtual const Domain* Equivalence() const;
	// simplify self then return a equivalent domain, aim ot optimize
	// return nullptr represent self domain is null
	// return self pointer represent self domain has been simplified
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