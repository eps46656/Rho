#ifndef RHO__define_guard__Kernel__Component_cuh
#define RHO__define_guard__Kernel__Component_cuh

#include "init.cuh"

namespace rho {

class Component {
	friend class Object;

public:
	enum struct Type : char { collider, light };

#///////////////////////////////////////////////////////////////////////////////

	const Type type;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda virtual const Space* root() const = 0;
	RHO__cuda virtual dim_t root_dim() const;

	RHO__cuda bool latest() const;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda virtual ~Component() {}

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda virtual bool Refresh() const = 0;
	RHO__cuda void Delete();

protected:
	RHO__cuda Component(Type type);

private:
	RHO__cuda void SetLatestFalse_();
	// void Move_();
	// cmpt do not need Move_
	// because all state of cmpt
	// referencing to its object
	// will also be modified
	// when the object::Move_ is called

#///////////////////////////////////////////////////////////////////////////////

	bool latest_;
};

RHO__cuda bool operator<(const Component& x, const Component& y);

}

#endif
