#ifndef RHO__define_guard__Kernel__Object_cuh
#define RHO__define_guard__Kernel__Object_cuh

#include "init.cuh"
#include "Component.cuh"
#include "ComponentContainer.cuh"

namespace rho {

class Object {
public:
	RHO__cuda const Space* ref() const;
	RHO__cuda const Space* root() const;

	RHO__cuda dim_t root_dim() const;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Object(const Space* ref = nullptr);
	RHO__cuda ~Object();

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Object* set_ref(const Space* ref);

private:
	const Space* ref_;
};

}

#endif