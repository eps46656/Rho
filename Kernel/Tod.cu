#include "define.cuh"
#include "Kernel.cuh"

#define RHO__throw__local(desc) RHO__throw(Tod, __func__, desc)

namespace rho {

void Tod::TanMatrix(dim_t dim_s, dim_t dim_r, Num* dst, const Num* src) {
	if (dim_s) {
		NumMatrix temp;

		Copy<RHO__max_dim_sq>(temp, src);

		if (!Complement(dim_s, dim_r, temp))
			RHO__throw__local("linear dependence error");

		NumMatrix temp_i;
		inverse(dim_r, temp_i, temp);
		dot(dim_r, dim_s, dim_r, dst, temp_i, temp);
	} else {
		Matrix::identity(dst, dim_r);
	}
}

void Tod::OrthMatrix(dim_t dim_s, dim_t dim_r, Num* dst, const Num* src) {
	if (dim_s) {
		NumMatrix temp;

		Copy<RHO__max_dim_sq>(temp, src);

		if (!Complement(dim_s, dim_r, temp))
			RHO__throw__local("linear dependence error");

		NumMatrix temp_i;
		inverse(dim_r, temp_i, temp);
		dot(dim_r, dim_r - dim_s, dim_r, dst, temp_i + dim_s,
			temp + RHO__max_dim * dim_s);
	} else {
		for (dim_t i(0); i != dim_r; ++i) {
			for (dim_t j(0); j != RHO__max_dim; ++j)
				dst[RHO__max_dim * i + j] = 0;
		}
	}
}

void Tod::TanMatrix(Matrix& axis) {
	TanMatrix(axis.col_dim(), axis.row_dim(), axis, axis);
	axis.set_col_dim(axis.row_dim());
}

void Tod::OrthMatrix(Matrix& axis) {
	OrthMatrix(axis.col_dim(), axis.row_dim(), axis, axis);
	axis.set_col_dim(axis.row_dim());
}

Vector Tod::Tan(const Vector& vector, const Vector& axis) {
	RHO__debug_if(vector.dim() != axis.dim()) RHO__throw__local("dim error");

	Vector r(vector.dim());
	Tan(vector.dim(), r, vector, axis);
	return r;
}

Vector Tod::Orth(const Vector& vector, const Vector& axis) {
	RHO__debug_if(vector.dim() != axis.dim()) RHO__throw__local("dim error");

	Vector r(vector.dim());
	Orth(vector.dim(), r, vector, axis);
	return r;
}

void Tod::Tan(dim_t dim_r, Num* dst, const Num* vector, const Num* axis) {
	RHO__debug_if(!dim_r) RHO__throw__local("dim error");

	Num dot(0);
	Num axis_sq(0);

	for (dim_t i(0); i != dim_r; ++i) {
		dot += vector[i] * axis[i];
		axis_sq += sq(axis[i]);
	}

	if (axis_sq.ne<0>()) { dot /= axis_sq; }

	for (dim_t i(0); i != dim_r; ++i) { dst[i] = axis[i] * dot; }
}

void Tod::Orth(dim_t dim_r, Num* dst, const Num* vector, const Num* axis) {
	RHO__debug_if(!dim_r) RHO__throw__local("dim error");

	Num dot(0);
	Num axis_sq(0);

	for (dim_t i(0); i != dim_r; ++i) {
		dot += vector[i] * axis[i];
		axis_sq += sq(axis[i]);
	}

	if (axis_sq.ne<0>()) { dot /= axis_sq; }

	for (dim_t i(0); i != dim_r; ++i) { dst[i] = vector[i] - axis[i] * dot; }
}

}