#include "define.cuh"
#include "Calculus.cuh"

#define RHO__det_2(x0, x1, x2, x3) ((x0) * (x3) - (x1) * (x2))

#define RHO__det_3(x00, x01, x02, x10, x11, x12, x20, x21, x22)                \
	((x00)*RHO__det_2(x11, x12, x21, x22) -                                    \
	 (x01)*RHO__det_2(x10, x12, x20, x22) +                                    \
	 (x02)*RHO__det_2(x10, x11, x20, x21))

#define RHO__det_4(x00, x01, x02, x03, x10, x11, x12, x13, x20, x21, x22, x23, \
				   x30, x31, x32, x33)                                         \
	((x00)*RHO__det_3(x11, x12, x13, x21, x22, x23, x31, x32, x33) -           \
	 (x01)*RHO__det_3(x10, x12, x13, x20, x22, x23, x30, x32, x33) +           \
	 (x02)*RHO__det_3(x10, x11, x13, x20, x21, x23, x30, x31, x33) -           \
	 (x02)*RHO__det_3(x10, x11, x12, x20, x21, x22, x30, x31, x32))

#///////////////////////////////////////////////////////////////////////////////

#define RHO__cross_3_0(x00, x01, x02, x10, x11, x12)                           \
	(RHO__det_2(x01, x02, x11, x12))

#define RHO__cross_3_1(x00, x01, x02, x10, x11, x12)                           \
	(-RHO__det_2(x00, x02, x10, x12))

#define RHO__cross_3_2(x00, x01, x02, x10, x11, x12)                           \
	(RHO__det_2(x00, x01, x10, x11))

#///////////////////////////////////////////////////////////////////////////////

#define RHO__cross_4_0(x00, x01, x02, x03, x10, x11, x12, x13, x20, x21, x22,  \
					   x23)                                                    \
	(RHO__det_3(x01, x02, x03, x11, x12, x13, x21, x22, x23))

#define RHO__cross_4_1(x00, x01, x02, x03, x10, x11, x12, x13, x20, x21, x22,  \
					   x23)                                                    \
	(-RHO__det_3(x00, x02, x03, x10, x12, x13, x20, x22, x23))

#define RHO__cross_4_2(x00, x01, x02, x03, x10, x11, x12, x13, x20, x21, x22,  \
					   x23)                                                    \
	(RHO__det_3(x00, x01, x03, x10, x11, x13, x20, x21, x23))

#define RHO__cross_4_3(x00, x01, x02, x03, x10, x11, x12, x13, x20, x21, x22,  \
					   x23)                                                    \
	(-RHO__det_3(x00, x01, x02, x10, x11, x12, x20, x21, x22))

#///////////////////////////////////////////////////////////////////////////////

#define RHO__throw__local(desc) RHO__throw(Matrix, __func__, desc)
#define RHO__full_loop for (dim_t i(0); i != RHO__max_dim_sq; ++i)

