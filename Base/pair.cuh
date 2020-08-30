#ifndef RHO__define_guard__Base__pair_cuh
#define RHO__define_guard__Base__pair_cuh

#include "../define.cuh"

namespace rho {

template<typename T1, typename T2 = T1> struct pair {
	T1 first;
	T2 second;

	RHO__cuda pair(){};

	template<typename Y1, typename Y2>
	RHO__cuda pair(Y1&& first_, Y2&& second_):
		first(Forward<Y1>(first_)), second(Forward<Y2>(second_)) {}
};

}

#endif