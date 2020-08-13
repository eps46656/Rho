#ifndef RHO__define_guard__Container__ReverseIterator_cuh
#define RHO__define_guard__Container__ReverseIterator_cuh

#include "../define.cuh"

namespace rho {
namespace contaienr {

template<typename Iterator>
struct ReverseIterator : public Iterator {
	ReverseIterator(const Iterator& iterator) : Iterator(iterator) {}

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda auto operator++() { return --this->iterator_; }
	RHO__cuda auto operator--() { return ++this->iterator_; }

	RHO__cuda auto operator++() const { return --this->iterator_; }
	RHO__cuda auto operator--() const { return ++this->iterator_; }
};

}
}

#endif
