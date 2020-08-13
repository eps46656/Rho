#ifndef RHO__define_guard__Base__triple_cuh
#define RHO__define_guard__Base__triple_cuh

#include"../define.cuh"

namespace rho {

template<typename T1, typename T2 = T1, typename T3 = T2>
struct triple {
	T1 first;
	T2 second;
	T3 third;

	RHO__cuda triple() {}

	template<typename Y1, typename Y2, typename Y3>
	RHO__cuda triple(Y1&& first_, Y2&& second_, Y3&& third_) :
		first(Forward<Y1>(first_)),
		second(Forward<Y2>(second_)),
		third(Forward<Y3>(third_)) {}
};

}

#endif