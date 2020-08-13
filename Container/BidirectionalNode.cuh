#ifndef RHO__define_guard__Container__BidirectionalNode_cuh
#define RHO__define_guard__Container__BidirectionalNode_cuh

#include "../Base/memory.cuh"
#include "../define.cuh"

#define RHO__throw__local(desc) RHO__throw(BidirectionalNode, __func__, desc);

namespace rho {
namespace cntr {

struct BidirectionalNode {
	using Self = BidirectionalNode;

#///////////////////////////////////////////////////////////////////////////////

	Self* prev;
	Self* next;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda BidirectionalNode();
	RHO__cuda virtual ~BidirectionalNode();

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda static void Link(Self* x, Self* y);

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda void PushFront(Self* node);
	RHO__cuda void PushFront(Self* begin, Self* end);

	RHO__cuda void PushBack(Self* node);
	RHO__cuda void PushBack(Self* begin, Self* end);

	RHO__cuda Self* Pop();
	RHO__cuda static void Pop(Self* begin, Self* end);

	RHO__cuda void Replace(Self* node);

	RHO__cuda void Reverse();
	RHO__cuda void ReverseAll();

	RHO__cuda static void Swap(Self& x, Self& y);
};

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

inline BidirectionalNode::BidirectionalNode(): prev(this), next(this) {}
inline BidirectionalNode::~BidirectionalNode() { this->Pop(); }

#///////////////////////////////////////////////////////////////////////////////

inline void BidirectionalNode::Link(Self* x, Self* y) {
	(y->prev = x)->next = y;
}

inline void BidirectionalNode::PushFront(Self* node) {
	if (node != node->prev) { Link(node->prev, node->next); }

	Link(this->prev, node);
	Link(node, this);
}

inline void BidirectionalNode::PushFront(Self* begin, Self* end) {
	RHO__debug_if(!begin || !end) RHO__throw__local("nullptr error");

	if (begin->prev != end) { Link(begin->prev, end); }

	Self* begin_(begin->prev);
	Self* end_(end->prev);

	Link(this->prev, begin);
	Link(end_, this);

	if (begin_ != end) { Link(begin_, end); }
}

inline void BidirectionalNode::PushBack(Self* node) {
	if (node != node->prev) { Link(node->prev, node->next); }

	Link(node, this->next);
	Link(this, node);
}

inline void BidirectionalNode::PushBack(Self* begin, Self* end) {
	RHO__debug_if(!begin || !end) { RHO__throw__local("nullptr error"); }

	Self* begin_(begin->prev);
	Self* end_(end->prev);

	Link(end_, this->next);
	Link(this, begin);

	if (begin_ != end) { Link(begin_, end); }
}

inline BidirectionalNode* BidirectionalNode::Pop() {
	if (this != this->prev) {
		Link(this->prev, this->next);
		this->prev = this->next = this;
	}

	return this;
}

inline void BidirectionalNode::Pop(Self* begin, Self* end) {
	Self* begin_(begin->prev);
	Self* end_(end->prev);

	if (begin != end) {
		Link(begin_, end);
		Link(begin, end_);
	}
}

inline void BidirectionalNode::Replace(Self* node) {
	if (this == node) { return; }

	if (node != node->prev) { Link(node->prev, node->next); }

	Link(this->prev, node);
	Link(node, this->next);

	this->prev = this->next = this;
}

inline void BidirectionalNode::Reverse() {
	Self* prev_(this->prev);
	Self* next_(this->next);

	Link(next_, this);
	Link(this, prev_);
}

inline void BidirectionalNode::ReverseAll() {
	Swap(*this->prev, *this->next);

	for (Self* i(this->next); i != this; i = i->next) {
		Swap(*i->prev, *i->next);
	}
}

inline void BidirectionalNode::Swap(Self& x, Self& y) {
	if (&x == &y) { return; }

	Self* x_prev(x.prev);
	Self* x_next(x.next);

	if (x_prev == &y) {
		Self* y_prev(y.prev);

		Link(y_prev, &x);
		Link(&x, &y);
		Link(&y, x_next);
	} else if (x_next == &y) {
		Self* y_next(y.next);

		Link(x_prev, &y);
		Link(&y, &x);
		Link(&x, y_next);
	} else {
		Self* y_prev(y.prev);
		Self* y_next(y.next);

		Link(x_prev, &y);
		Link(&y, x_next);
		Link(y_prev, &x);
		Link(&x, y_next);
	}
}

}
}

#undef RHO__throw__local

#endif
