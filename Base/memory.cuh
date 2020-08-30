#ifndef RHO__define_guard__Base__memory_cuh
#define RHO__define_guard__Base__memory_cuh

#include "operator.cuh"

namespace rho {

template<typename T> RHO__cuda T* Malloc(size_t size) {
	return reinterpret_cast<T*>(new char[sizeof(T) * size]);
}

RHO__cuda inline void* Malloc(size_t size) { return Malloc<char>(size); }

template<typename T = char> RHO__hst void MallocDev(size_t size, T*& dst) {
	cudaMalloc(&dst, sizeof(T) * size);
}

template<typename T> RHO__hst T* MallocDev(size_t size) {
	T* r;
	cudaMalloc(&r, sizeof(T) * size);
	return r;
}

RHO__hst inline void* MallocDev(size_t size) { return MallocDev<char>(size); }

RHO__cuda inline void Free(void* ptr) { delete[](char*) ptr; }

RHO__hst inline void FreeDev(void* ptr) { cudaFree(ptr); }

template<typename T, typename... Args> RHO__cuda T* New(Args&&... args) {
	return new (Malloc(sizeof(T))) T(Forward<Args>(args)...);
}

#///////////////////////////////////////////////////////////////////////////////

template<typename T> RHO__cuda void Destroy(T* ptr) { ptr->~T(); }

template<typename T> RHO__cuda void Destroy(void* ptr) {
	static_cast<T*>(ptr)->~T();
}

template<typename Iterator>
RHO__cuda void Destroy(Iterator begin, Iterator end) {
	using T = RmRef_t<decltype(*begin)>;
	for (; begin != end; ++begin) { begin->~T(); }
}

template<typename Src> RHO__cuda void Destroy(size_t size, Src&& src) {
	using T = RmRef_t<decltype(src[0])>;
	for (size_t i(0); i != size; ++i) { src[i].~T(); }
}

#///////////////////////////////////////////////////////////////////////////////

template<typename T> RHO__cuda void Delete(T* ptr) {
	if (ptr) {
		ptr->~T();
		Free(ptr);
	}
}

template<typename T> RHO__cuda void Delete(size_t size, T* ptr) {
	for (size_t i(0); i != size; ++i) { ptr[i].~T(); }
	Free(ptr);
}

template<typename T> RHO__cuda void Delete(T* begin, T* end) {
	if (begin == end) { return; }
	for (; begin != end; ++begin) { begin->~T(); }
	Free(begin);
}

#///////////////////////////////////////////////////////////////////////////////

template<typename Dst, typename T>
RHO__cuda void Fill(size_t size, Dst&& dst, const T& value) {
	for (size_t i(0); i != size; ++i) { dst[i] = value; }
}

#///////////////////////////////////////////////////////////////////////////////

template<size_t i, size_t size> struct Fill_ {
	template<typename Dst, typename T>
	RHO__cuda void operator()(Dst&& dst, const T& value) {
		Forward<Dst>(dst)[i] = value;
		Fill_<i + 1, size>()(Forward<Dst>(dst), value);
	}
};

template<size_t size> struct Fill_<size, size> {
	template<typename Dst, typename T>
	RHO__cuda void operator()(Dst&& dst, const T& value) {}
};

template<size_t size, typename Dst, typename T>
RHO__cuda void Fill(Dst&& dst, const T& value) {
	Fill_<0, size>()(Forward<Dst>(dst), value);
}

#///////////////////////////////////////////////////////////////////////////////

template<typename Dst, typename Src>
RHO__cuda void Copy(size_t size, Dst&& dst, Src&& src) {
	for (size_t i(0); i != size; ++i) { dst[i] = src[i]; }
}

template<typename Dst, typename Src>
RHO__cuda void CopyForward(size_t size, Dst&& dst, Src&& src) {
	for (size_t i(0); i != size; ++i) { dst[i] = src[i]; }
}

template<typename Dst, typename Src>
RHO__cuda void CopyBackward(size_t size, Dst&& dst, Src&& src) {
	while (size) {
		--size;
		dst[size] = src[size];
	}
}

template<size_t size, typename Dst, typename Src>
RHO__cuda void Copy(Dst&& dst, Src&& src) {
#pragma unroll
	for (size_t i(0); i != size; ++i)
		Forward<Dst>(dst)[i] = Forward<Src>(src)[i];
}

#///////////////////////////////////////////////////////////////////////////////

template<typename Dst, typename Src>
RHO__cuda void Move(Dst dst, Src src, size_t size) {
	for (; size; ++dst, ++src, --size) { *dst = move(*src); }
}

template<typename Dst, typename Src>
RHO__cuda void Move(size_t size, Dst&& dst, Src&& src) {
	for (size_t i(0); i != size; ++i) { dst[i] = Move(src[i]); }
}

template<typename Dst, typename Src>
RHO__cuda void MoveForward(size_t size, Dst&& dst, Src&& src) {
	for (size_t i(0); i != size; ++i) { dst[i] = Move(src[i]); }
}

template<typename Dst, typename Src>
RHO__cuda void MoveBackward(size_t size, Dst&& dst, Src&& src) {
	while (size) {
		--size;
		dst[size] = Move(src[size]);
	}
}

template<size_t size, typename Dst, typename Src>
RHO__cuda void Move(Dst&& dst, Src&& src) {
#pragma unroll
	for (size_t i(0); i != size; ++i)
		Forward<Dst>(dst)[i] = Move(Forward<Src>(src)[i]);
}

#///////////////////////////////////////////////////////////////////////////////

template<
	typename X, typename Y,
	typename EQ = op::eq<decltype(declval<X>()[0]), decltype(declval<Y>()[0])>>
RHO__cuda bool Equal(size_t size, X&& x, Y&& y, EQ eq = EQ()) {
	for (size_t i(0); i != size; ++i) {
		if (!eq(x[i], y[i])) { return false; }
	}

	return true;
}

RHO__cuda inline void Memcpy(size_t size, void* dst, const void* src) {
	for (size_t i(0); i != size; ++i)
		static_cast<char*>(dst)[i] = static_cast<const char*>(src)[i];
}

RHO__cuda inline void MemcpyForward(size_t size, void* dst, const void* src) {
	for (size_t i(0); i != size; ++i)
		static_cast<char*>(dst)[i] = static_cast<const char*>(src)[i];
}

RHO__cuda inline void MemcpyBackward(size_t size, void* dst, const void* src) {
	while (size) {
		--size;
		static_cast<char*>(dst)[size] = static_cast<const char*>(src)[size];
	}
}

inline void MemcpyHstDev(size_t size, void* dst, const void* src) {
	cudaMemcpy(dst, src, size, cudaMemcpyDeviceToHost);
}

inline void MemcpyDevHst(size_t size, void* dst, const void* src) {
	cudaMemcpy(dst, src, size, cudaMemcpyHostToDevice);
}

RHO__cuda inline bool Memcmp(size_t size, const void* x, const void* y) {
	for (size_t i(0); i != size; ++i) {
		if (static_cast<const char*>(x)[i] != static_cast<const char*>(y)[i])
			return false;
	}

	return true;
}

#///////////////////////////////////////////////////////////////////////////////

template<typename T, typename Y = T> RHO__cuda void Swap(T& x, Y& y) {
	if (&x == &y) { return; }
	T temp(Move(x));
	x = Move(y);
	y = Move(temp);
}

#///////////////////////////////////////////////////////////////////////////////

namespace op {

template<typename T> struct swap {
	RHO__cuda void operator()(T& x, T& y) const { Swap(x, y); }
};

}

#///////////////////////////////////////////////////////////////////////////////

template<size_t i, size_t size> struct Init_ {
	template<typename Dst, typename T, typename... Args>
	RHO__cuda void operator()(Dst* dst, T&& x, Args&&... args) {
		new (dst + i) Dst(Forward<T>(x));
		Init_<i + 1, size>()(dst, Forward<Args>(args)...);
	}
};

template<size_t size> struct Init_<size, size> {
	template<typename Dst> RHO__cuda void operator()(Dst* dst) {}
};

template<size_t size, typename Dst, typename... Args>
RHO__cuda void Init(Dst* dst, Args&&... args) {
	static_assert(size == sizeof...(args), "size error");
	Init_<0, size>()(dst, Forward<Args>(args)...);
}

#///////////////////////////////////////////////////////////////////////////////

template<size_t i, size_t size> struct Assign_ {
	template<typename Dst, typename T, typename... Args>
	RHO__cuda static void F(Dst&& dst, T&& x, Args&&... args) {
		dst[i] = Forward<T>(x);
		Assign_<i + 1, size>::F(dst, Forward<Args>(args)...);
	}
};

template<size_t size> struct Assign_<size, size> {
	template<typename Dst> RHO__cuda static void F(Dst&& dst) {}
};

template<size_t size, typename Dst, typename... Args>
RHO__cuda void Assign(Dst&& dst, Args&&... args) {
	static_assert(size == sizeof...(args), "size error");
	Assign_<0, size>::F(dst, Forward<Args>(args)...);
}

#///////////////////////////////////////////////////////////////////////////////

template<size_t i, size_t j, size_t col_dim, size_t row_dim, size_t align>
struct Assign2D_ {
	template<typename Dst, typename T, typename... Args>
	RHO__cuda static void F(Dst&& dst, T&& x, Args&&... args) {
		Forward<Dst>(dst)[align * i + j] = Forward<T>(x);
		Assign2D_<i, j + 1, col_dim, row_dim, align>::F(Forward<Dst>(dst),
														Forward<Args>(args)...);
	}
};

template<size_t i, size_t col_dim, size_t row_dim, size_t align>
struct Assign2D_<i, row_dim, col_dim, row_dim, align> {
	template<typename Dst, typename... Args>
	RHO__cuda static void F(Dst&& dst, Args&&... args) {
		Assign2D_<i + 1, 0, col_dim, row_dim, align>::F(Forward<Dst>(dst),
														Forward<Args>(args)...);
	}
};

template<size_t col_dim, size_t row_dim, size_t align>
struct Assign2D_<col_dim, 0, col_dim, row_dim, align> {
	template<typename Dst> RHO__cuda static void F(Dst&& dst) {}
};

template<size_t col_size, size_t row_size, size_t align, typename Dst,
		 typename... Args>
RHO__cuda void Assign2D(Dst&& dst, Args&&... args) {
	static_assert(col_size * row_size == sizeof...(args), "size error");
	Assign2D_<0, 0, col_size, row_size, align>::F(Forward<Dst>(dst),
												  Forward<Args>(args)...);
}

}

#endif
