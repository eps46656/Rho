#ifndef RHO__define_guard__Kernel__Component_cuh
#define RHO__define_guard__Kernel__Component_cuh

#include "init.cuh"

namespace rho {

class Component {
	friend class Object;

public:
	enum struct Type : char { collider, light };

	struct PriorityCmp {
		RHO__cuda bool operator()(const Component* x, const Component* y);
	};

#///////////////////////////////////////////////////////////////////////////////

	const Type type;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda virtual ~Component();

	RHO__cuda bool active() const;
	RHO__cuda bool latest() const;

	RHO__cuda priority_t priority() const;

	RHO__cuda Space* root() const;
	RHO__cuda Object* object() const;

	RHO__cuda size_t dim_r() const;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Component* SetObject(Object* object);

	RHO__cuda virtual bool Refresh() const = 0;
	RHO__cuda void Active(bool active);
	RHO__cuda void Delete();

protected:
	RHO__cuda Component(Type type, Object* object = nullptr);

private:
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

	Object* object_;
};

RHO__cuda bool operator<(const Component& x, const Component& y);

}

#endif
