#ifndef RHO__define_guard__Base__search_cuh
#define RHO__define_guard__Base__search_cuh

#include "operator.cuh"

namespace rho {

template<typename Iterator, typename Index,
		 typename Compare = op::eq<RmRef_t<decltype(*declval<Iterator>())>>>
RHO__cuda Iterator LinearSearch(Iterator begin, Iterator end,
								const Index& index,
								Compare compare = Compare()) {
	while (begin != end && !compare(*begin, index)) { ++begin; }
	return begin;
}

template<typename Src, typename Index,
		 typename Compare = op::lt<RmRef_t<decltype(declval<Src>()[0])>>>
RHO__cuda size_t BinarySearch(Src&& src, size_t size, const Index& index,
							  Compare compare = Compare()) {
	size_t i(0);
	size_t j(size);
	size_t k;

	while (i != j) {
		k = (i + j) / 2;

		if (compare(src[k], index)) {
			i = k + 1;
		} else if (compare(index, src[k])) {
			j = k;
		} else {
			return k;
		}
	}

	return size;
}

template<typename Src, typename Index,
		 typename Compare = op::lt<decltype(declval<Src&&>()[0])>>
RHO__cuda size_t BinarySearchForward(Src&& src, size_t size, const Index& index,
									 Compare compare = Compare()) {
	size_t i(0);
	size_t j(size);
	size_t k;

	while (i != j) {
		k = (i + j) / 2;

		if (compare(index, src[k])) {
			j = k;
		} else {
			i = k + 1;
		}
	}

	return i;
}

template<typename TreeNode, typename Index, typename Compare>
RHO__cuda TreeNode TreeSearch(TreeNode node, const Index& index,
							  Compare compare) {
	while (node) {
		if (compare(node, index)) {
			node = node->r;
		} else if (compare(index, node)) {
			node = node->l;
		} else {
			return node;
		}
	}

	return node;
}

template<
	typename Iterator, typename Index,
	typename Compare = op::eq<RmRef_t<decltype(*declval<Iterator>())>, Index>>
RHO__cuda bool Contain(Iterator begin, Iterator end, const Index& index,
					   Compare compare = Compare()) {
	for (; begin != end; ++begin) {
		if (compare(*begin, index)) { return true; }
	}

	return false;
}

template<typename Src, typename Index, typename Compare = op::lt<Src>>
RHO__cuda bool ContainLinear(size_t size, Src&& src, const Index& index,
							 Compare compare = Compare()) {
	for (size_t i(0); i != size; ++i) {
		if (compare(src[i], index)) { return true; }
	}

	return false;
}

template<typename Src, typename Index, typename Compare = op::lt<Src>>
RHO__cuda bool Contain(size_t size, Src&& src, const Index& index,
					   Compare compare = Compare()) {
	size_t begin(0);

	for (size_t i; begin != size;) {
		i = (begin + size) / 2;

		if (compare(index, src[i])) {
			size = i;
		} else if (compare(src[i], index)) {
			begin = i + 1;
		} else {
			return true;
		}
	}

	return false;
}

}

#endif