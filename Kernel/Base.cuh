#ifndef RHO__define_guard__Kernel__Base_cuh
#define RHO__define_guard__Kernel__Base_cuh

#include "init.cuh"

namespace rho {

template<size_t size, typename Dst, typename T, typename Direct,
		 typename Origin>
RHO__cuda void line(Dst&& dst, const T& t, const Direct& direct,
					const Origin& origin) {
#pragma unroll
	for (size_t i(0); i != size; ++i) { dst[i] = t * direct[i] + origin[i]; }
}

#///////////////////////////////////////////////////////////////////////////////

/*
RHO__cuda bool LinearDependence(
	const Matrix& matrix);
RHO__cuda bool LinearDependence(
	const Num* m, size_t col_dim, size_t row_dim);*/

#///////////////////////////////////////////////////////////////////////////////
/*
	RHO__cuda bool Include(
		const Num* vector_a, const Num* vector_b,
		size_t dim_a, size_t dim_b, size_t dim_r);*/

#////////////////////////////////////////////////

RHO__cuda bool Complement(dim_t col_dim, dim_t row_dim, Num* data);
RHO__cuda bool Complement(Matrix& matrix);
/*
RHO__cuda bool Complement(Num* begin_m, size_t col_dim, size_t row_dim);

RHO__cuda bool Complement(
	const cntr::Vector<Num*>& data,
	size_t col_dim,
	size_t row_dim);

RHO__cuda bool Complement_(
	const cntr::Vector<Num*>& data,
	size_t col_dim,
	size_t row_dim,
	size_t progress);*/

#////////////////////////////////////////////////
/*
	RHO__cuda bool Complement(Num* d_begin, const Num* begin,
					size_t dim_s, size_t dim_r);

	RHO__cuda bool Complement(Num** begin,
					size_t dim_s, size_t dim_r);

	RHO__cuda bool Complement_(Num** begin,
					 size_t dim_s, size_t dim_r,
					 size_t prog);

	RHO__cuda bool Projection(Num* dest, const Num* begin,
					size_t dim_s, size_t dim_r);

	RHO__cuda bool CoProjection(Num* dest, const Num* begin,
					  size_t dim_s, size_t dim_r);

	RHO__cuda size_t Union(
		Num* dest, const Num* begin_a, const Num* begin_b,
		size_t dim_a, size_t dim_b, size_t dim_r);*/

}

#endif