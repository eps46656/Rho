#ifndef RHO__define_guard__Container__Array_cuh
#define RHO__define_guard__Container__Array_cuh

namespace rho {
namespace cntr {

template<typename T, size_t N> struct Array {
	static_assert(N != 0, "N needs larger than 0");

	T value[N];

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Array() {}

	template<typename Src> RHO__cuda Array(Src&& src) { *this = src; }

	RHO__cuda ~Array() {}

#///////////////////////////////////////////////////////////////////////////////

	template<typename Src> RHO__cuda Array& operator=(Src&& src) {
		rho::Copy<N>(this->value, Forward<Src>(src));
		return *this;
	}

#///////////////////////////////////////////////////////////////////////////////

	template<typename Index> RHO__cuda T& operator[](Index&& index) & {
		return this->value[Forward<Index>(index)];
	}

	template<typename Index>
	RHO__cuda const T& operator[](Index&& index) const& {
		return this->value[Forward<Index>(index)];
	}

	template<typename Index> RHO__cuda T&& operator[](Index&& index) && {
		return Move(this->value[Forward<Index>(index)]);
	}
};

}
}

#endif