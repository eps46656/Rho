#ifndef RHO__define_guard__Calculus__Matrix_cuh
#define RHO__define_guard__Calculus__Matrix_cuh

#include "init.cuh"

namespace rho {

using NumMatrix = Num[RHO__max_dim_sq];

struct Matrix_ {
	Num data[RHO__max_dim_sq];

	RHO__cuda operator Num*() { return this->data; }
	RHO__cuda operator const Num*() const { return this->data; }
};

class Matrix: public Matrix_ {
public:
	template<typename Dst, typename Src>
	RHO__cuda static void Copy(Dst&& dst, Src&& src) {
		rho::Copy<RHO__max_dim_sq>(Forward<Dst>(dst), Forward<Src>(src));
	}

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda dim_t col_dim() const;
	RHO__cuda dim_t row_dim() const;

	RHO__cuda void set_col_dim(dim_t col_dim);
	RHO__cuda void set_row_dim(dim_t row_dim);
	RHO__cuda void set_dim(dim_t col_dim, dim_t row_dim);

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Matrix();
	RHO__cuda Matrix(dim_t col_dim, dim_t row_dim);
	RHO__cuda Matrix(const Matrix& matrix);

#///////////////////////////////////////////////////////////////////////////////

	template<dim_t col_dim, dim_t row_dim, typename... Args>
	RHO__cuda static Matrix Make(Args&&... args) {
		static_assert(col_dim <= RHO__max_dim && row_dim <= RHO__max_dim &&
						  col_dim * row_dim == sizeof...(args),
					  "dim error");
		Matrix r(col_dim, row_dim);
		Assign2D<col_dim, row_dim, RHO__max_dim>(r, Forward<Args>(args)...);
		return r;
	}

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda static void identity(Matrix& dst, dim_t dim);
	RHO__cuda static void identity(Num* dst);
	RHO__cuda static void identity(Num* dst, dim_t dim);

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Matrix& operator=(const Matrix& matrix);

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Num& operator[](dim_t index);
	RHO__cuda const Num& operator[](dim_t index) const;

	RHO__cuda Num& get(dim_t col_index, dim_t row_index);
	RHO__cuda const Num& get(dim_t col_index, dim_t row_index) const;

	RHO__cuda Matrix slice(dim_t max_col_index, dim_t max_row_index) const&;

	RHO__cuda Matrix&& slice(dim_t max_col_index, dim_t max_row_index) &&;

	RHO__cuda Matrix slice(dim_t min_col_index, dim_t min_row_index,
						   dim_t max_col_index, dim_t max_row_index) const&;

	RHO__cuda Matrix&& slice(dim_t min_col_index, dim_t min_row_index,
							 dim_t max_col_index, dim_t max_row_index) &&;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda void static slice(Matrix& dst, const Matrix& src,
								dim_t max_col_index, dim_t max_row_index);

	RHO__cuda void static slice(Matrix& dst, const Matrix& src,
								dim_t min_col_index, dim_t min_row_index,
								dim_t max_col_index, dim_t max_row_index);

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Matrix& operator+() &;
	RHO__cuda Matrix&& operator+() &&;
	RHO__cuda const Matrix& operator+() const&;
	RHO__cuda Matrix operator-() const&;
	RHO__cuda Matrix& operator-() &&;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Matrix& operator+=(const Matrix& matrix) &;
	RHO__cuda Matrix& operator-=(const Matrix& matrix) &;

	RHO__cuda Matrix& operator*=(Num num) &;
	RHO__cuda Matrix& operator*=(const Matrix& matrix) &;

	RHO__cuda Matrix& operator/=(Num num) &;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda static void Print(dim_t col_dim, dim_t row_dim, const Num* data);

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Matrix transpose() const&;
	RHO__cuda Matrix&& transpose() &&;
	RHO__cuda Matrix& transpose_self();

	RHO__cuda Num det() const;

	RHO__cuda Matrix inverse() const;

	RHO__cuda Vector cross() const;

private:
	dim_t col_dim_;
	dim_t row_dim_;
};

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

RHO__cuda bool operator==(const Matrix& x, const Matrix& y);
RHO__cuda bool operator!=(const Matrix& x, const Matrix& y);

RHO__cuda Matrix operator+(const Matrix& x, const Matrix& y);
RHO__cuda Matrix&& operator+(const Matrix& x, Matrix&& y);
RHO__cuda Matrix&& operator+(Matrix&& x, const Matrix& y);
RHO__cuda Matrix&& operator+(Matrix&& x, Matrix&& y);

RHO__cuda Matrix operator-(const Matrix& x, const Matrix& y);
RHO__cuda Matrix&& operator-(const Matrix& x, Matrix&& y);
RHO__cuda Matrix&& operator-(Matrix&& x, const Matrix& y);
RHO__cuda Matrix&& operator-(Matrix&& x, Matrix&& y);

RHO__cuda Matrix operator*(Num num, const Matrix& matrix);
RHO__cuda Matrix operator*(const Matrix& matrix, Num num);
RHO__cuda Vector operator*(const Vector& vector, const Matrix& matrix);
RHO__cuda Matrix operator*(const Matrix& x, const Matrix& y);

RHO__cuda Matrix&& operator*(Num num, Matrix&& matrix);
RHO__cuda Matrix&& operator*(Matrix&& matrix, Num num);

RHO__cuda Matrix operator/(const Matrix& matrix, Num num);
RHO__cuda Matrix&& operator/(Matrix&& matrix, Num num);

RHO__cuda Print operator<<(Print p, const Matrix& matrix);

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

RHO__cuda void identity(Num* dst, dim_t dim);

RHO__cuda void dot(dim_t col_dim, dim_t row_dim, Num* dst, const Num* v,
				   const Num* m);

RHO__cuda void dot(dim_t x_col_dim, dim_t y_col_dim, dim_t y_row_dim, Num* dst,
				   const Num* x, const Num* y);

#///////////////////////////////////////////////////////////////////////////////

RHO__cuda Num det(const Num* src, dim_t size);
RHO__cuda void inverse(dim_t dim, Num* dst, const Num* src);
RHO__cuda void cross(Num* dst, const Num* src, dim_t size);

}

#endif
