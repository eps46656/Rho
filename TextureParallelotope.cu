#include "define.cuh"
#include "TextureParallelotope.cuh"

#define RHO__throw__local(description)                                         \
	RHO__throw(TextureParallelotope, __func__, description);

namespace rho {

size_t TextureParallelotope::dim() const { return this->dim_; }

size_t TextureParallelotope::size(size_t index) const {
	RHO__debug_if(this->dim_ <= index) RHO__throw__local("index error");

	return this->size_[index].first;
}

size_t TextureParallelotope::total_size() const { return this->total_size_; }

TextureParallelotope::data_t& TextureParallelotope::data() {
	return this->data_;
}

const TextureParallelotope::data_t& TextureParallelotope::data() const {
	return this->data_;
}

#///////////////////////////////////////////////////////////////////////////////

TextureParallelotope& TextureParallelotope::set_size(size_t* size) {
	for (size_t i(0); i != this->dim_; ++i) {
		this->size_[i].second = double_t(this->size_[i].first = size[i]);
	}

	return *this;
}

TextureParallelotope& TextureParallelotope::set_size(size_t index,
													 size_t size) {
	RHO__debug_if(this->dim_ <= index) RHO__throw__local("index error");

	this->size_[index].second = double_t(this->size_[index].first = size);

	return *this;
}

#///////////////////////////////////////////////////////////////////////////////

TextureParallelotope::TextureParallelotope(size_t dim):
	dim_(dim), size_(Malloc<pair<size_t, double_t>>(dim)), data_(dim) {}

TextureParallelotope::~TextureParallelotope() { Free(this->size_); }

#///////////////////////////////////////////////////////////////////////////////

bool TextureParallelotope::Refresh() const { return true; }

#///////////////////////////////////////////////////////////////////////////////

Texture::Data TextureParallelotope::GetData(const Num* root_point,
											const Num* tod_tan) const {
	RHO__debug_if(this->dim_ != root_point.size())
		RHO__throw__local("dim error");

	size_t direct(this->dim_);
	size_t side(0);

	size_t index(0);

	size_t a;

	for (size_t i(0); i != this->dim_; ++i) {
		if (direct == this->dim_) {
			if (root_point[i].eq<-1>()) {
				direct = i;
				side = 0;
				continue;
			} else if (root_point[i].eq<1>()) {
				direct = i;
				side = 1;
				continue;
			}
		}

		if (root_point[i].ge<-1>() && root_point[i].le<1>()) {
			a = size_t(this->size_[i].second * (root_point[i] + 1) / 2);

			(index *= this->size_[i].first) +=
				a < this->size_[i].first ? a : this->size_[i].first - 1;
		} else {
			return this->data_[0][0][0];
		}
	}

	return direct == this->dim_ ? this->data_[0][0][0]
								: this->data_[direct][side][index];
}

}