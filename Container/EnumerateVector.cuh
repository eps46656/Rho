#ifndef RHO__define_guard__Container__EnumerateVector_cuh
#define RHO__define_guard__Container__EnumerateVector_cuh

#include "../define.cuh"
#include "../Base/memory.cuh"
#include "Vector.cuh"

namespace rho {
namespace cntr {

template<typename T> class EnumerateVector: public Vector<T> {
public:
	template<typename... Args>
	EnumerateVector(Args&&... args): Vector<T>(sizeof...(args)) {
		Assign<sizeof...(args)>(*this, Forward<Args>(args)...);
	}
};

}
}

#endif