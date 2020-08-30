#ifndef RHO__define_guard__Kernel__TextureSolid_cuh
#define RHO__define_guard__Kernel__TextureSolid_cuh

#include "init.cuh"
#include "Texture.cuh"

namespace rho {

class TextureSolid: public Texture {
public:
	Data data;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda TextureSolid();
	RHO__cuda TextureSolid(const Data& data);

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda bool Refresh() const override;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Data GetData(const Num* root_point,
						   const Num* tod_tan) const override;
};

}

#endif