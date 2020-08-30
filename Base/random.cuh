#ifndef RHO__define_guard__Function__Random_cuh
#define RHO__define_guard__Function__Random_cuh

#include <cstdlib>
#include <ctime>
#include "../define.cuh"
#include "memory.cuh"

namespace rho {

inline bool rand_init_() {
	std::srand((unsigned int)time(nullptr));
	return true;
}

inline int rand() {
	static int init(rand_init_());
	return std::rand();
}

template<typename Iter, typename Swap_t>
void shuffle(Iter x, size_t size,
			 Swap_t swap = Swap<rho::RmRef_t<decltype(x[0])>>()) {
	for (size_t time(0); time != 2; ++time) {
		for (size_t i(0); i != size; ++i) {
			size_t a(rand() % size);

			if (i != a) { swap(x[i], x[a]); }
		}
	}
}

}

#endif