namespace rho {

dim_t Matrix::col_dim() const { return this->col_dim_; }
dim_t Matrix::row_dim() const { return this->row_dim_; }

void Matrix::set_col_dim(dim_t col_dim) { this->col_dim_ = col_dim; }
void Matrix::set_row_dim(dim_t row_dim) { this->row_dim_ = row_dim; }

void Matrix::set_dim(dim_t col_dim, dim_t row_dim) {
	RHO__debug_if(RHO__max_dim < col_dim || RHO__max_dim < row_dim) {
		RHO__throw__local("capacity error");
	}

	this->col_dim_ = col_dim;
	this->row_dim_ = row_dim;
}

#///////////////////////////////////////////////////////////////////////////////

Matrix::Matrix(): col_dim_(0), row_dim_(0) {}

Matrix::Matrix(dim_t col_dim, dim_t row_dim):
	col_dim_(col_dim), row_dim_(row_dim) {}

Matrix::Matrix(const Matrix& matrix):
	col_dim_(matrix.col_dim_), row_dim_(matrix.row_dim_) {
	Copy(*this, matrix);
}

#///////////////////////////////////////////////////////////////////////////////

void Matrix::identity(Num* dst) {
#pragma unroll
	for (dim_t i(1); i != RHO__max_dim; ++i) {
		*dst = 1;
		++dst;

#pragma unroll
		for (dim_t j(0); j != RHO__max_dim; ++j, ++dst) { *dst = 0; }
	}

	*dst = 1;
}

void Matrix::identity(Num* dst, dim_t dim) {
	for (dim_t i(1); i != dim; ++i) {
		*dst = 1;
		++dst;

		for (dim_t j(0); j != RHO__max_dim; ++j, ++dst) { *dst = 0; }
	}

	*dst = 1;
}

void Matrix::identity(Matrix& dst, dim_t dim) {
	RHO__debug_if(RHO__max_dim < dim) { RHO__throw__local("dim error"); }

	dst.col_dim_ = dst.row_dim_ = dim;

	for (dim_t i(0); i != dim; ++i) {
		for (dim_t j(0); j != dim; ++j) {
			dst[RHO__max_dim * i + j] = i == j ? 1 : 0;
		}
	}
}

#///////////////////////////////////////////////////////////////////////////////

Matrix& Matrix::operator=(const Matrix& matrix) {
	if (this == &matrix) { return *this; }
	this->col_dim_ = matrix.col_dim_;
	this->row_dim_ = matrix.row_dim_;
	Copy(*this, matrix);
	return *this;
}

#///////////////////////////////////////////////////////////////////////////////

Num& Matrix::operator[](dim_t index) {
	RHO__debug_if(RHO__max_dim_sq < index) { RHO__throw__local("index error"); }

	return this->data[index];
}

const Num& Matrix::operator[](dim_t index) const {
	RHO__debug_if(RHO__max_dim_sq < index) { RHO__throw__local("index error"); }

	return this->data[index];
}

Num& Matrix::get(dim_t col_index, dim_t row_index) {
	RHO__debug_if(this->col_dim_ <= col_index || this->row_dim_ <= row_index) {
		RHO__throw__local("index error");
	}

	return (*this)[RHO__max_dim * col_index + row_index];
}

const Num& Matrix::get(dim_t col_index, dim_t row_index) const {
	RHO__debug_if(this->col_dim_ <= col_index || this->row_dim_ <= row_index) {
		RHO__throw__local("index error");
	}

	return (*this)[RHO__max_dim * col_index + row_index];
}

Matrix Matrix::slice(dim_t max_col_index, dim_t max_row_index) const& {
	Matrix r;
	slice(r, *this, max_col_index, max_row_index);
	return r;
}

Matrix&& Matrix::slice(dim_t max_col_index, dim_t max_row_index) && {
	slice(*this, *this, max_col_index, max_row_index);
	return Move(*this);
}

Matrix Matrix::slice(dim_t min_col_index, dim_t min_row_index,
					 dim_t max_col_index, dim_t max_row_index) const& {
	Matrix r;
	slice(r, *this, min_col_index, min_row_index, max_col_index, max_row_index);
	return r;
}

Matrix&& Matrix::slice(dim_t min_col_index, dim_t min_row_index,
					   dim_t max_col_index, dim_t max_row_index) && {
	slice(*this, *this, min_col_index, min_row_index, max_col_index,
		  max_row_index);
	return Move(*this);
}

void Matrix::slice(Matrix& dst, const Matrix& src, dim_t max_col_index,
				   dim_t max_row_index) {
	RHO__debug_if(src.col_dim_ < max_col_index ||
				  src.row_dim_ < max_row_index) {
		RHO__throw__local("index error");
	}

	dst.col_dim_ = max_col_index;
	dst.row_dim_ = max_row_index;

	if (dst.col_dim_ * dst.row_dim_) {
		for (dim_t i(0); i != dst.col_dim_; ++i) {
			CopyForward(dst.row_dim_, dst + RHO__max_dim * i,
						src + RHO__max_dim * i);
		}
	}
}

void Matrix::slice(Matrix& dst, const Matrix& src, dim_t min_col_index,
				   dim_t min_row_index, dim_t max_col_index,
				   dim_t max_row_index) {
	RHO__debug_if(
		src.col_dim_ < min_col_index || src.row_dim_ < min_row_index ||
		src.col_dim_ < max_col_index || src.row_dim_ < max_row_index ||
		max_col_index < min_col_index || max_row_index < min_row_index) {
		RHO__throw__local("index error");
	}

	dst.col_dim_ = max_col_index - min_col_index;
	dst.row_dim_ = max_row_index - min_row_index;

	if (dst.col_dim_ * dst.row_dim_) {
		for (dim_t i(0); i != dst.col_dim_; ++i) {
			CopyForward(dst.row_dim_, dst + RHO__max_dim * i,
						src + RHO__max_dim * (min_col_index + i) +
							min_row_index);
		}
	}
}

#///////////////////////////////////////////////////////////////////////////////

bool operator==(const Matrix& x, const Matrix& y) {
	if (x.col_dim() != y.col_dim() || x.row_dim() != y.row_dim()) {
		return false;
	}

	for (dim_t i(0); i != x.col_dim(); ++i) {
		for (dim_t j(0); j != x.row_dim(); ++j) {
			if (x[RHO__max_dim * i + j] != y[RHO__max_dim * i + j])
				return false;
		}
	}

	return true;
}

bool operator!=(const Matrix& x, const Matrix& y) { return !(x == y); }

#///////////////////////////////////////////////////////////////////////////////

Matrix& Matrix::operator+() & { return *this; }
Matrix&& Matrix::operator+() && { return Move(*this); }
const Matrix& Matrix::operator+() const& { return *this; }

Matrix Matrix::Matrix::operator-() const& {
	Matrix r(this->col_dim_, this->row_dim_);

#pragma unroll
	RHO__full_loop { r[i] = -(*this)[i]; }

	return r;
}

Matrix& Matrix::operator-() && {
#pragma unroll
	RHO__full_loop { (*this)[i] = -(*this)[i]; }

	return *this;
}

#///////////////////////////////////////////////////////////////////////////////

Matrix operator+(const Matrix& x, const Matrix& y) {
	RHO__debug_if(x.col_dim() != y.col_dim() || x.row_dim() != y.row_dim()) {
		RHO__throw__local("dim error");
	}

	Matrix r(x.col_dim(), x.row_dim());

#pragma unroll
	RHO__full_loop { r[i] = x[i] + y[i]; }

	return r;
}

Matrix&& operator+(const Matrix& x, Matrix&& y) { return Move(y += x); }

Matrix&& operator+(Matrix&& x, const Matrix& y) { return Move(x += y); }

Matrix&& operator+(Matrix&& x, Matrix&& y) { return Move(x += y); }

#///////////////////////////////////////////////////////////////////////////////

Matrix operator-(const Matrix& x, const Matrix& y) {
	RHO__debug_if(x.col_dim() != y.col_dim() || x.row_dim() != y.row_dim()) {
		RHO__throw__local("dim error");
	}

	Matrix r(x.col_dim(), x.row_dim());

#pragma unroll
	RHO__full_loop { r[i] = x[i] - y[i]; }

	return r;
}

Matrix&& operator-(const Matrix& x, Matrix&& y) {
	RHO__debug_if(x.col_dim() != y.col_dim() || x.row_dim() != y.row_dim()) {
		RHO__throw__local("dim error");
	}

#pragma unroll
	RHO__full_loop { y[i] = x[i] - y[i]; }

	return Move(y);
}

Matrix&& operator-(Matrix&& x, const Matrix& y) { return Move(x -= y); }

Matrix&& operator-(Matrix&& x, Matrix&& y) { return Move(x -= y); }

#///////////////////////////////////////////////////////////////////////////////

Matrix operator*(Num num, const Matrix& matrix) { return matrix * num; }

Matrix operator*(const Matrix& matrix, Num num) {
	Matrix r(matrix.col_dim(), matrix.row_dim());

#pragma unroll
	RHO__full_loop { r[i] = matrix[i] * num; }

	return r;
}

Vector operator*(const Vector& vector, const Matrix& matrix) {
	RHO__debug_if(vector.dim() != matrix.col_dim())
		RHO__throw__local("dim error");

	Vector r(matrix.row_dim());
	dot(matrix.col_dim(), matrix.row_dim(), r, vector, matrix);

	return r;
}

Matrix operator*(const Matrix& x, const Matrix& y) {
	RHO__debug_if(x.row_dim() != y.col_dim()) RHO__throw__local("dim error");

	Matrix r(x.col_dim(), y.row_dim());
	dot(x.col_dim(), y.col_dim(), y.row_dim(), r, x, y);

	return r;
}

Matrix&& operator*(Num num, Matrix&& matrix) { return Move(matrix *= num); }

Matrix&& operator*(Matrix&& matrix, Num num) { return Move(matrix *= num); }

#///////////////////////////////////////////////////////////////////////////////

Matrix operator/(const Matrix& matrix, Num num) { return matrix * (1 / num); }
Matrix&& operator/(Matrix&& matrix, Num num) { return Move(matrix /= num); }

#///////////////////////////////////////////////////////////////////////////////

Matrix& Matrix::operator+=(const Matrix& matrix) & {
	RHO__debug_if(this->col_dim_ != matrix.col_dim_ ||
				  this->row_dim_ != matrix.row_dim_) {
		RHO__throw__local("dim error");
	}

#pragma unroll
	RHO__full_loop { (*this)[i] += matrix[i]; }

	return *this;
}

Matrix& Matrix::operator-=(const Matrix& matrix) & {
	RHO__debug_if(this->col_dim_ != matrix.col_dim_ ||
				  this->row_dim_ != matrix.row_dim_) {
		RHO__throw__local("dim error");
	}

#pragma unroll
	RHO__full_loop { (*this)[i] -= matrix[i]; }

	return *this;
}

Matrix& Matrix::operator*=(Num num) & {
#pragma unroll
	RHO__full_loop { (*this)[i] *= num; }

	return *this;
}

Matrix& Matrix::operator*=(const Matrix& matrix) & {
	return (*this) = (*this) * matrix;
}

Matrix& Matrix::operator/=(Num num) & { return (*this) *= 1 / num; }

#///////////////////////////////////////////////////////////////////////////////

void Matrix::Print(dim_t col_dim, dim_t row_dim, const Num* data) {
	if (!(col_dim * row_dim)) {
		rho::Print() << "[ void matrix ]\n";
		return;
	}

	rho::Print() << "[";

	for (dim_t i(0); i != col_dim; ++i) {
		rho::Print() << "\n" << data[RHO__max_dim * i];

		for (dim_t j(1); j != row_dim; ++j) {
			rho::Print() << ", " << data[RHO__max_dim * i + j];
		}
	}

	rho::Print() << "\n]\n";
}

const Print& operator<<(const Print& p, const Matrix& matrix) {
	Matrix::Print(matrix.col_dim(), matrix.row_dim(), matrix);
	return p;
}

#///////////////////////////////////////////////////////////////////////////////

Matrix Matrix::transpose() const& {
	Matrix r(this->row_dim_, this->col_dim_);

	for (dim_t i(0); i != this->row_dim_; ++i) {
		for (dim_t j(0); j != this->col_dim_; ++j) {
			r.get(i, j) = this->get(j, i);
		}
	}

	return r;
}

Matrix&& Matrix::transpose() && { return Move(this->transpose_self()); }

Matrix& Matrix::transpose_self() {
	Swap(this->col_dim_, this->row_dim_);

	for (dim_t i(0); i != this->col_dim_; ++i) {
		for (dim_t j(i + 1); j != this->row_dim_; ++j) {
			Swap(this->get(i, j), this->get(j, i));
		}
	}

	return *this;
}

#////////////////////////////////////////////////

Num Matrix::det() const {
	RHO__debug_if(this->col_dim_ != this->row_dim_) {
		RHO__throw__local("dim error");
	}

	return rho::det(*this, this->col_dim_);
}

Matrix Matrix::inverse() const {
	RHO__debug_if(this->col_dim_ != this->row_dim_) {
		RHO__throw__local("dim error");
	}

	Matrix r(this->col_dim_, this->row_dim_);
	rho::inverse(this->col_dim_, r, *this);
	return r;
}

Vector Matrix::cross() const {
	RHO__debug_if(this->col_dim_ + 1 != this->row_dim_) {
		RHO__throw__local("dim error");
	}

	Vector r(this->row_dim_);
	rho::cross(r, *this, this->row_dim_);
	return r;
}

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

void identity(Num* dst, dim_t dim) {
	for (dim_t i(1); i != dim; ++i) {
		*dst = 1;
		++dst;
		for (dim_t j(0); j != dim; ++j, ++dst) { *dst = 0; }
	}

	*dst = 1;
}

#///////////////////////////////////////////////////////////////////////////////

#define RHO__index(i, j) (RHO__max_dim * i + j)
#define RHO__F(i, j) (v[i] * m[RHO__max_dim * i + j])

void dot(dim_t col_dim, dim_t row_dim, Num* dst, const Num* v, const Num* m) {
	if (col_dim == 2 && row_dim == 2) {
		dst[0] = RHO__F(0, 0) + RHO__F(1, 0);
		dst[1] = RHO__F(0, 1) + RHO__F(1, 1);
		return;
	}

	if (col_dim == 3 && row_dim == 3) {
		dst[0] = RHO__F(0, 0) + RHO__F(1, 0) + RHO__F(2, 0);
		dst[1] = RHO__F(0, 1) + RHO__F(1, 1) + RHO__F(2, 1);
		dst[2] = RHO__F(0, 2) + RHO__F(1, 2) + RHO__F(2, 2);
		return;
	}

	if (col_dim == 4 && row_dim == 4) {
		dst[0] = RHO__F(0, 0) + RHO__F(1, 0) + RHO__F(2, 0) + RHO__F(3, 0);
		dst[1] = RHO__F(0, 1) + RHO__F(1, 1) + RHO__F(2, 1) + RHO__F(3, 1);
		dst[2] = RHO__F(0, 2) + RHO__F(1, 2) + RHO__F(2, 2) + RHO__F(3, 2);
		dst[3] = RHO__F(0, 3) + RHO__F(1, 3) + RHO__F(2, 3) + RHO__F(3, 3);
		return;
	}

	for (dim_t i(0); i != row_dim; ++i) { dst[i] = RHO__F(0, i); }

	for (dim_t i(0); i != col_dim; ++i) {
		for (dim_t j(1); j != row_dim; ++j) { dst[j] += RHO__F(i, j); }
	}
}

#undef RHO__F

#define RHO__dst(i, j) dst[RHO__max_dim * i + j]
#define RHO__F(i, j, k) x[RHO__max_dim * i + k] * y[RHO__max_dim * k + j]

void dot(dim_t x_col_dim, dim_t y_col_dim, dim_t y_row_dim, Num* dst,
		 const Num* x, const Num* y) {
	if (x_col_dim == 3 && y_col_dim == 3 && y_row_dim == 3) {
		RHO__dst(0, 0) = RHO__F(0, 0, 0) + RHO__F(0, 0, 1) + RHO__F(0, 0, 2);
		RHO__dst(0, 1) = RHO__F(0, 1, 0) + RHO__F(0, 1, 1) + RHO__F(0, 1, 2);
		RHO__dst(0, 2) = RHO__F(0, 2, 0) + RHO__F(0, 2, 1) + RHO__F(0, 2, 2);
		RHO__dst(1, 0) = RHO__F(1, 0, 0) + RHO__F(1, 0, 1) + RHO__F(1, 0, 2);
		RHO__dst(1, 1) = RHO__F(1, 1, 0) + RHO__F(1, 1, 1) + RHO__F(1, 1, 2);
		RHO__dst(1, 2) = RHO__F(1, 2, 0) + RHO__F(1, 2, 1) + RHO__F(1, 2, 2);
		RHO__dst(2, 0) = RHO__F(2, 0, 0) + RHO__F(2, 0, 1) + RHO__F(2, 0, 2);
		RHO__dst(2, 1) = RHO__F(2, 1, 0) + RHO__F(2, 1, 1) + RHO__F(2, 1, 2);
		RHO__dst(2, 2) = RHO__F(2, 2, 0) + RHO__F(2, 2, 1) + RHO__F(2, 2, 2);
		return;
	}

	/*for (dim_t i(0); i != x_col_dim; ++i) {
		dot(y_col_dim, y_row_dim, dst + RHO__max_dim * i,
			x + RHO__max_dim * i, y);
	}*/

	for (dim_t i(0); i != x_col_dim; ++i) {
		for (dim_t j(0); j != y_row_dim; ++j) {
			RHO__dst(i, j) = RHO__F(i, j, 0);

			for (dim_t k(1); k != y_col_dim; ++k)
				RHO__dst(i, j) += RHO__F(i, j, k);
		}
	}
}

#undef RHO__dst
#undef RHO__F

#///////////////////////////////////////////////////////////////////////////////

#define RHO__F(i, j) src[RHO__max_dim * i + j]

Num det(const Num* src, dim_t size) {
	switch (size) {
		case 0: return 0;
		case 1: return *src;
	}

	if (size == 2) {
		return RHO__det_2(RHO__F(0, 0), RHO__F(0, 1), RHO__F(1, 0),
						  RHO__F(1, 1));
	}

	if (size == 3) {
		return RHO__det_3(RHO__F(0, 0), RHO__F(0, 1), RHO__F(0, 2),
						  RHO__F(1, 0), RHO__F(1, 1), RHO__F(1, 2),
						  RHO__F(2, 0), RHO__F(2, 1), RHO__F(2, 2));
	}

	if (size == 4) {
		return RHO__det_4(
			RHO__F(0, 0), RHO__F(0, 1), RHO__F(0, 2), RHO__F(0, 3),
			RHO__F(1, 0), RHO__F(1, 1), RHO__F(1, 2), RHO__F(1, 3),
			RHO__F(2, 0), RHO__F(2, 1), RHO__F(2, 2), RHO__F(2, 3),
			RHO__F(3, 0), RHO__F(3, 1), RHO__F(3, 2), RHO__F(3, 3));
	}

	return 0;
}

#undef RHO__F

#define RHO__src(i, j) src[RHO__max_dim * i + j]
#define RHO__dst(i, j) dst[RHO__max_dim * i + j]

void inverse(dim_t dim, Num* dst, const Num* src) {
	if (dim == 2) {
		Num det(RHO__det_2(src[0], src[1], src[2], src[3]));

		if (det.eq<0>()) {
			dst[0] = 0;
			dst[1] = 0;
			dst[2] = 0;
			dst[3] = 0;
		} else {
			dst[0] = src[3] / det;
			dst[1] = -src[1] / det;
			dst[2] = -src[2] / det;
			dst[3] = src[0] / det;
		}

		return;
	}

	if (dim == 3) {
		Num a[3];

		a[0] = RHO__det_2(RHO__src(1, 1), RHO__src(1, 2), RHO__src(2, 1),
						  RHO__src(2, 2));
		a[1] = RHO__det_2(RHO__src(2, 1), RHO__src(2, 2), RHO__src(0, 1),
						  RHO__src(0, 2));
		a[2] = RHO__det_2(RHO__src(0, 1), RHO__src(0, 2), RHO__src(1, 1),
						  RHO__src(1, 2));

		Num det(RHO__src(0, 0) * a[0] + RHO__src(1, 0) * a[1] +
				RHO__src(2, 0) * a[2]);

		if (det.eq<0>()) {
			RHO__dst(0, 0) = 0;
			RHO__dst(0, 1) = 0;
			RHO__dst(0, 2) = 0;
			RHO__dst(1, 0) = 0;
			RHO__dst(1, 1) = 0;
			RHO__dst(1, 2) = 0;
			RHO__dst(2, 0) = 0;
			RHO__dst(2, 1) = 0;
			RHO__dst(2, 2) = 0;
		} else {
			Num idet(1 / det);

			RHO__dst(0, 0) = a[0] * idet;
			RHO__dst(0, 1) = a[1] * idet;
			RHO__dst(0, 2) = a[2] * idet;
			RHO__dst(1, 0) = RHO__det_2(RHO__src(2, 0), RHO__src(2, 2),
										RHO__src(1, 0), RHO__src(1, 2)) *
							 idet;
			// src[6], src[8], src[3], src[5]) * idet;
			RHO__dst(1, 1) = RHO__det_2(RHO__src(0, 0), RHO__src(0, 2),
										RHO__src(2, 0), RHO__src(2, 2)) *
							 idet;
			// src[0], src[2], src[6], src[8]) * idet;
			RHO__dst(1, 2) = RHO__det_2(RHO__src(0, 2), RHO__src(1, 2),
										RHO__src(0, 0), RHO__src(1, 0)) *
							 idet;
			// src[2], src[5], src[0], src[3]) * idet;
			RHO__dst(2, 0) = RHO__det_2(RHO__src(1, 0), RHO__src(1, 1),
										RHO__src(2, 0), RHO__src(2, 1)) *
							 idet;
			// src[3], src[4], src[6], src[7]) * idet;
			RHO__dst(2, 1) = RHO__det_2(RHO__src(0, 1), RHO__src(2, 1),
										RHO__src(0, 0), RHO__src(2, 0)) *
							 idet;
			// src[1], src[7], src[0], src[6]) * idet;
			RHO__dst(2, 2) = RHO__det_2(RHO__src(0, 0), RHO__src(0, 1),
										RHO__src(1, 0), RHO__src(1, 1)) *
							 idet;
			// src[0], src[1], src[3], src[4]) * idet;
		}

		return;
	}

	::printf("this->col_dim_ : %d\n", int(dim));
}

#undef RHO__src
#undef RHO__dst

#define RHO__src(i, j) src[RHO__max_dim * i + j]

void cross(Num* dst, const Num* src, dim_t size) {
	if (size == 2) {
		dst[0] = src[1];
		dst[1] = -src[0];
		return;
	}

	if (size == 3) {
		dst[0] = RHO__cross_3_0(RHO__src(0, 0), RHO__src(0, 1), RHO__src(0, 2),
								RHO__src(1, 0), RHO__src(1, 1), RHO__src(1, 2));
		dst[1] = RHO__cross_3_1(RHO__src(0, 0), RHO__src(0, 1), RHO__src(0, 2),
								RHO__src(1, 0), RHO__src(1, 1), RHO__src(1, 2));
		dst[2] = RHO__cross_3_2(RHO__src(0, 0), RHO__src(0, 1), RHO__src(0, 2),
								RHO__src(1, 0), RHO__src(1, 1), RHO__src(1, 2));
		return;
	}

	if (size == 4) {
		dst[0] = RHO__cross_4_0(RHO__src(0, 0), RHO__src(0, 1), RHO__src(0, 2),
								RHO__src(0, 3), RHO__src(1, 0), RHO__src(1, 1),
								RHO__src(1, 2), RHO__src(1, 3), RHO__src(2, 0),
								RHO__src(2, 1), RHO__src(2, 2), RHO__src(2, 3));
		dst[1] = RHO__cross_4_1(RHO__src(0, 0), RHO__src(0, 1), RHO__src(0, 2),
								RHO__src(0, 3), RHO__src(1, 0), RHO__src(1, 1),
								RHO__src(1, 2), RHO__src(1, 3), RHO__src(2, 0),
								RHO__src(2, 1), RHO__src(2, 2), RHO__src(2, 3));
		dst[2] = RHO__cross_4_2(RHO__src(0, 0), RHO__src(0, 1), RHO__src(0, 2),
								RHO__src(0, 3), RHO__src(1, 0), RHO__src(1, 1),
								RHO__src(1, 2), RHO__src(1, 3), RHO__src(2, 0),
								RHO__src(2, 1), RHO__src(2, 2), RHO__src(2, 3));
		dst[3] = RHO__cross_4_3(RHO__src(0, 0), RHO__src(0, 1), RHO__src(0, 2),
								RHO__src(0, 3), RHO__src(1, 0), RHO__src(1, 1),
								RHO__src(1, 2), RHO__src(1, 3), RHO__src(2, 0),
								RHO__src(2, 1), RHO__src(2, 2), RHO__src(2, 3));
		return;
	}

	printf("cross error\n");
}

}