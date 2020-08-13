#ifndef RHO__define_guard__Kernel__Component_cuh
#define RHO__define_guard__Kernel__Component_cuh

#include "init.cuh"

namespace rho {

class Component {
	friend class Manager;
	friend class Space;
	friend class Object;

	friend class ComponentCollider;
	friend class ComponentLight;
	friend class Material;

public:
	enum struct Type : char { collider, light };

	struct PriorityCmp {
		RHO__cuda bool operator()(const Component* x, const Component* y);
	};

	const Type type;

	RHO__cuda bool active() const;
	RHO__cuda bool latest() const;

	RHO__cuda priority_t priority() const;

	RHO__cuda Manager* manager() const;
	RHO__cuda Space* root() const;
	RHO__cuda Object* object() const;

	RHO__cuda size_t dim_r() const;

	RHO__cuda virtual bool Refresh() const = 0;
	RHO__cuda void Active(bool active);
	RHO__cuda void Delete();

private:
	RHO__cuda Component(Type type, Object* object);
	RHO__cuda virtual ~Component();

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda void SetLatestFalse_();
	// void Move_();
	// cmpt do not need Move_
	// because all state of cmpt
	// referencing to its object
	// will also be modified
	// when the object::Move_ is called

#///////////////////////////////////////////////////////////////////////////////

	bool active_;
	bool latest_;
	priority_t priority_;

	Manager* const& manager_;
	Space* const& root_;
	Object* const object_;

	const size_t& dim_r_;
};

RHO__cuda bool operator<(const Component& x, const Component& y);

}

#endif
