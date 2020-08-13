#include "Calculus.cuh"
#include "define.cuh"

#define RHO__throw__local(desc) RHO__throw(Vector, __func__, desc)

#define RHO__full_loop for (dim_t i(0); i != RHO__max_dim; ++i)

namespace rho {

dim_t Vector::dim() const { return this->dim_; }

void Vector::set_dim(dim_t dim) {
	RHO__debug_if(RHO__max_dim < dim) RHO__throw__local("dim error");
	this->dim_ = dim;
}

#///////////////////////////////////////////////////////////////////////////////

Vector::Vector(): dim_(0) {}
Vector::Vector(dim_t dim): dim_(dim) {}
Vector::Vector(const Vector& vector): dim_(vector.dim_) { Copy(*this, vector); }

#///////////////////////////////////////////////////////////////////////////////

Vector& Vector::operator=(const Vector& vector) {
	if (this == &vector) { return *this; }
	this->dim_ = vector.dim_;
	Copy(*this, vector);
	return *this;
}

#///////////////////////////////////////////////////////////////////////////////

Num& Vector::operator[](dim_t index) {
	RHO__debug_if(RHO__max_dim < index) RHO__throw__local("index error");
	return this->data[index];
}

const Num& Vector::operator[](dim_t index) const {
	RHO__debug_if(RHO__max_dim < index) RHO__throw__local("index error");
	return this->data[index];
}

Vector Vector::slice(dim_t min_index, dim_t max_index) const& {
	RHO__debug_if(this->dim_ < min_index || this->dim_ < max_index ||
				  max_index < min_index) {
		RHO__throw__local("index error");
	}

	Vector r;
	slice(r, *this, min_index, max_index);
	return r;
}

Vector&& Vector::slice(dim_t min_index, dim_t max_index) && {
	slice(*this, *this, min_index, max_index);
	return Move(*this);
}

void Vector::slice(Vector& dst, const Vector& src, dim_t min_index,
				   dim_t max_index) {
	RHO__debug_if(src.dim_ < min_index || src.dim_ < max_index ||
				  min_index < min_index) {
		RHO__throw__local("index error");
	}

	rho::Copy(dst.dim_ = max_index - min_index, dst, src + min_index);
}

#////////////////////////////////////////////////

Vector& Vector::operator+() & { return *this; }
Vector&& Vector::operator+() && { return Move(*this); }
const Vector& Vector::operator+() const& { return *this; }

Vector Vector::operator-() const& {
	Vector r(this->dim_);

#pragma unroll
	RHO__full_loop { r[i] = -(*this)[i]; }

	return r;
}

Vector&& Vector::operator-() && {
#pragma unroll
	RHO__full_loop(*this)[i] = -(*this)[i];

	return Move(*this);
}

#////////////////////////////////////////////////

bool operator==(const Vector& x, const Vector& y) {
	return (x.dim() == y.dim() && Equal(x.dim(), x, y));
}

bool operator!=(const Vector& x, const Vector& y) { return !(x == y); }

#////////////////////////////////////////////////

Vector operator+(const Vector& x, const Vector& y) {
	RHO__debug_if(x.dim() != y.dim()) RHO__throw__local("dim error");

	Vector r(x.dim());

#pragma unroll
	RHO__full_loop { r[i] = x[i] + y[i]; }

	return r;
}

Vector&& operator+(const Vector& x, Vector&& y) { return Move(y += x); }

Vector&& operator+(Vector&& x, const Vector& y) { return Move(x += y); }

Vector&& operator+(Vector&& x, Vector&& y) { return Move(x += y); }

#////////////////////////////////////////////////

Vector operator-(const Vector& x, const Vector& y) {
	RHO__debug_if(x.dim() != y.dim()) RHO__throw__local("dim error");

	Vector r(x.dim());

#pragma unroll
	RHO__full_loop { r[i] = x[i] - y[i]; }

	return r;
}

Vector&& operator-(const Vector& x, Vector&& y) {
	RHO__debug_if(x.dim() != y.dim()) RHO__throw__local("dim error");

#pragma unroll
	RHO__full_loop { y[i] = x[i] - y[i]; }

	return Move(y);
}

Vector&& operator-(Vector&& x, const Vector& y) { return Move(x -= y); }

Vector&& operator-(Vector&& x, Vector&& y) { return Move(x -= y); }

#////////////////////////////////////////////////

Vector operator*(Num num, const Vector& vector) { return vector * num; }

Vector operator*(const Vector& vector, Num num) {
	Vector r(vector.dim());

#pragma unroll
	RHO__full_loop { r[i] = vector[i] * num; }

	return r;
}

Num operator*(const Vector& x, const Vector& y) {
	RHO__debug_if(x.dim() != y.dim()) RHO__throw__local("dim error");

	Num r(0);
	dot(x.dim(), r, x, y);

	return r;
}

Vector&& operator*(Num num, Vector&& vector) { return Move(vector *= num); }

Vector&& operator*(Vector&& vector, Num num) { return Move(vector *= num); }

#///////////////////////////////////////////////////////////////////////////////

Vector operator/(const Vector& vector, Num num) {
	Vector r(vector.dim());

#pragma unroll
	RHO__full_loop { r[i] = vector[i] / num; }

	return r;
}

Vector&& operator/(Vector&& vector, Num num) { return Move(vector /= num); }

#///////////////////////////////////////////////////////////////////////////////

Vector& Vector::operator+=(const Vector& vector) & {
	RHO__debug_if(this->dim_ != vector.dim_) { RHO__throw__local("dim error"); }
	iadd(*this, vector);
	return *this;
}

Vector& Vector::operator-=(const Vector& vector) & {
	RHO__debug_if(this->dim_ != vector.dim_) { RHO__throw__local("dim error"); }
	isub(*this, vector);
	return *this;
}

Vector& Vector::operator*=(Num num) & {
	imul(*this, num);
	return *this;
}

Vector& Vector::operator/=(Num num) & {
	idiv(*this, num);
	return *this;
}

#///////////////////////////////////////////////////////////////////////////////

Print operator<<(Print p, const Vector& vector) {
	if (!vector.dim()) { Print() << "( void vector )\n"; }

	Print() << "( ", vector[0];

	for (dim_t i(1); i != vector.dim(); ++i) { Print() << ", ", vector[i]; }

	return Print() << " )\n";
}

#///////////////////////////////////////////////////////////////////////////////

bool Vector::is_zero() const {
	for (dim_t i(0); i != this->dim_; ++i) {
		if ((*this)[i].ne<0>()) { return false; }
	}

	return true;
}

#///////////////////////////////////////////////////////////////////////////////

bool is_zero(dim_t dim, const Num* src) {
	for (dim_t i(0); i != dim; ++i) {
		if (src[i].ne<0>()) { return false; }
	}

	return true;
}

void Vector::set_length(Num length) {
	Num l(sqrt(sq(this->dim(), *this)));

	RHO__debug_if(l.eq<0>()) RHO__throw__local("zero div");

	Num a(length / l);

#pragma unroll
	RHO__full_loop { (*this)[i] *= a; }
}

void Vector::set_sq(Num sq) { this->set_length(sqrt(sq)); }

#///////////////////////////////////////////////////////////////////////////////

Num sq(const Vector& vector) { return sq(vector.dim(), vector); }

Num abs(const Vector& vector) { return sqrt(sq(vector.dim(), vector)); }

Num dist(const Vector& x, const Vector& y) { return sqrt(dist_sq(x, y)); }

Num dist_sq(const Vector& x, const Vector& y) {
	RHO__debug_if(x.dim() != y.dim()) RHO__throw__local("dim error");

	Num r(0);
	dist_sq(x.dim(), r, x, y);
	return r;
}

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

void Vector::add(Num* dst, const Num* x, const Num* y) {
#pragma unroll
	RHO__full_loop { dst[i] = x[i] + y[i]; }
}

void Vector::sub(Num* dst, const Num* x, const Num* y) {
#pragma unroll
	RHO__full_loop { dst[i] = x[i] + y[i]; }
}

void Vector::mul(Num* dst, const Num* x, const Num& t) {
#pragma unroll
	RHO__full_loop { dst[i] = x[i] * t; }
}

void Vector::sub(Num* dst, const Num* x, const Num& t) { mul(dst, x, 1 / t); }

void Vector::iadd(Num* dst, const Num* x) {
#pragma unroll
	RHO__full_loop { dst[i] += x[i]; }
}

void Vector::isub(Num* dst, const Num* x) {
#pragma unroll
	RHO__full_loop { dst[i] -= x[i]; }
}

void Vector::imul(Num* dst, Num t) {
#pragma unroll
	RHO__full_loop { dst[i] *= t; }
}

void Vector::idiv(Num* dst, Num t) { imul(dst, 1 / t); }

#///////////////////////////////////////////////////////////////////////////////

Num angle_sin(const Vector& x, const Vector& y) {
	return sqrt(angle_sin_sq(x, y));
}

Num angle_sin_sq(const Vector& x, const Vector& y) {
	return 1 - angle_cos_sq(x, y);
}

Num angle_cos(const Vector& x, const Vector& y) {
	RHO__debug_if(x.dim() != y.dim()) { RHO__throw__local("dim error"); }
	return angle_cos(x.dim(), x, y);
}

Num angle_cos_sq(const Vector& x, const Vector& y) {
	RHO__debug_if(x.dim() != y.dim()) { RHO__throw__local("dim error"); }
	return angle_cos_sq(x.dim(), x, y);
}

Num angle_sin(dim_t dim, const Num* x, const Num* y) {
	return sqrt(angle_sin_sq(dim, x, y));
}

Num angle_cos(dim_t dim, const Num* x, const Num* y) {
	Num x_sq, dot, y_sq;
	sq__dot__sq(dim, x_sq, dot, y_sq, x, y);

	RHO__debug_if(x_sq.eq<0>() || y_sq.eq<0>()) RHO__throw__local("zero div");

	return dot / sqrt(x_sq * y_sq);
}

Num angle_sin_sq(dim_t dim, const Num* x, const Num* y) {
	return 1 - angle_cos_sq(dim, x, y);
}

Num angle_cos_sq(dim_t dim, const Num* x, const Num* y) {
	Num x_sq, dot, y_sq;
	sq__dot__sq(dim, x_sq, dot, y_sq, x, y);

	RHO__debug_if(x_sq.eq<0>() || y_sq.eq<0>()) RHO__throw__local("zero div");

	return sq(dot) / (x_sq * y_sq);
}

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

Num sq(dim_t dim, const Num* src) {
	RHO__debug_if(!dim) RHO__throw(, __func__, "dim error");

	if (dim == 3) { return sq(src[0]) + sq(src[1]) + sq(src[2]); }

	Num r(0);
	for (dim_t i(0); i != dim; ++i) { r += sq(src[i]); }
	return r;
}

Num abs(dim_t dim, const Num* src) { return sqrt(sq(dim, src)); }

Num dot(dim_t dim, const Num* x, const Num* y) {
	Num r(0);
	dot(dim, r, x, y);
	return r;
}

void dot(dim_t dim, Num& dst, const Num* x, const Num* y) {
	RHO__debug_if(!dim) RHO__throw(, __func__, "dim error");

	if (dim == 3) {
		dst += x[0] * y[0] + x[1] * y[1] + x[2] * y[2];
		return;
	}

	for (dim_t i(0); i != dim; ++i) { dst += x[i] * y[i]; }
}

Num dist_sq(dim_t dim, const Num* x, const Num* y) {
	Num r(0);
	dist_sq(dim, r, x, y);
	return r;
}

void dist_sq(dim_t dim, Num& dst, const Num* x, const Num* y) {
	RHO__debug_if(!dim) RHO__throw(, __func__, "dim error");

	for (dim_t i(0); i != dim; ++i) { dst += sq(x[i] - y[i]); }
}

void sq__dot__sq(dim_t dim, Num& dst_x_sq, Num& dst_dot, Num& dst_y_sq,
				 const Num* x, const Num* y) {
	RHO__debug_if(!dim) RHO__throw(, __func__, "dim error");

	dst_x_sq = sq(x[0]);
	dst_dot = x[0] * y[0];
	dst_y_sq = sq(y[0]);

	for (dim_t i(1); i != dim; ++i) {
		dst_x_sq += sq(x[i]);
		dst_dot += x[i] * y[i];
		dst_y_sq += sq(y[i]);
	}
}

}