#ifndef RHO__define_guard__Kernel__Texture_cuh
#define RHO__define_guard__Kernel__Texture_cuh

#include "init.cuh"

namespace rho {

class Texture {
public:
	struct Data {
		Num3 color;
		Num3 transmittance;
		Num3 reflectance;
		Num3 shininess;

		RHO__cuda bool Check() const;
	};

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda virtual bool Refresh() const = 0;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda virtual Data GetData(const Num* root_point,
								   const Num* tod_tan) const = 0;
};

}

#endif