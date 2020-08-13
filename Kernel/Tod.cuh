#ifndef RHO__define_guard__Kernel__Tod_cuh
#define RHO__define_guard__Kernel__Tod_cuh

#include "init.cuh"

namespace rho {

struct Tod {
	NumVector tan;
	NumVector orth;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda static void TanMatrix(dim_t dim_s, dim_t dim_r, Num* dst,
									const Num* src);

	RHO__cuda static void OrthMatrix(dim_t dim_s, dim_t dim_r, Num* dst,
									 const Num* src);

	RHO__cuda static void TanMatrix(Matrix& matrix);
	RHO__cuda static void OrthMatrix(Matrix& matrix);

	RHO__cuda static Vector Tan(const Vector& src, const Vector& axis);
	RHO__cuda static Vector Orth(const Vector& src, const Vector& axis);

	RHO__cuda static void Tan(dim_t dim_r, Num* dst, const Num* vector,
							  const Num* axis);

	RHO__cuda static void Orth(dim_t dim_r, Num* dst, const Num* vector,
							   const Num* axis);

	RHO__cuda static void Tan(dim_t dim_s, dim_t dim_r, Num* dst,
							  const Num* vector, const Num* axis);
	RHO__cuda static void Orth(dim_t dim_s, dim_t dim_r, Num* dst,
							   const Num* vector, const Num* axis);
};

}

#endif