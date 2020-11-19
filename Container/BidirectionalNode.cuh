#ifndef RHO__define_guard__Container__BidirectionalNode_cuh
#define RHO__define_guard__Container__BidirectionalNode_cuh

#include "../Base/memory.cuh"
#include "../define.cuh"

namespace rho {
namespace cntr {

struct BidirectionalNode {
	using Self = BidirectionalNode;

#///////////////////////////////////////////////////////////////////////////////

	template<typename T = Self*> RHO__cuda T prev() const;
	template<typename T = Self*> RHO__cuda T next() const;

	RHO__cuda bool sole() const;
	RHO__cuda bool Contain(const Self* node) const;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda BidirectionalNode();
	RHO__cuda virtual ~BidirectionalNode();

	RHO__cuda static void Link(Self* x, Self* y);

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda inline void PushPrev(Self* node);
	RHO__cuda inline void PushPrevAll(Self* node);
	RHO__cuda inline void PushPrevAllExcept(Self* node);

	RHO__cuda inline void PushNext(Self* node);
	RHO__cuda inline void PushNextAll(Self* node);
	RHO__cuda inline void PushNextAllExcept(Self* node);

	RHO__cuda inline Self* Pop();

	RHO__cuda inline void Replace(Self* node);

	RHO__cuda inline void ReverseAll();

	RHO__cuda inline static void Swap(Self& x, Self& y);

private:
	Self* prev_;
	Self* next_;
};

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

template<typename T> T BidirectionalNode::prev() const {
	return static_cast<T>(this->prev_);
}

template<typename T> T BidirectionalNode::next() const {
	return static_cast<T>(this->next_);
}

inline bool BidirectionalNode::sole() const { return this->prev_ == this; }

inline void BidirectionalNode::Link(Self* x, Self* y) {
	(y->prev_ = x)->next_ = y;
}

inline bool BidirectionalNode::Contain(const Self* node) const {
	if (node == this) { return true; }

	for (Self* i(this->next_); i != this; i = i->next_) {
		if (i == node) { return true; }
	}

	return false;
}

#///////////////////////////////////////////////////////////////////////////////

inline BidirectionalNode::BidirectionalNode(): prev_(this), next_(this) {}
inline BidirectionalNode::~BidirectionalNode() { this->Pop(); }

#///////////////////////////////////////////////////////////////////////////////

void BidirectionalNode::PushPrev(Self* node) {
	if (node == this || node == this->prev_) { return; }
	if (!node->sole()) { Link(node->prev_, node->next_); }

	Link(this->prev_, node);
	Link(node, this);
}

void BidirectionalNode::PushPrevAll(Self* node) {
	if (node == this) { return; }
	Link(this->prev_, node->next_);
	Link(node, this);
}

void BidirectionalNode::PushPrevAllExcept(Self* node) {
	if (node->sole() || this->Contain(node)) { return; }
	Link(this->prev_, node->next_);
	Link(node->prev_, this);
}

void BidirectionalNode::PushNext(Self* node) {
	if (node == this || node == this->next_) { return; }
	if (!node->sole()) { Link(node->prev_, node->next_); }

	Link(node, this->next_);
	Link(this, node);
}

void BidirectionalNode::PushNextAll(Self* node) {
	if (node == this) { return; }
	Link(node->prev_, this->next_);
	Link(this, node);
}

void BidirectionalNode::PushNextAllExcept(Self* node) {
	if (node->sole() || this->Contain(node)) { return; }
	Link(node->prev_, this->next_);
	Link(this, node);
}

#///////////////////////////////////////////////////////////////////////////////

BidirectionalNode::Self* BidirectionalNode::Pop() {
	if (this->sole()) { return this; }
	Link(this->prev_, this->next_);
	this->prev_ = this->next_ = this;
	return this;
}

void BidirectionalNode::Replace(Self* node) {
	if (node == this) { return; }
	if (!node->sole()) { Link(node->prev_, node->next_); }

	Link(this->prev_, node);
	Link(node, this->next_);

	this->prev_ = this->next_ = this;
}

void BidirectionalNode::ReverseAll() {
	rho::Swap(*this->prev_, *this->next_);

	for (Self* i(this->next_); i != this; i = i->next_) {
		rho::Swap(*i->prev_, *i->next_);
	}
}

void BidirectionalNode::Swap(Self& x, Self& y) {
	if (&x == &y) { return; }

	Self* x_prev_(x.prev_);
	Self* y_prev_(y.prev_);

	if (x_prev_ == &y) {
		Link(y_prev_, &x);
		Link(&y, x.next_);
		Link(&x, &y);
	} else if (y_prev_ == &x) {
		Link(x_prev_, &y);
		Link(&x, y.next_);
		Link(&y, &x);
	} else {
		Self* x_next_(x.next_);
		Self* y_next_(y.next_);

		Link(x_prev_, &y);
		Link(&y, x_next_);
		Link(y_prev_, &x);
		Link(&x, y_next_);
	}
}

}
}

#endif
