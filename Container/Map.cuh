#ifndef RHO__define_guard__Container__Map_cuh
#define RHO__define_guard__Container__Map_cuh

#include "../Base/pair.cuh"
#include "RedBlackTree.cuh"

namespace rho {
namespace cntr {

template<typename Index, typename Value, typename Compare = op::lt<Index>>
struct MapCompare {
	Compare compare;

	RHO__cuda bool operator()(const Index& x,
							  const pair<Index, Value>& y) const {
		return this->compare(x, y.first);
	}

	RHO__cuda bool operator()(const pair<Index, Value>& x,
							  const Index& y) const {
		return this->compare(x.first, y);
	}

	RHO__cuda bool operator()(const pair<Index, Value>& x,
							  const pair<Index, Value>& y) const {
		return this->compare(x.first, y.first);
	}
};

template<typename Index, typename Value, typename Compare>
using Map =
	RedBlackTree<rho::pair<Index, Value>, MapCompare<Index, Value, Compare>>;

}
}

#endif