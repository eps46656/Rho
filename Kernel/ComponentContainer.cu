#include "define.cuh"
#include "Kernel.cuh"

namespace rho {

bool ComponentContainerCmp::operator()(const Component* x,
									   const Component* y) const {
	return x < y;
}

}