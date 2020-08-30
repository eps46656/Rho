#ifndef RHO__define_guard__TextureParallelotopeTiling_cuh
#define RHO__define_guard__TextureParallelotopeTiling_cuh

#include "Kernel/Kernel.cuh"

namespace rho {

struct TextureParallelotopeTiling: public Texture {
	RHO__cuda size_t dim() const;
	RHO__cuda size_t size(size_t index) const;

	RHO__cuda cntr::Vector<Texture::Data>& data();
	RHO__cuda const cntr::Vector<Texture::Data>& data() const;

	RHO__cuda TextureParallelotopeTiling& set_size(size_t* size);
	RHO__cuda TextureParallelotopeTiling& set_size(size_t index, size_t size);

	RHO__cuda const Space* ref() const;
	RHO__cuda void set_ref(const Space* ref);

#////////////////////////////////////////////////

	RHO__cuda TextureParallelotopeTiling(size_t dim);
	RHO__cuda ~TextureParallelotopeTiling();

#////////////////////////////////////////////////

	RHO__cuda bool Refresh() const override;

#////////////////////////////////////////////////

	RHO__cuda Data GetData(const Num* root_point,
						   const Num* tod_tan) const override;

private:
	const size_t dim_;
	pair<size_t, Num> size_[RHO__max_dim];

	cntr::Vector<Data> data_;

	const Space* ref_;
};

}

#endif