#ifndef RHO__define_guard__Pattern__Family_cuh
#define RHO__define_guard__Pattern__Family_cuh

#include"../define.cuh"

namespace rho {
namespace pattern {

struct Family {
	Family* parent;

	Family* prev_sibling;
	Family* next_sibling;

	Family* prev_child;
	Family* next_child;

#////////////////////////////////////////////////

	RHO__cuda Family* child_begin();
	RHO__cuda Family* child_end();

	RHO__cuda Family* descendant_begin();
	RHO__cuda Family* descendant_end();

	RHO__cuda const Family* child_begin()const;
	RHO__cuda const Family* child_end()const;

	RHO__cuda const Family* descendant_begin()const;
	RHO__cuda const Family* descendant_end()const;

#////////////////////////////////////////////////

	RHO__cuda Family* next_descendant();
	RHO__cuda const Family* next_descendant()const;

#////////////////////////////////////////////////

	RHO__cuda Family();
	RHO__cuda Family(Family* parent);
	RHO__cuda virtual ~Family();

#////////////////////////////////////////////////

	RHO__cuda void Push(Family* child);
	RHO__cuda Family* Pop();
};

}
}

#endif