#ifndef RHO__define_guard__Base__Sort_cuh
#define RHO__define_guard__Base__Sort_cuh

#include "memory.cuh"
#include "operator.cuh"
#include "pair.cuh"
#include "triple.cuh"
#include "search.cuh"

namespace rho {

template<typename Iterator>
RHO__cuda size_t Count(Iterator begin, Iterator end) {
	size_t r(0);

	while (begin != end) {
		++begin;
		++r;
	}

	return r;
}

template<typename Iterator, typename T,
	typename Compare = op::eq<decltype(*declval<Iterator>()), const T&>>
RHO__cuda size_t Count(
	Iterator begin, Iterator end, const T& value, Compare compare = Compare()) {
	size_t r(0);

	for (; begin != end; ++begin) {
		if (compare(*begin, r)) { ++r; }
	}

	return r;
}

template<typename Iterator,
	typename Compare = op::lt<RmRef_t<decltype(*declval<Iterator>())>>>
RHO__cuda Iterator Max(
	Iterator begin, Iterator end, Compare compare = Compare()) {
	if (begin == end) { return end; }

	Iterator r(begin);

	for (++begin; begin != end; ++begin) {
		if (compare(*r, *begin)) { r = begin; }
	}

	return r;
}

#///////////////////////////////////////////////////////////////////////////////

template<typename Src,
	typename Compare = op::lt<RmRef_t<decltype(declval<Src>()[0])>>>
RHO__cuda void InsertionSort(
	size_t size, Src&& src, Compare compare = Compare()) {
	using T = RmRef_t<decltype(src[0])>;

	if (size < 2) { return; }

	char temp_[sizeof(T)];
	T* temp(reinterpret_cast<T*>(temp_));

	for (size_t i(1); i != size; ++i) {
		if (!compare(src[i], src[i - 1])) { continue; }

		new (temp) T(Move(src[i]));
		size_t j(i);

		do {
			src[j] = Move(src[j - 1]);
			--j;
		} while (j && compare(src[j], src[j - 1]));

		src[j] = Move(*temp);
		temp->~T();
	}

	Free(temp);
}

template<typename Iterator,
	typename Compare = op::lt<RmRef_t<decltype(*declval<Iterator>())>>>
RHO__cuda void InsertionSort(
	Iterator begin, Iterator end, Compare compare = Compare()) {
	using T = RmRef_t<decltype(*begin)>;

	if (begin == end) { return; }

	T* temp(Malloc<T>(1));

	Iterator i(begin);
	++i;

	for (Iterator j(begin); i != end;) {
		if (compare(*i, *j)) {
			new (temp) T(Move(*i));

			Iterator k(i);

			do {
				*k = Move(*j);
				k = j;
				if (k == begin) { break; }
				--j;
			} while (compare(*temp, *j));

			*k = Move(*temp);
			temp->~T();
		}

		j = i;
		++i;
	}
}

template<typename Iterator,
	typename Compare = op::lt<RmRef_t<decltype(*declval<Iterator>())>>>
RHO__cuda void Sort(Iterator begin, Iterator end, Compare compare = Compare()) {
	InsertionSort(begin, end, compare);
}

template<typename Src,
	typename Compare = op::lt<RmRef_t<decltype(declval<Src&&>()[0])>>>
RHO__cuda void Sort(size_t size, Src&& src, Compare compare = Compare()) {
	InsertionSort(size, Forward<Src>(src), compare);
}

}

#endif