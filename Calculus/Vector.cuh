#ifndef RHO__define_guard__Calculus__Vector_cuh
#define RHO__define_guard__Calculus__Vector_cuh

#include "init.cuh"
#include "Double.cuh"

namespace rho {

using NumVector = Num[RHO__max_dim];

struct Vector_ {
	Num data[RHO__max_dim];

	RHO__cuda operator Num*() { return this->data; }
	RHO__cuda operator const Num*() const { return this->data; }
};

class Vector: public Vector_ {
public:
	template<typename Dst, typename Src>
	RHO__cuda static void Copy(Dst&& dst, Src&& src) {
		rho::Copy<RHO__max_dim>(Forward<Dst>(dst), Forward<Src>(src));
	}

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda dim_t dim() const;
	RHO__cuda void set_dim(dim_t dim);

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Vector();
	RHO__cuda explicit Vector(dim_t dim);
	RHO__cuda Vector(const Vector& vector);

#///////////////////////////////////////////////////////////////////////////////

	template<dim_t dim, typename... Args>
	RHO__cuda static Vector Make(Args&&... args) {
		static_assert(dim <= RHO__max_dim, "dim error");
		Vector r(dim);
		rho::Assign<dim>(r, Forward<Args>(args)...);
		return r;
	}

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Vector& operator=(const Vector& vector);

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Num& operator[](dim_t index);
	RHO__cuda const Num& operator[](dim_t index) const;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Vector slice(dim_t min_index, dim_t max_index) const&;
	RHO__cuda Vector&& slice(dim_t min_index, dim_t max_index) &&;

	RHO__cuda static void slice(Vector& dst, const Vector& src, dim_t min_index,
								dim_t max_index);

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Vector& operator+() &;
	RHO__cuda Vector&& operator+() &&;
	RHO__cuda const Vector& operator+() const&;
	RHO__cuda Vector operator-() const&;
	RHO__cuda Vector&& operator-() &&;

	RHO__cuda Vector& operator+=(const Vector& vector) &;
	RHO__cuda Vector& operator-=(const Vector& vector) &;
	RHO__cuda Vector& operator*=(Num num) &;
	RHO__cuda Vector& operator/=(Num num) &;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda bool is_zero() const;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda void set_length(Num length);

	RHO__cuda void set_sq(Num sq);

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda static void add(Num* dst, const Num* x, const Num* y);
	RHO__cuda static void sub(Num* dst, const Num* x, const Num* y);
	RHO__cuda static void mul(Num* dst, const Num* x, const Num& t);
	RHO__cuda static void sub(Num* dst, const Num* x, const Num& t);

	RHO__cuda static void iadd(Num* dst, const Num* x);
	RHO__cuda static void isub(Num* dst, const Num* x);
	RHO__cuda static void imul(Num* dst, Num t);
	RHO__cuda static void idiv(Num* dst, Num t);

#///////////////////////////////////////////////////////////////////////////////

private:
	dim_t dim_;
};

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

RHO__cuda bool operator==(const Vector& x, const Vector& y);
RHO__cuda bool operator!=(const Vector& x, const Vector& y);

#///////////////////////////////////////////////////////////////////////////////

RHO__cuda Vector operator+(const Vector& x, const Vector& y);
RHO__cuda Vector&& operator+(const Vector& x, Vector&& y);
RHO__cuda Vector&& operator+(Vector&& x, const Vector& y);
RHO__cuda Vector&& operator+(Vector&& x, Vector&& y);

RHO__cuda Vector operator-(const Vector& x, const Vector& y);
RHO__cuda Vector&& operator-(const Vector& x, Vector&& y);
RHO__cuda Vector&& operator-(Vector&& x, const Vector& y);
RHO__cuda Vector&& operator-(Vector&& x, Vector&& y);

RHO__cuda Vector operator*(Num num, const Vector& vector);
RHO__cuda Vector operator*(const Vector& vector, Num num);
RHO__cuda Num operator*(const Vector& x, const Vector& y);

RHO__cuda Vector&& operator*(Num num, Vector&& vector);
RHO__cuda Vector&& operator*(Vector&& vector, Num num);

RHO__cuda Vector operator/(const Vector& vector, Num num);
RHO__cuda Vector&& operator/(Vector&& vector, Num num);

#///////////////////////////////////////////////////////////////////////////////

RHO__cuda Print operator<<(Print p, const Vector& vector);

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

RHO__cuda bool is_zero(dim_t size, const Num* src);

RHO__cuda Num sq(dim_t size, const Num* src);
RHO__cuda Num abs(dim_t dim, const Num* src);

RHO__cuda Num dot(dim_t size, const Num* x, const Num* y);
RHO__cuda void dot(dim_t size, Num& dst, const Num* x, const Num* y);

RHO__cuda Num dist_sq(dim_t size, const Num* x, const Num* y);
RHO__cuda void dist_sq(dim_t size, Num& dst, const Num* x, const Num* y);

RHO__cuda void sq__dot__sq(dim_t size, Num& d_x_sq, Num& d_dot, Num& d_y_sq,
						   const Num* x, const Num* y);

RHO__cuda Num sq(const Vector& vector);
RHO__cuda Num abs(const Vector& vector);

RHO__cuda Num dist(const Vector& x, const Vector& y);
RHO__cuda Num dist_sq(const Vector& x, const Vector& y);

RHO__cuda Num angle_sin(dim_t dim, const Num* x, const Num* y);
RHO__cuda Num angle_cos(dim_t dim, const Num* x, const Num* y);
RHO__cuda Num angle_sin_sq(dim_t dim, const Num* x, const Num* y);
RHO__cuda Num angle_cos_sq(dim_t dim, const Num* x, const Num* y);

RHO__cuda Num angle_cos(const Vector& x, const Vector& y);
RHO__cuda Num angle_sin(const Vector& x, const Vector& y);
RHO__cuda Num angle_cos_sq(const Vector& x, const Vector& y);
RHO__cuda Num angle_sin_sq(const Vector& x, const Vector& y);

}

#endif