#include"define.cuh"
#include"Kernel.cuh"

namespace rho {

bool Texture::Data::Check()const {
	return
		this->color[0].ge<0>() &&
		this->color[1].ge<0>() &&
		this->color[2].ge<0>() &&

		this->transmittance[0].ge<0>() &&
		this->transmittance[1].ge<0>() &&
		this->transmittance[2].ge<0>() &&

		this->reflectance[0].ge<0>() &&
		this->reflectance[1].ge<0>() &&
		this->reflectance[2].ge<0>() &&

		this->shininess[0].ge<0>() &&
		this->shininess[1].ge<0>() &&
		this->shininess[2].ge<0>();
}

}