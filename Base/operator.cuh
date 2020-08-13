#ifndef RHO__define_guard__Base__operator_cuh
#define RHO__define_guard__Base__operator_cuh

#include "../define.cuh"

namespace rho {
namespace op {

struct true_t;
struct false_t;

#////////////////////////////////////////////////

template<typename T> struct neg {
	RHO__cuda auto operator()(const T& x) const { return -x; }
};

#////////////////////////////////////////////////

template<typename T1, typename T2 = T1> struct eq {
	RHO__cuda bool operator()(const T1& x, const T2& y) const { return x == y; }
	RHO__cuda bool operator()(const T2& x, const T1& y) const { return x == y; }
};

template<typename T> struct eq<T, T> {
	RHO__cuda bool operator()(const T& x, const T& y) const { return x == y; }
};

#////////////////////////////////////////////////

template<typename T1, typename T2 = T1> struct ne {
	RHO__cuda bool operator()(const T1& x, const T2& y) const { return x != y; }
	RHO__cuda bool operator()(const T2& x, const T1& y) const { return x != y; }
};

template<typename T> struct ne<T, T> {
	RHO__cuda bool operator()(const T& x, const T& y) const { return x != y; }
};

#////////////////////////////////////////////////

template<typename T1, typename T2 = T1> struct lt {
	RHO__cuda bool operator()(const T1& x, const T2& y) const { return x < y; }
	RHO__cuda bool operator()(const T2& x, const T1& y) const { return x < y; }
};

template<typename T> struct lt<T, T> {
	RHO__cuda bool operator()(const T& x, const T& y) const { return x < y; }
};

#////////////////////////////////////////////////

template<typename T1, typename T2 = T1> struct le {
	RHO__cuda bool operator()(const T1& x, const T2& y) const { return x <= y; }
	RHO__cuda bool operator()(const T2& x, const T1& y) const { return x <= y; }
};

template<typename T> struct le<T, T> {
	RHO__cuda bool operator()(const T& x, const T& y) const { return x <= y; }
};

#////////////////////////////////////////////////

template<typename T1, typename T2 = T1> struct gt {
	RHO__cuda bool operator()(const T1& x, const T2& y) const { return x > y; }
	RHO__cuda bool operator()(const T2& x, const T1& y) const { return x > y; }
};

template<typename T> struct gt<T, T> {
	RHO__cuda bool operator()(const T& x, const T& y) const { return x > y; }
};

#////////////////////////////////////////////////

template<typename T1, typename T2 = T1> struct ge {
	RHO__cuda bool operator()(const T1& x, const T2& y) const { return x >= y; }
	RHO__cuda bool operator()(const T2& x, const T1& y) const { return x >= y; }
};

template<typename T> struct ge<T, T> {
	RHO__cuda bool operator()(const T& x, const T& y) const { return x >= y; }
};

#////////////////////////////////////////////////

template<typename T> struct log_not {
	RHO__cuda bool operator()(const T& x) const { return !x; }
};

#////////////////////////////////////////////////

template<typename T1, typename T2 = T1> struct log_or {
	RHO__cuda bool operator()(const T1& x, const T2& y) const { return x || y; }
	RHO__cuda bool operator()(const T2& x, const T1& y) const { return x || y; }
};

template<typename T> struct log_or<T, T> {
	RHO__cuda bool operator()(const T& x, const T& y) const { return x || y; }
};

#////////////////////////////////////////////////

template<typename T1, typename T2 = T1> struct log_and {
	RHO__cuda bool operator()(const T1& x, const T2& y) const { return x && y; }
	RHO__cuda bool operator()(const T2& x, const T1& y) const { return x && y; }
};

template<typename T> struct log_and<T, T> {
	RHO__cuda bool operator()(const T& x, const T& y) const { return x && y; }
};

#////////////////////////////////////////////////

template<typename T1, typename T2 = T1> struct log_xor {
	RHO__cuda bool operator()(const T1& x, const T2& y) const { return x ^ y; }
	RHO__cuda bool operator()(const T2& x, const T1& y) const { return x ^ y; }
};

template<typename T> struct log_xor<T, T> {
	RHO__cuda bool operator()(const T& x, const T& y) const { return x ^ y; }
};

#////////////////////////////////////////////////

template<typename T> struct ptr {
	RHO__cuda T& operator()(T& x) const { return &x; }
};

template<typename T> struct ref {
	RHO__cuda T& operator()(T* x) const { return *x; }
};

#////////////////////////////////////////////////

template<typename Src, typename Dst> struct assign {
	RHO__cuda auto operator()(Dst&& dst, const Src&& src) const {
		return dst = src;
	}
};

template<typename Src, typename Dst = Src> struct copy {
	RHO__cuda Dst operator()(const Src& src) const {
		return static_cast<Dst>(src);
	}
};

template<typename Src, typename Dst> struct move {
	RHO__cuda auto operator()(Dst& dst, Src& src) const {
		return dst = Move(src);
	}
};

#////////////////////////////////////////////////

template<typename T> struct DefaultCreator {
	RHO__cuda T operator()() { return T(); }
};

template<typename T> struct DefaultDeleter {
	RHO__cuda void operator()(T& x) const { Delete(&x); }
	RHO__cuda void operator()(T* begin, T* end) const { Delete(begin, end); }
};

template<typename Iterator, typename T = decltype(*rho::declval<Iterator>()),
		 typename Ref = ref<T>, typename Compare = lt<T>>
struct IteratorCompare {
	RHO__cuda bool operator()(const Iterator& x, const Iterator& y,
							  Ref ref = Ref(), Compare compare = Compare()) {
		return compare(ref(x), ref(y));
	}
};

}
}

#endif