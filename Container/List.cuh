#ifndef RHO__define_guard__Container__List_cuh
#define RHO__define_guard__Container__List_cuh

#include "BidirectionalNode.cuh"

#define RHO__throw__local(desc)                                                \
	RHO__throw(cntr::List<T, Compare>, __func__, desc);

namespace rho {
namespace cntr {

template<typename T> class List {
public:
	struct Node: public BidirectionalNode {
		T value;

		template<typename... Args> RHO__cuda Node(Args&&... args);
	};

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

	template<typename T_t, typename Node_t> struct Iterator_ {
	public:
		friend class List<T>;

		RHO__cuda bool operator==(const Iterator_& iter) const;
		RHO__cuda bool operator!=(const Iterator_& iter) const;

		RHO__cuda T_t& operator*() const;
		RHO__cuda T_t* operator->() const;

		RHO__cuda Iterator_& operator++();
		RHO__cuda Iterator_& operator--();

	private:
		Node_t* node_;

		RHO__cuda Iterator_(Node_t* node);
	};

	using Iterator = Iterator_<T, Node>;
	using ConstIterator = Iterator_<const T, const Node>;

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda size_t size() const;
	RHO__cuda bool empty() const;

	RHO__cuda Iterator begin();
	RHO__cuda Iterator end();

	RHO__cuda ConstIterator begin() const;
	RHO__cuda ConstIterator end() const;

	RHO__cuda ConstIterator const_begin();
	RHO__cuda ConstIterator const_end();

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda List();
	RHO__cuda List(const List<T>& list);
	RHO__cuda List(List<T>&& list);

	RHO__cuda ~List();

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda T& front();
	RHO__cuda const T& front() const;

	RHO__cuda T& back();
	RHO__cuda const T& back() const;

#///////////////////////////////////////////////////////////////////////////////

	template<typename... Args> RHO__cuda void PushFront(Args&&... args);
	template<typename... Args> RHO__cuda void PushBack(Args&&... args);

private:
	size_t size_;
	BidirectionalNode node_;
};

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

template<typename T> size_t List<T>::size() const { return this->size_; }

template<typename T> bool List<T>::empty() const { return !this->size_; }

#///////////////////////////////////////////////////////////////////////////////

template<typename T> List<T>::Iterator List<T>::begin() {
	return this->node_->next;
}
template<typename T> List<T>::Iterator List<T>::end() { return this->node_; }

template<typename T> List<T>::ConstIterator List<T>::begin() const {
	return this->node_->next;
}
template<typename T> List<T>::ConstIterator List<T>::end() const {
	return this->node_;
}

template<typename T> List<T>::ConstIterator List<T>::const_begin() {
	return this->node_->next;
}
template<typename T> List<T>::ConstIterator List<T>::const_end() {
	return this->node_;
}

#///////////////////////////////////////////////////////////////////////////////

template<typename T> List<T>::List(): size_(0) {}

template<typename T> List<T>::List(const List<T>& list): size_(list.size_) {
	for (Node* i(list.node_->next); i != list.node_;
		 i = static_cast<Node*>(i->next)) {
		this->node_->PushFront(new Node(i->value));
	}
}

template<typename T> List<T>::List(List<T>&& list): size_(list.size_) {
	list.size_ = 0;
	Node::Swap(this->node_, list.node_);
}

template<typename T> List<T>::~List() {
	Node* n(this->node_->next);
	Node* m;

	while (n != this->node_) {
		m = n->next;
		Delete(n);
		n = m;
	}
}

#///////////////////////////////////////////////////////////////////////////////

template<typename T> T& List<T>::front() {
	return static_cast<Node*>(this->node_->next)->value;
}

template<typename T> const T& List<T>::front() const {
	return static_cast<Node*>(this->node_->next)->value;
}

template<typename T> T& List<T>::back() {
	return static_cast<Node*>(this->node_->prev)->value;
}

template<typename T> const T& List<T>::back() const {
	return static_cast<Node*>(this->node_->prev)->value;
}

#///////////////////////////////////////////////////////////////////////////////

template<typename T>
template<typename... Args>
void List<T>::PushFront(Args&&... args) {
	++this->size_;
	this->node_.PushBack(new Node(Forward<Args>(args)...));
}

template<typename T>
template<typename... Args>
void List<T>::PushBack(Args&&... args) {
	++this->size_;
	this->node_.PushFront(new Node(Forward<Args>(args)...));
}

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

template<typename T>
template<typename... Args>
List<T>::Node::Node(Args&&... args): value(Forward<Args>(args)...) {}

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

#define RHO__list_iter List<T>::Iterator_<T_t, Node_t>

template<typename T>
template<typename T_t, typename Node_t>
RHO__list_iter::Iterator_(Node_t* node): node_(node) {}

#///////////////////////////////////////////////////////////////////////////////

template<typename T>
template<typename T_t, typename Node_t>
bool RHO__list_iter::operator==(const Iterator_& iter) const {
	return this->node_ == iter.node_;
}

template<typename T>
template<typename T_t, typename Node_t>
bool RHO__list_iter::operator!=(const Iterator_& iter) const {
	return this->node_ != iter.node_;
}

#///////////////////////////////////////////////////////////////////////////////

template<typename T>
template<typename T_t, typename Node_t>
T_t& RHO__list_iter::operator*() const {
	return *this->node_;
}

template<typename T>
template<typename T_t, typename Node_t>
T_t* RHO__list_iter::operator->() const {
	return this->node_;
}

#///////////////////////////////////////////////////////////////////////////////

template<typename T>
template<typename T_t, typename Node_t>
RHO__list_iter& RHO__list_iter::operator--() {
	this->node_ = static_cast<Node_t*>(this->node_->prev);
	return *this;
}

template<typename T>
template<typename T_t, typename Node_t>
RHO__list_iter& RHO__list_iter::operator++() {
	this->node_ = static_cast<Node_t*>(this->node_->next);
	return *this;
}

}
}

#undef RHO__throw__local
#undef RHO__list_iter

#endif