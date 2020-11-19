#ifndef RHO__define_guard__Container__FastList_cuh
#define RHO__define_guard__Container__FastList_cuh

#include "BidirectionalNode.cuh"

#include "BidirectionalNode.cuh"

#define RHO__throw__local(desc) RHO__throw(cntr::List, __func__, desc)

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
			return this->node_ != iter.node_;
		}

		RHO__cuda T_t& operator*() const { return *this->node_->value; }
		RHO__cuda T_t* operator->() const { return this->node_->valeu; }

		RHO__cuda Iterator_& operator++() {
			this->node_ = static_cast<Node_t*>(this->node_->next());
			return *this;
		}

		RHO__cuda Iterator_& operator--() {
			this->node_ = static_cast<Node_t*>(this->node_->prev());
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

	RHO__cuda Iterator begin() {
		return static_cast<Node*>(this->node_.next());
	}
	RHO__cuda Iterator end() { return static_cast<Node*>(this->end_); }

	RHO__cuda ConstIterator begin() const {
		return static_cast<Node*>(this->node_.next());
	}
	RHO__cuda ConstIterator end() const {
		return static_cast<Node*>(this->end_);
	}

	RHO__cuda ConstIterator const_begin() {
		return static_cast<Node*>(this->node_.next());
	}
	RHO__cuda ConstIterator const_end() {
		return static_cast<Node*>(this->end_);
	}

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda List(): size_(0) {}

	RHO__cuda List(const List<T>& list): size_(list.size_) {
		for (Node* i(list.node_.next()); i != list.node_;
			 i = static_cast<Node*>(i->next())) {
			this->node_.PushPrev(new Node(i->value));
		}
	}

	RHO__cuda List(List<T>&& list): size_(list.size_) {
		list.size_ = 0;
		Node::Swap(this->node_, list.node_);
	}

	RHO__cuda ~List() {
		while (this->node_.sole()) { Delete(this->node_.next()); }
	}

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda T& front() {
		return static_cast<Node*>(this->node_.next())->value;
	}
	RHO__cuda const T& front() const {
		return static_cast<Node*>(this->node_.next())->value;
	}

	RHO__cuda T& back() {
		return static_cast<Node*>(this->end_->prev())->value;
	}
	RHO__cuda const T& back() const {
		return static_cast<Node*>(this->end_->prev())->value;
	}

#///////////////////////////////////////////////////////////////////////////////

	template<typename... Args> RHO__cuda void PushFront(Args&&... args) {
		++this->size_;
		this->node_.PushNext(new Node(Forward<Args>(args)...));
	}

	RHO__cuda void PushNodePront(Node* node) {
		RHO__debug_if(!node->sole()) { RHO__throw__local("node error"); }
		++this->size_;
		this->node_.PushNext(node);
	}

	RHO__cuda void PushListFront(List<T>& list) {
		this->size_ += list.size_;
		list.size_ = 0;
		this->node_.PushNextAllExcept(&list.node_);
	}

#///////////////////////////////////////////////////////////////////////////////

	template<typename... Args> RHO__cuda void PushBack(Args&&... args) {
		++this->size_;
		this->node_.PushPrev(new Node(Forward<Args>(args)...));
	}

	RHO__cuda void PushNodeBack(Node* node) {
		RHO__debug_if(!node->sole()) { RHO__throw__local("node error"); }
		++this->size_;
		this->node_.PushPrev(node);
	}

	RHO__cuda void PushListBack(List<T>& list) {
		this->size_ += list.size_;
		list.size_ = 0;
		this->node_.PushPrevAllExcept(&list.node_);
	}

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda void PopFront() {
		RHO__debug_if(!this->size_) { RHO__throw__local("size error"); }

		--this->size_;
		Delete(this->node_.next()->Pop());
	}

	RHO__cuda void PopBack() {
		RHO__debug_if(!this->size_) { RHO__throw__local("size error"); }

		--this->size_;
		Delete(this->node_.prev()->Pop());
	}

private:
	size_t size_;
	BidirectionalNode node_;
};

}
}

#undef RHO__throw__local

#endif