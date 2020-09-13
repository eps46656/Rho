#ifndef RHO__define_guard__Container__Array_cuh
#define RHO__define_guard__Container__Array_cuh

namespace rho {
namespace cntr {

template<typename T, size_t N> struct Array {
	static_assert(N != 0, "N needs larger than 0");

	T value[N];

#///////////////////////////////////////////////////////////////////////////////

	template<typename... Args> RHO__cuda static Array Make(Args&&... args) {
		Array r;
		rho::Assign<N>(r, Forward<Args>(args)...);
		return r;
	}

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Array() {}

	template<typename Src> RHO__cuda Array(Src&& src) { *this = src; }

	RHO__cuda ~Array() {}

	operator T*() { return this->value; }
	operator const T*() const { return this->value; }

#///////////////////////////////////////////////////////////////////////////////

	template<typename Src> RHO__cuda Array& operator=(Src&& src) {
		Copy<N>(this->value, Forward<Src>(src));
		return *this;
	}

	template<typename... Args> RHO__cuda void Assign(Args&&... args) {
		rho::Assign<N>(this->value, Forward<Args>(args)...);
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