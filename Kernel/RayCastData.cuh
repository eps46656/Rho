#ifndef RHO__define_guard__Kernel__RayCastData_cuh
#define RHO__define_guard__Kernel__RayCastData_cuh

#include "init.cuh"

namespace rho {

struct RayCastDataCore {
	struct Phase {
		int value;

		RHO__cuda Phase(int value = 0);
		RHO__cuda Phase(bool fr, bool to);

		RHO__cuda bool fr() const;
		RHO__cuda bool to() const;

		RHO__cuda void fr(bool fr);
		RHO__cuda void to(bool to);

		RHO__cuda void set(bool fr, bool to);

		RHO__cuda void reverse();
	};

	const Domain* domain;

	Num t;
	Phase phase;

	RHO__cuda virtual ~RayCastDataCore();
};

RHO__cuda bool operator==(const RayCastData& x, const RayCastData& y);
RHO__cuda bool operator==(const RayCastData& x, Num t);
RHO__cuda bool operator==(Num t, const RayCastData& x);

RHO__cuda bool operator<(const RayCastData& x, const RayCastData& y);
RHO__cuda bool operator<(Num t, const RayCastData& x);
RHO__cuda bool operator<(const RayCastData& x, Num t);
RHO__cuda bool operator<=(const RayCastData& x, const RayCastData& y);
RHO__cuda bool operator<=(Num t, const RayCastData& x);
RHO__cuda bool operator<=(const RayCastData& x, Num t);

}

#endif