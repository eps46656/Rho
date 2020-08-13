#ifndef RHO__define_guard__Pointer__Unique_cuh
#define RHO__define_guard__Pointer__Unique_cuh

#include "../Base/memory.cuh"

namespace rho {
namespace ptr {

template<typename T> struct Unique {
public:
	RHO__cuda Unique();
	RHO__cuda explicit Unique(T* ptr);
	RHO__cuda Unique(Unique&& unique);

	RHO__cuda ~Unique();

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda operator bool() const;
	RHO__cuda operator T*() const;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Unique& operator=(T* ptr);
	RHO__cuda Unique& operator=(Unique&& unique);

#///////////////////////////////////////////////////////////////////////////////

	template<typename Y> RHO__cuda Y Get() const;

	RHO__cuda T& operator*() const;
	RHO__cuda T* operator->() const;
	RHO__cuda T& operator[](size_t index) const;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda T* Release();

	RHO__cuda static void Swap(Unique& x, Unique& y);

private:
	T* ptr_;
};

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

template<typename T> Unique<T>::Unique(): ptr_(nullptr) {}

template<typename T> Unique<T>::Unique(T* ptr): ptr_(ptr) {}

template<typename T> Unique<T>::Unique(Unique<T>&& unique): ptr_(unique.ptr_) {
	unique.ptr_ = nullptr;
}

template<typename T> Unique<T>::~Unique() { Delete(this->ptr_); }

#///////////////////////////////////////////////////////////////////////////////

template<typename T> Unique<T>::operator bool() const { return this->ptr_; }

template<typename T> Unique<T>::operator T*() const { return this->ptr_; }

#///////////////////////////////////////////////////////////////////////////////

template<typename T> Unique<T>& Unique<T>::operator=(T* ptr) {
	Delete(this->ptr_);
	this->ptr_ = ptr;

	return *this;
}

template<typename T> Unique<T>& Unique<T>::operator=(Unique&& unique) {
	if (this != &unique) {
		Delete(this->ptr_);
		this->ptr_ = unique.ptr_;
		unique.ptr_ = nullptr;
	}

	return *this;
}

#///////////////////////////////////////////////////////////////////////////////

template<typename T> template<typename Y> Y Unique<T>::Get() const {
	return static_cast<Y>(this->ptr_);
}

template<typename T> T& Unique<T>::operator*() const { return *this->ptr_; }

template<typename T> T* Unique<T>::operator->() const { return this->ptr_; }

template<typename T> T& Unique<T>::operator[](size_t index) const {
	return this->ptr_[index];
}

#///////////////////////////////////////////////////////////////////////////////

template<typename T> T* Unique<T>::Release() {
	T* r(this->ptr_);
	this->ptr_ = nullptr;
	return r;
}

template<typename T> void Unique<T>::Swap(Unique& x, Unique& y) {
	if (&x != &y) {
		T* temp(x.ptr_);
		x.ptr_ = y.ptr_;
		y.ptr_ = temp;
	}
}

}

template<typename T> RHO__cuda void Swap(ptr::Unique<T>& x, ptr::Unique<T>& y) {
	ptr::Unique<T>::Swap(x, y);
}

}

#endif