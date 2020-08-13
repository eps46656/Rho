#ifndef RHO__define_guard__Kernel__Domain_cuh
#define RHO__define_guard__Kernel__Domain_cuh

#include "init.cuh"

namespace rho {

class Domain {
public:
	RHO__cuda Manager* manager() const;
	RHO__cuda Space* root() const;
	RHO__cuda dim_t dim_r() const;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Domain(Space* root = nullptr);
	RHO__cuda virtual ~Domain();

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda virtual bool Refresh() const = 0;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda virtual bool Contain(const Num* root_point) const = 0;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda virtual bool RayCastB(const Ray& ray) const;
	RHO__cuda virtual RayCastData RayCast(const Ray& ray) const;
	RHO__cuda virtual void RayCastForRender(RayCastDataPair& rcdp,
											ComponentCollider* cmpt_collider,
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
	Space* root_;
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