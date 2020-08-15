#include "define.cuh"
#include "Kernel.cuh"

namespace rho {

bool Component::PriorityCmp::operator()(const Component* x,
										const Component* y) {
	return x->active_ && (!y->active_ || x->priority_ > y->priority_);
}

#///////////////////////////////////////////////////////////////////////////////

bool Component::active() const { return this->active_; }
bool Component::latest() const { return this->latest_; }

priority_t Component::priority() const { return this->priority_; }

Space* Component::root() const { return this->object_->root(); }
Object* Component::object() const { return this->object_; }

size_t Component::dim_r() const { return this->object_->root()->dim_r(); }

#///////////////////////////////////////////////////////////////////////////////

Component::Component(Type type, Object* object):
	type(type), active_(true), latest_(false), object_(object) {
	if (this->object_) { this->object_->AddCmpt_(this); }
}

Component::~Component() {
	if (this->object_) { this->object_->SubCmpt_(this); }
}

#///////////////////////////////////////////////////////////////////////////////

void Component::SetLatestFalse_() { this->latest_ = false; }

#///////////////////////////////////////////////////////////////////////////////

Component* Component::SetObject(Object* object) {
	if (this->object_ == object) { return this; }
	if (this->object_) { this->object_->SubCmpt_(this); }
	if (this->object_ = object) { this->object_->AddCmpt_(this); }
	return this;
}

void Component::Active(bool active) { this->active_ = active; }

#///////////////////////////////////////////////////////////////////////////////

bool operator<(const Component& x, const Component& y) { return &x < &y; }

}