#ifndef RHO__define_guard__Kernel__DomainSole_cuh
#define RHO__define_guard__Kernel__DomainSole_cuh

#include "init.cuh"
#include "Domain.cuh"

namespace rho {

class DomainSole: public Domain {
public:
	RHO__cuda Space* root()const override;
	RHO__cuda Space* ref() const;

	RHO__cuda dim_t dim_s() const;
	RHO__cuda dim_t dim_cr() const;

	RHO__cuda void set_ref(Space* ref);

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda DomainSole(Space* ref);

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda virtual bool Contain(const Num* root_point) const override;
	RHO__cuda virtual bool Contain_s(const Num* point) const = 0;

private:
	Space* ref_;
};

}

#endif