#include "define.cuh"
#include "Kernel.cuh"

#define RHO__throw__local(desc) RHO__throw(Object, __func__, desc)

namespace rho {

Space* Object::root() const { return this->root_; }

dim_t Object::dim_r() const { return this->root_->dim_r(); }

const ComponentContainer& Object::cmpt() const { return this->cmpt_; }

#///////////////////////////////////////////////////////////////////////////////

Object::Object(): root_(nullptr) {}
Object::Object(Space* root) { this->SetRoot(root); }

Object::~Object() {
	auto iter(this->cmpt_.begin());
	for (auto end(this->cmpt_.end()); iter != end; ++iter) { delete *iter; }
}

#///////////////////////////////////////////////////////////////////////////////

Object* Object::SetRoot(Space* root) {
	RHO__debug_if(root && !root->is_root()) RHO__throw__local("root error");
	this->root_ = root;
	return this;
}

#///////////////////////////////////////////////////////////////////////////////

void Object::ActiveCmpt(bool active) {
	auto iter(this->cmpt_.begin());
	for (auto end(this->cmpt_.end()); iter != end; ++iter)
		(*iter)->Active(active);
}

#///////////////////////////////////////////////////////////////////////////////

bool Object::RefreshCmpt() const {
	auto iter(this->cmpt_.begin());
	for (auto end(this->cmpt_.end()); iter != end; ++iter) {
		if ((*iter)->active() && !(*iter)->Refresh()) { return false; }
	}

	return true;
}

#///////////////////////////////////////////////////////////////////////////////

void Object::AddCmpt_(Component* cmpt) { this->cmpt_.Insert(cmpt); }
void Object::SubCmpt_(Component* cmpt) { this->cmpt_.FindErase(cmpt); }

}