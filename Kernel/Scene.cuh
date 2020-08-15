#if false

#ifndef RHO__define_guard__Scene_cuh
#define RHO__define_guard__Scene_cuh

#include "init.cuh"

namespace rho {
class Manager final: private cntr::BidirectionalNode {
	friend class Space;
	friend class Object;
	friend class Component;
	friend class Camera;

public:
	Space* root() const;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda const RBT<Space*>& space() const;
	RHO__cuda const RBT<Object*>& object() const;
	RHO__cuda const ComponentContainer& cmpt() const;

	RHO__cuda const RBT<Object*>& active_object() const;
	RHO__cuda const ComponentContainer& active_cmpt() const;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda const cntr::Vector<Component*>& priority() const;
	RHO__cuda bool priority(const cntr::Vector<Component*>& priority);

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Texture* default_texture() const;
	RHO__cuda Material* default_material() const;
	RHO__cuda Material* void_material() const;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda void Refresh() const;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda ComponentCollider* GetComponentCollider(const Num* pooint) const;

	RHO__cuda cntr::Vector<ComponentCollider*>
	GetComponentColliderFull(const Num* point) const;

private:
	Space* const root_;

	RBT<Space*> space_;
	RBT<Object*> object_;
	ComponentContainer cmpt_;

	RBT<Object*> active_object_;
	ComponentContainer active_cmpt_;

	cntr::Vector<Component*> priority_;

	cntr::Vector<ComponentCollider*> active_sorted_cmpt_collider_;

#///////////////////////////////////////////////////////////////////////////////

	cntr::Vector<Camera*> camera_;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Scene(Space* root);

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda void AddSpace_(Space* space);
	RHO__cuda void AddObject_(Object* object);
	RHO__cuda void AddComponent_(Component* cmpt);
	RHO__cuda void AddCamera_(Camera* camera);

	RHO__cuda void SubSpace_(Space* space);
	RHO__cuda void SubObject_(Object* object);
	RHO__cuda void SubComponent_(Component* cmpt);
	RHO__cuda void SubCamera_(Camera* camera);

	RHO__cuda void ActiveComponent_T_(Component* cmpt);
	RHO__cuda void ActiveComponent_F_(Component* cmpt);
};

}

#endif

#endif