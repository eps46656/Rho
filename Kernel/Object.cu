#include "define.cuh"
#include "Kernel.cuh"

#define RHO__throw__local(desc) RHO__throw(Object, __func__, desc)

namespace rho {

const Space* Object::ref() const { return this->ref_; }
const Space* Object::root() const { return this->ref_->root(); }

dim_t Object::root_dim() const { return this->ref_->root_dim(); }

#///////////////////////////////////////////////////////////////////////////////

Object::Object(const Space* ref): ref_(ref) {}
Object::~Object() {}

#///////////////////////////////////////////////////////////////////////////////

Object* Object::set_ref(const Space* ref) {
	this->ref_ = ref;
	return this;
}

}