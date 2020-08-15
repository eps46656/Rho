#ifndef RHO__define_guard__TextureParallelotope_cuh
#define RHO__define_guard__TextureParallelotope_cuh

#include "Kernel/Kernel.cuh"

namespace rho {

struct TextureParallelotope: public Texture {
	using data_t = cntr::Vector<Array_t<cntr::Vector<Data>, 2>>;

	RHO__cuda size_t dim() const;
	RHO__cuda size_t size(size_t index) const;
	RHO__cuda size_t total_size() const;

	RHO__cuda data_t& data();
	RHO__cuda const data_t& data() const;

	RHO__cuda TextureParallelotope& set_size(size_t* size);
	RHO__cuda TextureParallelotope& set_size(size_t index, size_t size);

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda TextureParallelotope(size_t dim);
	RHO__cuda ~TextureParallelotope();

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda bool Refresh() const override;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Data GetData(const Num* root_point,
						   const Num* tod_tan) const override;

private:
	const size_t dim_;
	pair<size_t, double_t>* size_;
	size_t total_size_;

	data_t data_;
};

}

#endif