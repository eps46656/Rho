#ifndef RHO__define_guard__Kernel__ComponentContainer_cuh
#define RHO__define_guard__Kernel__ComponentContainer_cuh

#include "init.cuh"

namespace rho {

struct ComponentContainerCmp {
	RHO__cuda bool operator()(const Component* x, const Component* y) const;
};

}

#endif