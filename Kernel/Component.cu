#include"define.cuh"
#include"Kernel.cuh"

namespace rho {

bool Component::PriorityCmp::operator()(
	const Component* x, const Component* y) {

	return x->active_ && (!y->active_ || x->priority_ > y->priority_);
}

#////////////////////////////////////////////////

code_t Component::id()const { return this->id_; }

bool Component::active()const { return this->active_; }
bool Component::latest()const { return this->latest_; }

priority_t Component::priority()const { return this->priority_; }

Manager* Component::manager()const { return this->manager_; }
Space* Component::root()const { return this->root_; }
Object* Component::object()const { return this->object_; }

size_t Component::dim_r()const { return this->dim_r_; }

#////////////////////////////////////////////////

Component::Component(Type type, Object* object) :
	id_(Manager::get_code()),
	type(type),

	active_(true),
	latest_(false),

	manager_(object->manager_),
	root_(object->root_),
	object_(object),

	dim_r_(object->dim_r_) {

	this->manager_->AddComponent_(this);
	this->object_->AddComponent_(this);
}

Component::~Component() {}

#////////////////////////////////////////////////

void Component::SetLatestFalse_() { this->latest_ = false; }

#////////////////////////////////////////////////

void Component::Active(bool active) {
	if (active == this->active_)
		return;

	if (active) {
		this->object_->ActiveSelfAndAncestor();
		this->manager_->ActiveComponentTrue_(this);
		this->active_ = true;
	} else {
		this->manager_->ActiveComponentFalse_(this);
		this->active_ = false;
	}
}

void Component::Delete() {
	this->manager_->DeleteComponent_(this);
	this->object_->DeleteComponent_(this);
	this->~Component();
	Free(this);
}

#////////////////////////////////////////////////

bool operator<(const Component& x, const Component& y) {
	return x.id() < y.id();
}

}