#ifndef RHO__define_guard__Container__RedBlackTreeNode_cuh
#define RHO__define_guard__Container__RedBlackTreeNode_cuh

#include "../define.cuh"

#define RHO__throw__local(discription)                                         \
	RHO__throw(container::RedBlackTreeNode, __func__, discription);

namespace rho {
namespace cntr {

struct RedBlackTreeNode {
	using Self = RedBlackTreeNode;
	static constexpr bool black = false;
	static constexpr bool red = true;

#///////////////////////////////////////////////////////////////////////////////

	Self* p;
	Self* l;
	Self* r;
	bool color;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda RedBlackTreeNode();
	RHO__cuda virtual ~RedBlackTreeNode();

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda Self* prev();
	RHO__cuda const Self* prev() const;

	RHO__cuda Self* next();
	RHO__cuda const Self* next() const;

	RHO__cuda Self* root();
	RHO__cuda const Self* root() const;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda void RotateL();
	RHO__cuda void RotateR();

	RHO__cuda static void Swap(Self* x, Self* y);

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda void InsertL(Self* n);
	RHO__cuda void InsertR(Self* n);
	RHO__cuda void InsertFix();

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda void Release();
	RHO__cuda void ReleaseFix();
};

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

inline RedBlackTreeNode::RedBlackTreeNode():
	p(nullptr), l(nullptr), r(nullptr), color(black) {}

inline RedBlackTreeNode::~RedBlackTreeNode() { this->Release(); }

#///////////////////////////////////////////////////////////////////////////////

inline RedBlackTreeNode* RedBlackTreeNode::prev() {
	if (this->l) {
		Self* n(this->l);
		while (n->r) { n = n->r; }
		return n;
	}

	Self* n(this);
	Self* p(this->p);

	for (; p; p = (n = p)->p) {
		if (n == p->r) { return p; }
	}

	return nullptr;
}

inline const RedBlackTreeNode* RedBlackTreeNode::prev() const {
	return const_cast<Self*>(this)->prev();
}

inline RedBlackTreeNode* RedBlackTreeNode::next() {
	if (this->r) {
		Self* n(this->r);
		while (n->l) { n = n->l; }
		return n;
	}

	Self* n(this);
	Self* p(this->p);

	for (; p; p = (n = p)->p) {
		if (n == p->l) { return p; }
	}

	return nullptr;
}

inline const RedBlackTreeNode* RedBlackTreeNode::next() const {
	return const_cast<Self*>(this)->next();
}

inline RedBlackTreeNode* RedBlackTreeNode::root() {
	Self* r(this);
	while (r->p) { r = r->p; }
	return r;
}

inline const RedBlackTreeNode* RedBlackTreeNode::root() const {
	return const_cast<Self*>(this)->root();
}

inline void RedBlackTreeNode::RotateL() {
	Self* p(this->r->p = this->p);
	Self* r(this->p = this->r);

	if (this->r = r->l) { this->r->p = this; }

	r->l = this;

	if (p) {
		if (this == p->l) {
			p->l = r;
		} else {
			p->r = r;
		}
	}
}

inline void RedBlackTreeNode::RotateR() {
	Self* p(this->l->p = this->p);
	Self* l(this->p = this->l);

	if (this->l = l->r) { this->l->p = this; }

	l->r = this;

	if (p) {
		if (this == p->l) {
			p->l = l;
		} else {
			p->r = l;
		}
	}
}

inline void RedBlackTreeNode::Swap(Self* x, Self* y) {
	RHO__debug_if(!x || !y) { RHO__throw__local("nullptr"); }

	if (x->p == y) {
		Self* temp(x);
		x = y;
		y = temp;
	}

	if (x == y->p) {
		Self* yl(y->l);
		Self* yr(y->r);

		if (y->p = x->p) {
			if (x == x->p->l) {
				y->p->l = y;
			} else {
				y->p->r = y;
			}
		}

		if (x->l == (x->p = y)) {
			if (y->r = (y->l = x)->r) { y->r->p = y; }
		} else {
			if (y->l = (y->r = x)->l) { y->l->p = y; }
		}

		if (x->l = yl) { yl->p = x; }
		if (x->r = yr) { yr->p = x; }

		return;
	}

	Self* xp(x->p);
	Self* xl(x->l);
	Self* xr(x->r);

	Self* yp(y->p);
	Self* yl(y->l);
	Self* yr(y->r);

	if (x->p = yp) {
		if (y == yp->l) {
			yp->l = x;
		} else {
			yp->r = x;
		}
	}

	if (y->p = xp) {
		if (x == xp->l) {
			xp->l = y;
		} else {
			xp->r = y;
		}
	}

	if (x->l = yl) { yl->p = x; }
	if (x->r = yr) { yr->p = x; }

	if (y->l = xl) { xl->p = y; }
	if (y->r = xr) { xr->p = y; }
}

#///////////////////////////////////////////////////////////////////////////////

inline void RedBlackTreeNode::InsertL(Self* node) {
	RHO__debug_if(this->l) { RHO__throw__local("this->l exist"); }
	((node->p = this)->l = node)->color = red;
	if (this->color == red) { node->InsertFix(); }
}

inline void RedBlackTreeNode::InsertR(Self* node) {
	RHO__debug_if(this->r) { RHO__throw__local("this->r exist"); }
	((node->p = this)->r = node)->color = red;
	if (this->color == red) { node->InsertFix(); }
}

inline void RedBlackTreeNode::InsertFix() {
	Self* n(this);
	Self* p;
	Self* g;
	Self* u;

	while ((p = n->p) && p->color == red) {
		if (p == (g = p->p)->l) {
			if (n == p->r) {
				p->RotateL();
				p = (n = p)->p;
			}

			p->color = black;
			g->color = red;

			if (!(u = g->r) || u->color == black) {
				g->RotateR();
				return;
			}
		} else {
			if (n == p->l) {
				p->RotateR();
				p = (n = p)->p;
			}

			p->color = black;
			g->color = red;

			if (!(u = g->l) || u->color == black) {
				g->RotateL();
				return;
			}
		}

		u->color = black;
		if (!(n = g)->p) {
			n->color = black;
			break;
		}
	}
}

#///////////////////////////////////////////////////////////////////////////////

inline void RedBlackTreeNode::Release() {
	if (!this->p && !this->l && !this->r) { return; }

	Self* n(this);
	Self* m;

	if (n->l && n->r) {
		for (m = n->l; m->r; m = m->r) {};

		Swap(n, m);

		if (n->color != m->color) {
			n->color = !n->color;
			m->color = !m->color;
		}
	}

	if (n->color == black) {
		if ((m = n->l) || (m = n->r)) {
			if (m->p = n->p) {
				if (n == m->p->l) {
					m->p->l = m;
				} else {
					m->p->r = m;
				}
			}

			if (m->color == black) {
				m->ReleaseFix();
			} else {
				m->color = black;
			}
		} else {
			n->ReleaseFix();

			if (n == n->p->l) {
				n->p->l = nullptr;
			} else {
				n->p->r = nullptr;
			}
		}
	} else {
		if ((m = n->l) || (m = n->r)) {
			if (n == (m->p = n->p)->l) {
				m->p->l = m;
			} else {
				m->p->r = m;
			}
		} else {
			if (n == n->p->l) {
				n->p->l = nullptr;
			} else {
				n->p->r = nullptr;
			}
		}
	}

	n->p = n->l = n->r = nullptr;
	n->color = black;
}

inline void RedBlackTreeNode::ReleaseFix() {
	Self* n(this);
	Self* p;
	Self* s;

	while (p = n->p) {
		if (n == p->l) {
			if ((s = p->r)->color == red) {
				p->color = red;
				s->color = black;
				p->RotateL();
				s = p->r;
			}

			RedBlackTreeNode* sr(s->r);

			if (sr && sr->color == red) {
				s->color = p->color;
				p->color = sr->color = black;
				p->RotateL();
				return;
			}

			Self* sl(s->l);

			if (sl && sl->color == red) {
				sl->color = p->color;
				p->color = black;
				s->RotateR();
				p->RotateL();
				return;
			}
		} else {
			if ((s = p->l)->color == red) {
				p->color = red;
				s->color = black;
				p->RotateR();
				s = p->l;
			}

			Self* sl(s->l);

			if (sl && sl->color == red) {
				s->color = p->color;
				p->color = sl->color = black;
				p->RotateR();
				return;
			}

			Self* sr(s->r);

			if (sr && sr->color == red) {
				sr->color = p->color;
				p->color = black;
				s->RotateL();
				p->RotateR();
				return;
			}
		}

		if (p->color == red) {
			p->color = black;
			s->color = red;
			return;
		}

		s->color = red;
		n = p;
	}
}

}
}

#undef RHO__throw__local

#endif