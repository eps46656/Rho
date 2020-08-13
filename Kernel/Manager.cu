#include "define.cuh"
#include "Kernel.cuh"

namespace rho {

const cntr::BidirectionalNode* Manager::instance() { return instance_(); }

cntr::BidirectionalNode* Manager::instance_() {
	static cntr::BidirectionalNode* r(nullptr);
	return r ? r : (r = New<cntr::BidirectionalNode>());
}

size_t Manager::get_code() {
	static size_t code(0);
	return code += 1;
}

Map_t<code_t, void*>& Manager::id_ptr_() {
	static Map_t<code_t, void*>* r(nullptr);
	return *(r ? r : (r = New<Map_t<code_t, void*>>()));
}

#///////////////////////////////////////////////////////////////////////////////

const RBT<Space*>& Manager::space() const { return this->space_; }

const RBT<Object*>& Manager::object() const { return this->object_; }

const ComponentContainer& Manager::cmpt() const { return this->cmpt_; }

const RBT<Object*>& Manager::active_object() const {
	return this->active_object_;
}

const ComponentContainer& Manager::active_cmpt() const {
	return this->active_cmpt_;
}

#///////////////////////////////////////////////////////////////////////////////

Texture* Manager::default_texture() const { return this->default_texture_; }

Material* Manager::default_material() const { return this->default_material_; }

Material* Manager::void_material() const { return this->void_material_; }

#///////////////////////////////////////////////////////////////////////////////

const cntr::Vector<Component*>& Manager::priority_vector() const {
	return this->priority_vector_;
}

bool Manager::priority_vector(const cntr::Vector<Component*>& priority_vector) {
	size_t size(this->priority_vector_.size());

	if (size != priority_vector.size()) { return false; }

	for (size_t i(0); i != priority_vector.size(); ++i) {
		if (BinarySearch(this->priority_vector_, priority_vector.size(),
						 priority_vector[i]) == priority_vector.size()) {
			return false;
		}
	}

	for (size_t i(0); i != size; ++i) {
		(this->priority_vector_[i] = priority_vector[i])->priority_ = i;
	}

	return true;
}

#///////////////////////////////////////////////////////////////////////////////

Manager::Manager(Space* root):
	root_(root), void_material_(New<Material>()),
	default_material_(New<Material>()) {
	//	instance_()->PushFront(this);

	this->void_material_->refraction_index = 1;
	this->void_material_->transmittance[0] = 0;
	this->void_material_->transmittance[1] = 0;
	this->void_material_->transmittance[2] = 0;

	this->default_material_->refraction_index = 1;
	this->default_material_->transmittance[0] = 0;
	this->default_material_->transmittance[1] = 0;
	this->default_material_->transmittance[2] = 0;

	TextureSolid* a(New<TextureSolid>());
	a->data.color[0] = 0;
	a->data.color[1] = 0;
	a->data.color[2] = 0;
	a->data.transmittance[0] = 0;
	a->data.transmittance[1] = 0;
	a->data.transmittance[2] = 0;
	a->data.reflectance[0] = 0;
	a->data.reflectance[1] = 0;
	a->data.reflectance[2] = 0;
	a->data.shininess[0] = 0;
	a->data.shininess[1] = 0;
	a->data.shininess[2] = 0;

	this->default_texture_ = a;

	//this->space_.Insert(root);
}

#///////////////////////////////////////////////////////////////////////////////

void Manager::Refresh() const {}

#///////////////////////////////////////////////////////////////////////////////

void Manager::AddSpace_(Space* space) { this->space_.Insert(space); }

void Manager::AddObject_(Object* object) {
	this->object_.Insert(object);
	this->active_object_.Insert(object);
}

void Manager::AddComponent_(Component* cmpt) {
	this->cmpt_.Insert(cmpt);
	this->active_cmpt_.Insert(cmpt);

	cmpt->priority_ = this->priority_vector_.size();
	this->priority_vector_.Push(cmpt);

	this->ActiveComponentTrue_(cmpt);
}

void Manager::RegisterCamera_(Camera* camera) { this->camera_.Push(camera); }

#///////////////////////////////////////////////////////////////////////////////

void Manager::ActiveObjectTrue_(Object* object) {
	this->active_object_.Insert(object);
}

void Manager::ActiveComponentTrue_(Component* cmpt) {
	this->active_cmpt_.Insert(cmpt);

	if (cmpt->type == Component::Type::collider) {
		this->active_sorted_cmpt_collider_.Push(
			static_cast<ComponentCollider*>(cmpt));

		Sort(this->active_sorted_cmpt_collider_.begin(),
			 this->active_sorted_cmpt_collider_.end(),
			 Component::PriorityCmp());
	}
}

void Manager::ActiveObjectFalse_(Object* object) {
	this->active_object_.FindErase(object);
}

void Manager::ActiveComponentFalse_(Component* cmpt) {
	this->active_cmpt_.FindErase(cmpt);

	if (cmpt->type == Component::Type::collider) {
		this->active_sorted_cmpt_collider_.Erase(
			LinearSearch(this->active_sorted_cmpt_collider_.begin(),
						 this->active_sorted_cmpt_collider_.end(),
						 static_cast<ComponentCollider*>(cmpt)));
	}
}

#///////////////////////////////////////////////////////////////////////////////

void Manager::DeleteSpace_(Space* space) {
	this->space_.Erase(this->space_.Find(space));
}

void Manager::DeleteObject_(Object* object) {
	this->object_.Erase(this->object_.Find(object));
	this->active_object_.Erase(this->active_object_.Find(object));
}

void Manager::DeleteComponent_(Component* cmpt) {
	this->cmpt_.FindErase(cmpt);
	this->active_cmpt_.FindErase(cmpt);

	if (cmpt->type == Component::Type::collider && cmpt->active()) {
		this->active_sorted_cmpt_collider_.Erase(
			LinearSearch(this->active_sorted_cmpt_collider_.begin(),
						 this->active_sorted_cmpt_collider_.end(),
						 static_cast<ComponentCollider*>(cmpt)));
	}
}

void Manager::DeleteCamera_(Camera* camera) {
	this->camera_.Erase(
		LinearSearch(this->camera_.begin(), this->camera_.end(), camera));
}

#///////////////////////////////////////////////////////////////////////////////

ComponentCollider* Manager::GetComponentCollider(const Num* point) const {
	return this->GetComponentCollider(point,
									  this->active_sorted_cmpt_collider_);
}

ComponentCollider* Manager::GetComponentCollider(
	const Num* point,
	const cntr::Vector<ComponentCollider*>& cmpt_collider) const {
	auto iter(this->active_sorted_cmpt_collider_.begin());

	for (auto end(this->active_sorted_cmpt_collider_.end()); iter != end;
		 ++iter) {
		if ((*iter)->domain()->Contain(point)) return *iter;
	}

	return nullptr;
}

cntr::Vector<ComponentCollider*>
Manager::GetComponentCollider_Full(const Num* point) const {
	return this->GetComponentCollider_Full(point,
										   this->active_sorted_cmpt_collider_);
}

cntr::Vector<ComponentCollider*> Manager::GetComponentCollider_Full(
	const Num* point,
	const cntr::Vector<ComponentCollider*>& cmpt_collider) const {
	cntr::Vector<ComponentCollider*> r;
	r.Reserve(this->active_sorted_cmpt_collider_.size());

	for (size_t i(0); i != this->active_sorted_cmpt_collider_.size(); ++i) {
		if (this->active_sorted_cmpt_collider_[i]->domain()->Contain(point))
			r.Push(this->active_sorted_cmpt_collider_[i]);
	}

	return r;
}

}
