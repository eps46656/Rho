#include "define.cuh"
#include "Kernel.cuh"

namespace rho {

bool Object::active() const { return this->active_; }
bool Object::latest() const { return this->latest_; }

Manager* Object::manager() const { return this->manager_; }
Space* Object::root() const { return this->root_; }

size_t Object::dim_r() const { return this->dim_r_; }

const ComponentContainer& Object::cmpt() const { return this->cmpt_; }

const ComponentContainer& Object::active_cmpt() const {
	return this->active_cmpt_;
}

ComponentCollider* Object::cmpt_collider() const {
	return this->cmpt_collider_;
}

Material* Object::material() const { return this->material_; }

#///////////////////////////////////////////////////////////////////////////////

Object::Object(Space* root, Material* material):
	active_(true), latest_(false),

	manager_(root->manager()), root_(root),

	dim_r_(root->dim_s()),

	material_(material) {
	RHO__debug_if(root->parent()) RHO__throw(Object, __func__, "root error");

	this->manager_->AddObject_(this);
}

Object::~Object() {
	auto iter(this->cmpt_.begin());

	for (auto end(this->cmpt_.end()); iter != end; ++iter) (*iter)->Delete();

	this->manager_->DeleteObject_(this);
}

#///////////////////////////////////////////////////////////////////////////////

bool Object::Refresh() const {
	if (this->latest_) { return true; }

	this->latest_ = true;

	if (!this->material_) {
		this->material_ = this->manager_->default_material();
	}

	auto iter(this->cmpt_.begin());

	for (auto end(this->cmpt_.end()); iter != end; ++iter) {
		if (!(*iter)->Refresh()) { return false; }
	}

	return true;
}

#///////////////////////////////////////////////////////////////////////////////

void Object::Active(bool active) {
	if (active) { this->ActiveSelfAndAncestor(); }
	this->ActiveDescendant_(active);
}

void Object::ActiveSelfAndAncestor() {
	this->manager_->ActiveObjectTrue_(this);
	this->active_ = true;
}

void Object::ActiveDescendant_(bool active) {
	auto iter(this->cmpt_.begin());

	for (auto end(this->cmpt_.end()); iter != end; ++iter)
		(*iter)->Active(active);
}

#///////////////////////////////////////////////////////////////////////////////

void Object::Delete() {
	auto iter(this->cmpt_.begin());

	for (auto end(this->cmpt_.end()); iter != end; ++iter) (*iter)->Delete();
}

#///////////////////////////////////////////////////////////////////////////////

void Object::SetLatestFalse_() {
	auto iter(this->cmpt_.begin());

	for (auto end(this->cmpt_.end()); iter != end; ++iter)
		(*iter)->SetLatestFalse_();

	this->latest_ = false;
}

#///////////////////////////////////////////////////////////////////////////////

void Object::AddComponent_(Component* cmpt) {
	this->cmpt_.Insert(cmpt);
	this->latest_ = false;
}

void Object::DeleteComponent_(Component* cmpt) { this->cmpt_.FindErase(cmpt); }

}