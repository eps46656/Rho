#ifndef RHO__define_guard__Kernel__Manager_cuh
#define RHO__define_guard__Kernel__Manager_cuh

#include "init.cuh"
#include "ComponentContainer.cuh"

namespace rho {

class Manager final: private cntr::BidirectionalNode {
	friend class Space;
	friend class Object;
	friend class Component;
	friend class ComponentCollider;
	friend class ComponentLight;

	friend class Camera;

public:
	RHO__cuda static const cntr::BidirectionalNode* instance();
	RHO__cuda static size_t get_code();

	RHO__cuda const RBT<Space*>& space() const;
	RHO__cuda const RBT<Object*>& object() const;
	RHO__cuda const ComponentContainer& cmpt() const;

	RHO__cuda const RBT<Object*>& active_object() const;
	RHO__cuda const ComponentContainer& active_cmpt() const;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda const cntr::Vector<Component*>& priority_vector() const;
	RHO__cuda bool
	priority_vector(const cntr::Vector<Component*>& priority_vector);

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Texture* default_texture() const;
	RHO__cuda Material* default_material() const;
	RHO__cuda Material* void_material() const;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda void Refresh() const;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda ComponentCollider* GetComponentCollider(const Num* pooint) const;

	RHO__cuda ComponentCollider* GetComponentCollider(
		const Num* point,
		const cntr::Vector<ComponentCollider*>& cmpt_collider) const;

	RHO__cuda cntr::Vector<ComponentCollider*>
	GetComponentCollider_Full(const Num* point) const;

	RHO__cuda cntr::Vector<ComponentCollider*> GetComponentCollider_Full(
		const Num* point,
		const cntr::Vector<ComponentCollider*>& cmpt_collider) const;

private:
	RHO__cuda static cntr::BidirectionalNode* instance_();
	RHO__cuda static Map_t<code_t, void*>& id_ptr_();

#///////////////////////////////////////////////////////////////////////////////

	Space* const root_;

	RBT<Space*> space_;
	RBT<Object*> object_;
	ComponentContainer cmpt_;

	RBT<Object*> active_object_;
	ComponentContainer active_cmpt_;

	cntr::Vector<Component*> priority_vector_;

	cntr::Vector<ComponentCollider*> active_sorted_cmpt_collider_;

#///////////////////////////////////////////////////////////////////////////////

	cntr::Vector<Camera*> camera_;

#///////////////////////////////////////////////////////////////////////////////

	Material* default_material_;
	Texture* default_texture_;
	Material* void_material_;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Manager(Space* root);

	// manager will be automatically created
	// when a new root space is created
	// it is not allowed to create a manager by client

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda void AddSpace_(Space* space);
	RHO__cuda void AddObject_(Object* object);
	RHO__cuda void AddComponent_(Component* cmpt);

	RHO__cuda void RegisterCamera_(Camera* camera);

	RHO__cuda void ActiveObjectTrue_(Object* object);
	RHO__cuda void ActiveComponentTrue_(Component* cmpt);

	RHO__cuda void ActiveObjectFalse_(Object* object);
	RHO__cuda void ActiveComponentFalse_(Component* cmpt);

	RHO__cuda void DeleteSpace_(Space* space);
	RHO__cuda void DeleteObject_(Object* object);
	RHO__cuda void DeleteComponent_(Component* cmpt);
	RHO__cuda void DeleteCamera_(Camera* camera);
};

}

#endif
