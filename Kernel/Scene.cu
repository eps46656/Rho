#if false

#include "../define.cuh"
#include "Scene.cuh"

namespace rho {

Scene::Scene() {}

#///////////////////////////////////////////////////////////////////////////////

Space* Scene::root() const { return this->root_; }

RBT<Space*> Scene::space() const { return this->space_; }
RBT<Object*> Scene::object() const { return this->object_; }

#///////////////////////////////////////////////////////////////////////////////

void Scene::AddSpace_(Space* space) { this->space_.Insert(space); }

void Scene::AddObject_(Object* object) {
	this->object_.Insert(object);
	if (object.axtive()) { this->active_object_.Insert(object); }
}

void Manager::AddCmpt_(Component* cmpt) {
	this->cmpt_.Insert(cmpt);
	this->active_cmpt_.Insert(cmpt);

	cmpt->priority_ = this->priority_vector_.size();
	this->priority_vector_.Push(cmpt);
}

#///////////////////////////////////////////////////////////////////////////////

void Scene::SubSpace_(Space* space) { this->space_.FindErase(space); }

void Scene::SubObject_(Object* object) {
	this->object_.Erase(this->object_.Find(object));
	this->active_object_.FindDeleteErase(object);
}

}

#endif