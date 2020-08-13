#ifndef RHO__define_guard__Pointer__Any_cuh
#define RHO__define_guard__Pointer__Any_cuh

#include"../Base/memory.cuh"

namespace rho {
namespace ptr {

class Any {

private:
	struct CoreBase {
		void* ptr;

		RHO__cuda virtual void Free() = 0;
		RHO__cuda virtual void Copy(void* ptr) = 0;
	};

	template<typename T>
	struct Core :public CoreBase {
		RHO__cuda void Free()override
		{ Delete(static_cast<T*>(this->ptr)); }

		RHO__cuda void Copy(void* ptr)override
		{ new(ptr) Core(); }
	};

public:
	RHO__cuda Any() { this->core_.ptr = nullptr; }

	template<typename T>
	RHO__cuda explicit Any(T* ptr)
	{ (new(&this->core_) Core<T>())->ptr = ptr; }

	RHO__cuda inline Any(Any&& any) {
		any.core_.Copy(&this->core_);
		this->core_.ptr = any.core_.ptr;
		any.core_.ptr = nullptr;
	}

	RHO__cuda inline ~Any()
	{ static_cast<CoreBase&>(this->core_).Free(); }

#////////////////////////////////////////////////

	RHO__cuda inline operator bool()const
	{ return this->core_.ptr; }

#////////////////////////////////////////////////

	template<typename T>
	RHO__cuda inline Any& operator=(T* ptr) {
		static_cast<CoreBase&>(this->core_).Free();
		(new(&this->core_) Core<T>())->ptr = ptr;

		return *this;
	}

	RHO__cuda inline Any& operator=(nullptr_t ptr) {
		static_cast<CoreBase&>(this->core_).Free();
		this->core_.ptr = nullptr;

		return *this;
	}

	RHO__cuda inline Any& operator=(Any&& any) {
		if (this != &any) {
			static_cast<CoreBase&>(this->core_).Free();
			any.core_.Copy(&this->core_);
			this->core_.ptr = any.core_.ptr;
			any.core_.ptr = nullptr;
		}

		return *this;
	}

#////////////////////////////////////////////////

	template<typename T>
	RHO__cuda inline T* Get()const
	{ return static_cast<T*>(this->core_.ptr); }

	template<typename T>
	RHO__cuda inline T* Release() {
		T* r(static_cast<T*>(this->core_.ptr));
		this->core_.ptr = nullptr;
		return r;
	}

	RHO__cuda inline static void Swap(Any& x, Any& y) {
		if (&x != &y) {
			void* temp(x.core_.ptr);
			x.core_.ptr = y.core_.ptr;
			y.core_.ptr = temp;
		}
	}

private:
	Core<char> core_;
	// it is not exact Core<char>
	// it aim to alloc memory to contain any type of Core
};

}
}

#endif