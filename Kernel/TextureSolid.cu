#include "define.cuh"
#include "Kernel.cuh"

namespace rho {

TextureSolid::TextureSolid() {}
TextureSolid::TextureSolid(const Data& data): data(data) {}

#///////////////////////////////////////////////////////////////////////////////

Texture::Data TextureSolid::GetData(const Num* root_point,
									const Num* tod_tan) const {
	return this->data;
}

#///////////////////////////////////////////////////////////////////////////////

bool TextureSolid::Refresh() const { return this->data.Check(); }

}