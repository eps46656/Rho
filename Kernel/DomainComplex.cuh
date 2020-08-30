#ifndef RHO__define_guard__Kernel__DomainComplex_cuh
#define RHO__define_guard__Kernel__DomainComplex_cuh

#include "init.cuh"
#include "Domain.cuh"

namespace rho {

class DomainComplex: public Domain {
public:
	RHO__cuda DomainComplex();
};

}

#endif