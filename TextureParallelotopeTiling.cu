#include "define.cuh"
#include "TextureParallelotopeTiling.cuh"

#define RHO__throw__local(description)                                         \
	RHO__throw(TextureParallelotopeTiling, __func__, description);

namespace rho {

size_t TextureParallelotopeTiling::dim() const { return this->dim_; }

size_t TextureParallelotopeTiling::size(size_t index) const {
	RHO__debug_if(this->dim_ <= index) { RHO__throw__local("index error"); }
	return this->size_[index].first;
}

cntr::Vector<Texture::Data>& TextureParallelotopeTiling::data() {
	return this->data_;
}

const cntr::Vector<Texture::Data>& TextureParallelotopeTiling::data() const {
	return this->data_;
}

#////////////////////////////////////////////////

TextureParallelotopeTiling& TextureParallelotopeTiling::set_size(size_t* size) {
	for (size_t i(0); i != this->dim_; ++i) {
		this->size_[i].second = (this->size_[i].first = size[i]);
	}

	return *this;
}

TextureParallelotopeTiling& TextureParallelotopeTiling::set_size(size_t index,
																 size_t size) {
	RHO__debug_if(this->dim_ <= index) RHO__throw__local("index error");

	this->size_[index].second = (this->size_[index].first = size);

	return *this;
}

const Space* TextureParallelotopeTiling::ref() const { return this->ref_; }

void TextureParallelotopeTiling::set_ref(const Space* ref) { this->ref_ = ref; }

#////////////////////////////////////////////////

TextureParallelotopeTiling::TextureParallelotopeTiling(size_t dim): dim_(dim) {}

TextureParallelotopeTiling::~TextureParallelotopeTiling() {}

#////////////////////////////////////////////////

bool TextureParallelotopeTiling::Refresh() const {
	return this->ref_->Refresh();
}

#////////////////////////////////////////////////

Texture::Data TextureParallelotopeTiling::GetData(const Num* root_point,
												  const Num* tod_tan) const {
	Vec point;

	this->ref_->MapPointFromRoot_rs(point, root_point);

	size_t index(0);
	Num a;

	for (size_t i(0); i != this->dim_; ++i) {
		a = (point[i] + 1) / 2;
		a -= floor(a);

		(index *= this->size_[i].first) += size_t(this->size_[i].second * a);
	}

	return this->data_[index];
}

}