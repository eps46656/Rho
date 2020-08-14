#ifndef RHO__define_guard__Container__BidirectionalNode_cuh
#define RHO__define_guard__Container__BidirectionalNode_cuh

#include "../Base/memory.cuh"
#include "../define.cuh"

namespace rho {
namespace cntr {

struct BidirectionalNode {
	using Self = BidirectionalNode;

#///////////////////////////////////////////////////////////////////////////////

	Self* prev;
	Self* next;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda BidirectionalNode(): prev(this), next(this) {}
	RHO__cuda virtual ~BidirectionalNode() { this->Pop(); }

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda static void Link(Self* x, Self* y) { (y->prev = x)->next = y; }

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda void PushPrev(Self* node) {
		if (this == node || this == node->next) { return; }
		if (node != node->prev) { Link(node->prev, node->next); }

		Link(this->prev, node);
		Link(node, this);
	}

	RHO__cuda void PushPrev(Self* begin, Self* end) {
		if (begin->prev != end) { Link(begin->prev, end); }

		Self* begin_(begin->prev);
		Self* end_(end->prev);

		Link(this->prev, begin);
		Link(end_, this);

		if (begin_ != end) { Link(begin_, end); }
	}

	RHO__cuda void PushNext(Self* node) {
		if (this == node || this == node->prev) { return; }
		if (node != node->prev) { Link(node->prev, node->next); }

		Link(node, this->next);
		Link(this, node);
	}

	RHO__cuda void PushNext(Self* begin, Self* end) {
		Self* begin_(begin->prev);
		Self* end_(end->prev);

		Link(end_, this->next);
		Link(this, begin);

		if (begin_ != end) { Link(begin_, end); }
	}

	RHO__cuda Self* Pop() {
		if (this != this->prev) {
			Link(this->prev, this->next);
			this->prev = this->next = this;
		}

		return this;
	}

	RHO__cuda static void Pop(Self* begin, Self* end) {
		Self* begin_(begin->prev);
		Self* end_(end->prev);

		if (begin != end) {
			Link(begin_, end);
			Link(begin, end_);
		}
	}

	RHO__cuda void Replace(Self* node) {
		if (this == node) { return; }

		if (node != node->prev) { Link(node->prev, node->next); }

		Link(this->prev, node);
		Link(node, this->next);

		this->prev = this->next = this;
	}

	RHO__cuda void Reverse() {
		Self* prev_(this->prev);
		Self* next_(this->next);

		Link(next_, this);
		Link(this, prev_);
	}

	RHO__cuda void ReverseAll() {
		rho::Swap(*this->prev, *this->next);

		for (Self* i(this->next); i != this; i = i->next) {
			rho::Swap(*i->prev, *i->next);
		}
	}

	RHO__cuda static void Swap(Self& x, Self& y) {
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
};

}
}

#endif
