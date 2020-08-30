#ifndef RHO__define_guard__Kernel__Object_cuh
#define RHO__define_guard__Kernel__Object_cuh

#include "init.cuh"
#include "Component.cuh"
#include "ComponentContainer.cuh"

namespace rho {

class Object {
	friend class Component;

public:
	RHO__cuda Space* root() const;

	RHO__cuda dim_t dim_r() const;

	RHO__cuda const ComponentContainer& cmpt() const;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Object();
	RHO__cuda Object(Space* root);
	RHO__cuda ~Object();

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Object* SetRoot(Space* root);

	RHO__cuda bool RefreshCmpt() const;
	RHO__cuda void ActiveCmpt(bool active);

private:
	Space* root_;

	ComponentContainer cmpt_;
	ComponentContainer active_cmpt_;

	ComponentCollider* cmpt_collider_;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda void AddCmpt_(Component* cmpt);
	RHO__cuda void SubCmpt_(Component* cmpt);
};

}

#endif