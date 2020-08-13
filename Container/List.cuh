#ifndef RHO__define_guard__Container__List_cuh
#define RHO__define_guard__Container__List_cuh

#include "BidirectionalNode.cuh"

#define RHO__throw__local(desc)                                                \
	RHO__throw(cntr::List<T, Compare>, __func__, desc);

#define RHO__Node(x) static_cast<Node*>(x)

namespace rho {
namespace cntr {

template<typename T> class List {
public:
	struct Node: public BidirectionalNode {
		T value;

		template<typename... Args>
		RHO__cuda Node(Args&&... args): value(Forward<Args>(args)...) {}
	};

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

	template<typename T_t, typename Node_t> struct Iterator_ {
	public:
		friend class List<T>;

		RHO__cuda bool operator==(const Iterator_& iter) const {
			return this->node_ == iter.node_;
		}
		RHO__cuda bool operator!=(const Iterator_& iter) const {
			this->node_ != iter.node_;
		}

		RHO__cuda T_t& operator*() const { return *this->node_->value; }
		RHO__cuda T_t* operator->() const { return this->node_->valeu; }

		RHO__cuda Iterator_& operator++() {
			this->node_ = static_cast<Node_t*>(this->node_->next);
			return *this;
		}

		RHO__cuda Iterator_& operator--() {
			this->node_ = static_cast<Node_t*>(this->node_->prev);
			return *this;
		}

	private:
		Node_t* node_;

		RHO__cuda Iterator_(Node_t* node): node_(node) {}
	};

	using Iterator = Iterator_<T, Node>;
	using ConstIterator = Iterator_<const T, const Node>;

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda size_t size() const { return this->size_; }
	RHO__cuda bool empty() const { return !this->size_; }

	RHO__cuda Iterator begin() { return this->node_->next; }
	RHO__cuda Iterator end() { return this->end_; }

	RHO__cuda ConstIterator begin() const { return this->node_->next; }
	RHO__cuda ConstIterator end() const { return this->end_; }

	RHO__cuda ConstIterator const_begin() { return this->node_->next; }
	RHO__cuda ConstIterator const_end() { return this->end_; }

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda List(): size_(0), end_(&this->node_) {}

	RHO__cuda List(const List<T>& list): size_(list.size_), end_(&this->node_) {
		for (Node* i(list.node_->next); i != list.node_;
			 i = static_cast<Node*>(i->next)) {
			this->node_->PushFront(new Node(i->value));
		}
	}

	RHO__cuda List(List<T>&& list): size_(list.size_), end_(list.end_) {
		list.size_ = 0;
		Node::Swap(this->node_, list.node_);
	}

	RHO__cuda ~List() {
		Node* n(this->node_->next);
		Node* m;

		while (n != this->end_) {
			m = n->next;
			Delete(n);
			n = m;
		}

		while (n != this->node_) {
			m = n->next;
			Free(n);
			n = m;
		}
	}

#///////////////////////////////////////////////////////////////////////////////

#define RHO__F(x) static_cast<Node*>(this->node_->##x##)

	RHO__cuda T& front() { return RHO__F(next)->value; }
	RHO__cuda const T& front() const { RHO__F(next)->value; }

	RHO__cuda T& back() { return RHO__F(prev)->value; }
	RHO__cuda const T& back() const { return RHO__F(prev)->value; }

#undef RHO__F

#///////////////////////////////////////////////////////////////////////////////

	template<typename... Args> RHO__cuda void PushFront(Args&&... args) {
		++this->size_;

		if (this->end_ == &this->node_) {
			this->node_.PushBack(new Node(Forward<Args>(args)...));
			return;
		}

		Node::Swap(this->node_->prev, this->node_);
		new (&static_cast<Node*>(this->node_->next)->value)
			T(Forward<Args>(args));

		if (this->end_ == this->node_->next) { this->end_ = &this->node_; }
	}

	template<typename... Args> RHO__cuda void PushBack(Args&&... args) {
		++this->size_;

		if (this->end_ == &this->node_) {
			this->node_.PushFront(new Node(Forward<Args>(args)...));
			return;
		}

		new (&static_cast<Node*>(this->end_)->value) T(Forward<Args>(args));
		this->end_ = this->end_->next;
	}

private:
	size_t size_;
	BidirectionalNode* end_;
	BidirectionalNode node_;
};

}
}

#undef RHO__throw__local

#endif