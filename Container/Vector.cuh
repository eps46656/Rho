#ifndef RHO__define_guard__Container__Vector_cuh
#define RHO__define_guard__Container__Vector_cuh

#include "../Base/memory.cuh"

#define RHO__throw__local(desc) RHO__throw(cntr::Vector<T>, __func__, desc)

namespace rho {
namespace cntr {

template<typename T> class Vector {
public:
	using Iterator = T*;
	using ConstIterator = const T*;

	RHO__cuda size_t size() const { return this->size_; }
	RHO__cuda size_t capacity() const { return this->capacity_; }

	RHO__cuda Iterator begin() { return this->data_; }
	RHO__cuda ConstIterator begin() const { return this->data_; }

	RHO__cuda Iterator end() { return this->data_ + this->size_; }
	RHO__cuda ConstIterator end() const { return this->data_ + this->size_; }

	RHO__cuda bool empty() const { return this->size_ == 0; }

	RHO__cuda T* data() const { return this->data_; }

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Vector(): size_(0), capacity_(0), data_(nullptr) {}

	RHO__cuda Vector(size_t size):
		size_(0), capacity_(size),
		data_(this->capacity_ ? Malloc<T>(size) : nullptr) {
		for (; this->size_ != size; ++this->size_) {
			new (this->data_ + this->size_) T();
		}
	}

	RHO__cuda Vector(const Vector& vector):
		size_(0), capacity_(vector.size_), data_(Malloc<T>(this->capacity_)) {
		for (; this->size_ != vector.size_; ++this->size_) {
			new (this->data_ + this->size_) T(vector.data_[this->size_]);
		}
	}

	RHO__cuda Vector(Vector&& vector):
		size_(vector.size_), capacity_(vector.capacity_), data_(vector.data_) {
		vector.size_ = vector.capacity_ = 0;
		vector.data_ = nullptr;
	}

	template<typename Iterator>
	RHO__cuda Vector(Iterator begin, Iterator end):
		size_(end - begin), capacity_(this->size_),
		data_(this->capacity_ ? Malloc<T>(this->capacity_) : nullptr) {
		for (T* i(this->data_); begin != end; ++begin, ++i) {
			new (i) T(*begin);
		}
	}

	RHO__cuda ~Vector() { rho::Delete(this->size_, this->data_); }

#///////////////////////////////////////////////////////////////////////////////

	template<typename... Args> RHO__cuda static Vector Make(Args&&... args) {
		Vector r(0, sizeof...(args));
		r.Make_(Forward<Args>(args)...);

		return r;
	}

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Vector& operator=(const Vector& vector) {
		if (this == &vector) { return *this; }

		size_t i(0);

		if (this->capacity_ < vector.size_) {
			Delete(this->size_, this->data_);
			this->data_ =
				Malloc<T>(this->size_ = this->capacity_ = vector.size_);

			for (; i != this->size_; ++i) {
				new (this->data_ + i) T(vector.data_[i]);
			}

			return *this;
		}

		if (this->size_ < vector.size_) {
			for (; i != this->size_; ++i) { this->data_[i] = vector.data_[i]; }

			for (; i != vector.size_; ++i) {
				new (this->data_ + i) T(vector.data_[i]);
			}
		} else {
			for (; i != vector.size_; ++i) { this->data_[i] = vector.data_[i]; }
			for (; i != this->size_; ++i) { this->data_[i].~T(); }
		}

		this->size_ = vector.size_;

		return *this;
	}

	RHO__cuda Vector& operator=(Vector&& vector) {
		if (this == &vector) { return *this; }

		Destroy(this->size_, this->data_);
		this->size_ = vector.size_;
		vector.size_ = 0;
		rho::Swap(this->capacity_, vector.capacity_);
		rho::Swap(this->data_, vector.data_);

		return *this;
	}

#///////////////////////////////////////////////////////////////////////////////

	template<typename Y>
	RHO__cuda bool operator==(const Vector<Y>& vector) const {
		if (this == &vector) { return true; }
		if (this->size_ != vector.size_) { return false; }

		for (size_t i(0); i != this->size_; ++i) {
			if (this->data_[i] != vector.data_[i]) { return false; }
		}

		return true;
	}

	template<typename Y>
	RHO__cuda bool operator!=(const Vector<Y>& vector) const {
		if (this == &vector) { return false; }
		if (this->size_ != vector.size_) { return true; }

		for (size_t i(0); i != this->size_; ++i) {
			if (this->data_[i] != vector.data_[i]) { return true; }
		}

		return false;
	}

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda T& operator[](size_t index) { return this->data_[index]; }

	RHO__cuda const T& operator[](size_t index) const {
		return this->data_[index];
	}

	RHO__cuda T& at(size_t index) {
		RHO__debug_if(this->size_ <= index) {
			RHO__throw__local("index error");
		}

		return this->data_[index];
	}

	RHO__cuda const T& at(size_t index) const {
		RHO__debug_if(this->size_ <= index) {
			RHO__throw__local("index error");
		}

		return this->data_[index];
	}

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda T& front() {
		RHO__debug_if(!this->size_) { RHO__throw__local("index error"); }
		return *this->data_;
	}

	RHO__cuda const T& front() const {
		RHO__debug_if(!this->size_) { RHO__throw__local("index error"); }
		return *this->data_;
	}

	RHO__cuda T& back() {
		RHO__debug_if(!this->size_) { RHO__throw__local("index error"); }
		return this->data_[this->size_ - 1];
	}

	RHO__cuda const T& back() const {
		RHO__debug_if(!this->size_) { RHO__throw__local("index error"); }
		return this->data_[this->size_ - 1];
	}

#///////////////////////////////////////////////////////////////////////////////

	template<typename... Args> RHO__cuda T& Push(Args&&... args) {
		this->Reserve(this->size_ + 1);

		T* r(new (this->data_ + this->size_) T(Forward<Args>(args)...));

		++this->size_;

		return *r;
	}

	template<typename... Args>
	RHO__cuda Iterator Insert(Iterator index, Args&&... args) {
		RHO__debug_if(!this->valid_(index)) {
			RHO__throw__local("index error");
		}

		if (this->size_ == this->capacity_) {
			if (this->capacity_) {
				this->capacity_ <<= 1;
			} else {
				++this->capacity_;
			}

			T* data(Malloc<T>(this->capacity_));

			T* i(this->data_);
			T* j(data);

			for (; i != index; ++i, ++j) {
				new (j) T(Move(*i));
				i->~T();
			}

			T* r(new (j) T(Forward<Args>(args)...));

			T* end(this->data_ + this->size_);

			for (++j; i != end; ++i, ++j) {
				new (j) T(Move(*i));
				i->~T();
			}

			++this->size_;
			Free(this->data_);
			this->data_ = data;

			return r;
		}

		T* i(this->data_ + this->size_ - 1);

		for (T* end(index - 1); i != end; --i) {
			new (i + 1) T(Move(*i));
			i->~T();
		}

		++this->size_;

		return new (index) T(Forward<Args>(args)...);
	}

	template<typename Iterator>
	RHO__cuda T* Insert(T* index, Iterator begin, Iterator end) {
		size_t d_size(end - begin);

		if (!d_size) { return index; }

		if (this->capacity_ < this->size_ + d_size) {
			T* data(Malloc<T>(this->size_ + d_size));

			T* i(this->data_);
			T* j(data);

			for (; i != index; ++i, ++j) {
				new (j) T(Move(*i));
				i->~T();
			}

			T* r(j);

			for (; begin != end; ++begin, ++j) { new (j) T(*begin); }

			for (T* end(this->data_ + this->size_); i != end; ++i, ++j) {
				new (j) T(Move(*i));
				i->~T();
			}

			this->capacity_ = (this->size_ += d_size);
			Free(this->data_);
			this->data_ = data;

			return r;
		}

		T* i(this->data_ + this->size_ - 1);

		for (T* end(index - 1); i != end; --i) {
			new (i + d_size) T(Move(*i));
			i->~T();
		}

		for (++i; begin != end; ++begin, ++i) { new (i) T(*begin); }

		this->size_ += d_size;

		return index;
	}

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda void Pop() {
		RHO__debug_if(!this->size_) { RHO__throw__local("index error"); }

		--this->size_;
		this->data_[this->size_].~T();
	}

#///////////////////////////////////////////////////////////////////////////////

	template<typename Y> RHO__cuda bool FindDelete(Y&& index) {
		for (size_t i(0); i != this->size_; ++i) {
			if (this->data_[i] == index) {
				size_t r(i);

				for (--this->size_; i != this->size_; ++i)
					this->data_[i] = Move(this->data_[i + 1]);

				this->data_[this->size_].~T();

				return r;
			}
		}

		return this->size_;
	}

	RHO__cuda T* Delete(T* index) {
		RHO__debug_if(!this->valid_(index)) {
			RHO__throw__local("index error");
		}

		T* end(this->data_ + (this->size_ -= 1));

		for (T* i(index); i != end; ++i) { *i = Move(i[1]); }

		end->~T();

		return index;
	}

	RHO__cuda T* Erase(T* begin, T* end) {
		RHO__debug_if(!this->valid_(begin, end)) {
			RHO__throw__local("index error");
		}

		if (begin == end) { return begin; }

		T* r(begin);

		for (T* end_(this->data_ + this->size_); end != end_; ++begin, ++end) {
			*begin = Move(*end);
		}

		this->size_ = begin - this->data_;

		for (; begin != end; ++begin) { begin->~T(); }

		return r;
	}

	RHO__cuda T* Replace(T* data, size_t capacity) {
		RHO__debug_if(capacity < this->size_) {
			RHO__throw__local("capacity error");
		}

		for (size_t i(0); i != this->size_; ++i) {
			new (data + i) T(Move(this->data_[i]));
			this->data_[i].~T();
		}

		this->capacity_ = capacity;

		T* old_data(this->data_);
		this->data_ = data;

		return old_data;
	}

	RHO__cuda T* Release() {
		T* old_data(this->data_);

		this->size_ = this->capacity_ = 0;
		this->data_ = nullptr;

		return old_data;
	}

	RHO__cuda void Clear() {
		Destroy(this->size_, this->data_);
		this->size_ = 0;
	}

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda void Reserve(size_t capacity) {
		if (capacity <= this->capacity_) { return; }

		T* data(Malloc<T>(this->capacity_ = capacity));

		for (size_t i(0); i != this->size_; ++i) {
			new (data + i) T(Move(this->data_[i]));
			this->data_[i].~T();
		}

		Free(this->data_);
		this->data_ = data;
	}

	RHO__cuda void MoreReserve(size_t d_capacity) {
		this->Reserve(this->size_ + d_capacity);
	}

	template<typename... Args>
	RHO__cuda void Resize(size_t size, Args&&... args) {
		if (this->size_ < size) {
			this->Reserve(size);

			for (; this->size_ != size; ++this->size_)
				new (this->data_ + this->size_) T(Forward<Args>(args)...);
		} else {
			Destroy(this->size_ - size, this->data_ + size);
			this->size_ = size;
		}
	}

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda static void Swap(Vector& x, Vector& y) {
		rho::Swap(x.size_, y.size_);
		rho::Swap(x.capacity_, y.capacity_);
		rho::Swap(x.data_, y.data_);
	}

protected:
	size_t size_;
	size_t capacity_;
	T* data_;

	RHO__cuda void Make_() {}

	template<typename Y, typename... Args>
	RHO__cuda void Make_(Y&& x, Args&&... args) {
		new (this->data_ + this->size_) T(Forward<Y>(x));
		++this->size_;
		this->Make_(Forward<Args>(args)...);
	}

	RHO__cuda bool valid_(const T* index) const {
		diff_t diff(index - this->data_);
		return 0 <= diff && size_t(diff) < this->size_;
	}

	RHO__cuda bool valid_(const T* begin, const T* end) {
		diff_t diff(end - begin);
		return 0 <= diff && size_t(diff) <= this->size_ && this->valid_(begin);
	}
};

}
}

#undef RHO__throw__local

#endif