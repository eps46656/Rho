#include"define.cuh"
#include"Kernel.cuh"

namespace rho {

bool Material::Check()const {
	return
		this->refraction_index.ge<1>() &&

		this->transmittance[0].ge<0>() &&
		this->transmittance[1].ge<0>() &&
		this->transmittance[2].ge<0>() &&

		this->transmittance[0].le<1>() &&
		this->transmittance[1].le<1>() &&
		this->transmittance[2].le<1>();
}

}