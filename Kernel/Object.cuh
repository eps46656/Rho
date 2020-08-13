#ifndef RHO__define_guard__Kernel__Object_cuh
#define RHO__define_guard__Kernel__Object_cuh

#include"init.cuh"
#include"Component.cuh"
#include"ComponentContainer.cuh"

namespace rho {

class Object {

	friend class Manager;
	friend class Component;

public:
	RHO__cuda bool active()const;
	RHO__cuda bool latest()const;

	RHO__cuda Manager* manager()const;
	RHO__cuda Space* root()const;

	RHO__cuda size_t dim_r()const;

#////////////////////////////////////////////////

	RHO__cuda const ComponentContainer& cmpt()const;
	RHO__cuda const ComponentContainer& active_cmpt()const;

	RHO__cuda ComponentCollider* cmpt_collider()const;
	RHO__cuda Material* material()const;

#////////////////////////////////////////////////

	RHO__cuda Object(
		Space* root,
		Material* material = nullptr);

	RHO__cuda ~Object();

#////////////////////////////////////////////////

	RHO__cuda bool Refresh()const;
	RHO__cuda void Active(bool active);
	RHO__cuda void ActiveSelfAndAncestor();
	RHO__cuda void Delete();

private:
	bool active_;

	mutable bool latest_;

	Manager* manager_;
	Space* root_;

	size_t dim_r_;

	ComponentContainer cmpt_;
	ComponentContainer active_cmpt_;

	ComponentCollider* cmpt_collider_;
	mutable Material* material_;

#////////////////////////////////////////////////

	RHO__cuda void ActiveDescendant_(bool active);
	RHO__cuda void SetLatestFalse_();

	RHO__cuda void AddComponent_(Component* cmpt);
	RHO__cuda void DeleteComponent_(Component* cmpt);
};

}

#endif