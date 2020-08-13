#ifndef RHO__define_guard__Calculus__Double_cuh
#define RHO__define_guard__Calculus__Double_cuh

#include "init.cuh"

namespace rho {

struct Double {
	double_t value;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Double() {}
	RHO__cuda Double(const Double& x): value(x.value) {}
	RHO__cuda Double(double_t x): value(x) {}

	RHO__cuda explicit operator double_t() const { return this->value; }
	RHO__cuda explicit operator size_t() const {
		return static_cast<size_t>(this->value);
	}
	RHO__cuda explicit operator int() const {
		return static_cast<int>(this->value);
	}

	template<typename T> RHO__cuda Double& operator=(const T& x) {
		this->value = static_cast<double_t>(x);
		return *this;
	}
	RHO__cuda Double& operator=(Double x) {
		this->value = x.value;
		return *this;
	}

#///////////////////////////////////////////////////////////////////////////////

	template<int x> RHO__cuda bool lt() const {
		return this->value < (x - RHO__eps);
	}

	template<int x> RHO__cuda bool gt() const {
		return (x + RHO__eps) < this->value;
	}

	template<int x> RHO__cuda bool eq() const {
		return !this->lt<x>() && !this->gt<x>();
	}

	template<int x> RHO__cuda bool ne() const { return !this->eq<x>(); }

	template<int x> RHO__cuda bool le() const { return !this->gt<x>(); }
	template<int x> RHO__cuda bool ge() const { return !this->lt<x>(); }

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Double operator+() const { return this->value; }
	RHO__cuda Double operator-() const { return -this->value; }

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Double& operator+=(Double x) & {
		this->value += x.value;
		return *this;
	}

	RHO__cuda Double& operator-=(Double x) & {
		this->value -= x.value;
		return *this;
	}

	RHO__cuda Double& operator*=(Double x) & {
		this->value *= x.value;
		return *this;
	}

	RHO__cuda Double& operator/=(Double x) & {
		this->value /= x.value;
		return *this;
	}
};

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

#define RHO__F RHO__cuda inline Double

RHO__F operator+(Double x, Double y) { return x.value + y.value; }
RHO__F operator-(Double x, Double y) { return x.value - y.value; }
RHO__F operator*(Double x, Double y) { return x.value * y.value; }
RHO__F operator/(Double x, Double y) { return x.value / y.value; }

#undef RHO__F

#///////////////////////////////////////////////////////////////////////////////

#define RHO__F RHO__cuda inline bool

RHO__F operator==(Double x, Double y) { return (x - y).eq<0>(); }
RHO__F operator!=(Double x, Double y) { return (x - y).ne<0>(); }

RHO__F operator<(Double x, Double y) { return (x - y).lt<0>(); }
RHO__F operator<=(Double x, Double y) { return (x - y).le<0>(); }
RHO__F operator>(Double x, Double y) { return (x - y).gt<0>(); }
RHO__F operator>=(Double x, Double y) { return (x - y).ge<0>(); }

#undef RHO__F

#///////////////////////////////////////////////////////////////////////////////

RHO__cuda inline Print operator<<(Print p, Double x) {
	return Print() << x.value;
}

#///////////////////////////////////////////////////////////////////////////////

RHO__cuda inline double_t sq(double_t x) { return x * x; }
RHO__cuda inline double_t sqrt(double_t x) { return ::sqrt(x); }

RHO__cuda inline Double sq(Double x) { return sq(x.value); }
RHO__cuda inline Double sqrt(Double x) { return ::sqrt(x.value); }

#///////////////////////////////////////////////////////////////////////////////

RHO__cuda inline Double abs(Double x) { return ::abs(x.value); }
RHO__cuda inline Double floor(Double x) { return ::floor(x.value); }
RHO__cuda inline Double ceil(Double x) { return ::ceil(x.value); }

RHO__cuda inline Double pow(Double base, Double exponent) {
	return ::pow(base.value, exponent.value);
}

#///////////////////////////////////////////////////////////////////////////////

RHO__cuda inline void swap(Double& x, Double& y) {
	const double_t temp(x.value);
	x.value = y.value;
	y.value = temp;
}

}

#undef RHO__eps

#endif