#ifndef RHO__define_guard__define_cuh
#define RHO__define_guard__define_cuh

#include <stdio.h>
#include <assert.h>
#include <cuda.h>
#include <cuda_runtime.h>
#include <cuda_runtime_api.h>
#include <new>

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

#define RHO__debug_flag true

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

#if RHO__debug_flag
#define RHO__debug if constexpr (true)
#define RHO__debug_if(x) if (x)

#define RHO__throw__(type, func, desc)                                         \
	{                                                                          \
		rho::Print() << __LINE__ << "\n"                                       \
					 << type << "::" << func << "\n\t" << desc;                \
		assert(false);                                                         \
	}
#else
#define RHO__debug if constexpr (false)
#define RHO__debug_if(x) if (false)

#define RHO__throw__(type, func, desc) ;
#endif

#define RHO__throw_(type, func, desc) RHO__throw__(#type, func, desc)
#define RHO__throw(type, func, desc) RHO__throw_(type, func, desc)

#define RHO__hst __host__
#define RHO__glb __global__
#define RHO__dev __device__
#define RHO__cuda RHO__hst RHO__dev

#define RHO__thread_num                                                        \
	(gridDim.x * gridDim.y * gridDim.z * blockDim.x * blockDim.y * blockDim.z)

#define RHO__thread_index                                                      \
	(blockIdx.z * blockDim.x * blockDim.y * blockDim.z * gridDim.x *           \
		 gridDim.y +                                                           \
	 blockIdx.y * blockDim.x * blockDim.y * blockDim.z * gridDim.x +           \
	 blockIdx.x * blockDim.x * blockDim.y * blockDim.z +                       \
	 threadIdx.z * blockDim.x * blockDim.y + threadIdx.y * blockDim.x +        \
	 threadIdx.x)

#define RHO__dev_block defined __CUDA_ARCH__
#define RHO__hst_block not defined __CUDA_ARCH__

/*
#define RHO__hst
#define RHO__glb
#define RHO__dev
#define RHO__cuda */
/*
#ifdef __CUDA_ARCH__
#define RHO__dev_only true
#else
#define RHO__dev_only false
#endif*/

#define RHO__offset(type, member) size_t(&((type*)0)->member)

#define RHO__max_dim (3)
#define RHO__max_dim_sq (RHO__max_dim * RHO__max_dim)

#define RHO__eps (1e-8)
#define RHO__inf (1e256 * 1e256 * 1e256 * 1e256)

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

namespace rho {

using nullptr_t = decltype(nullptr);
using size_t = decltype(sizeof(char));
using diff_t = decltype((char*)(0) - (char*)(0));
using uint_t = unsigned int;
using double_t = double;
using dim_t = unsigned int;
using id_t = unsigned int;

#///////////////////////////////////////////////////////////////////////////////

template<typename T> struct Identity { using type = T; };
template<typename T> using Ideneity_t = typename Identity<T>::type;

#///////////////////////////////////////////////////////////////////////////////

template<typename T> RHO__cuda inline T declval() { return T(); }

#///////////////////////////////////////////////////////////////////////////////

template<typename T> struct RmRef { using type = T; };
template<typename T> struct RmRef<T&> { using type = T; };
template<typename T> struct RmRef<T&&> { using type = T; };
template<typename T> using RmRef_t = typename RmRef<T>::type;

#///////////////////////////////////////////////////////////////////////////////

template<typename T> struct AddLvalueRef { using type = T&; };
template<typename T> using AddLvalueRef_t = typename AddLvalueRef<T>::type;
template<typename T> struct AddRvalueRef { using type = T&&; };
template<typename T> using AddRvalueRef_t = typename AddRvalueRef<T>::type;

#///////////////////////////////////////////////////////////////////////////////

template<typename T> RHO__cuda RmRef_t<T>&& Move(T&& x) {
	return static_cast<RmRef_t<T>&&>(x);
}

template<typename T> RHO__cuda T&& Forward(RmRef_t<T>& x) {
	return static_cast<T&&>(x);
}

#///////////////////////////////////////////////////////////////////////////////

template<typename T, typename Y> struct IsSame {
	static constexpr bool value = false;
};

template<typename T> struct IsSame<T, T> {
	static constexpr bool value = true;
};

#///////////////////////////////////////////////////////////////////////////////

template<typename T> struct IsConst { static constexpr bool value = false; };

template<typename T> struct IsConst<const T> {
	static constexpr bool value = true;
};

#///////////////////////////////////////////////////////////////////////////////

template<typename T> struct AddConst { using type = const T; };
template<typename T> using AddConst_t = typename AddConst<T>::type;

#///////////////////////////////////////////////////////////////////////////////

template<typename T> struct RmConst { using type = T; };
template<typename T> struct RmConst<const T> { using type = T; };
template<typename T> using RmConst_t = typename rho::RmConst<T>::type;

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

struct Print {};

#///////////////////////////////////////////////////////////////////////////////

template<size_t size> struct Line {};

template<size_t size>
RHO__cuda inline Print operator<<(Print p, const Line<size>& line) {
#pragma unroll
	for (size_t i(0); i != size; ++i) { ::printf("//"); }

	return Print();
}

RHO__cuda inline Print operator<<(Print p, void* x) {
	::printf("%p", x);
	return Print();
}

RHO__cuda inline Print operator<<(Print p, char x) {
	::printf("%c", x);
	return Print();
}

RHO__cuda inline Print operator<<(Print p, const char x[]) {
	::printf(x);
	return Print();
}

RHO__cuda inline Print operator<<(Print p, int x) {
	::printf("%d", x);
	return Print();
}
RHO__cuda inline Print operator<<(Print p, long int x) {
	::printf("%ld", x);
	return Print();
}

RHO__cuda inline Print operator<<(Print p, unsigned int x) {
	::printf("%u", x);
	return Print();
}

RHO__cuda inline Print operator<<(Print p, unsigned long int x) {
	::printf("%lu", x);
	return Print();
}

RHO__cuda inline Print operator<<(Print p, float x) {
	::printf("%+16.4f", x);
	return Print();
}

RHO__cuda inline Print operator<<(Print p, double x) {
	::printf("%+16.4lf", x);
	return Print();
}

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

RHO__cuda inline id_t get_id() {
	// This function is not completed.

	//The dev version

	/*static_assert(IsSame<id_t, unsigned int>::value ||
					  IsSame<id_t, unsigned long long int>::value,
				  "id_t type error");
	static id_t r(0);
	return atomicAdd(&r, id_t(1));*/

	/*The hst version is not complete*/

	return 0;
}

}

#endif
