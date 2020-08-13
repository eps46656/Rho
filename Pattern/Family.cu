#include"Family.cuh"

namespace rho {
namespace pattern {

Family* Family::child_begin() { return this->next_child; }
Family* Family::child_end() { return this; }

Family* Family::descendant_begin() { return this->next_descendant(); }
Family* Family::descendant_end() { return this->parent; }

const Family* Family::child_begin()const { return this->next_child; }
const Family* Family::child_end()const { return this; }

const Family* Family::descendant_begin()const { return this->next_descendant(); }
const Family* Family::descendant_end()const { return this->parent; }

#////////////////////////////////////////////////

Family::Family() :
	parent(nullptr),
	prev_sibling(nullptr), next_sibling(nullptr),
	prev_child(this), next_child(this) {}

Family::Family(Family* p) :
	parent(p), prev_child(this), next_child(this) {

	if (p == p->prev_child) {
		this->prev_sibling = this->next_sibling = p;
		p->prev_child = p->next_child = this;
	} else {
		this->prev_sibling = p->prev_child;
		p->prev_child->next_sibling = this;

		this->next_sibling = p;
		p->prev_child = this;
	}
}

Family::~Family() { this->Pop(); }

#////////////////////////////////////////////////

Family* Family::next_descendant() {
	if (this != this->prev_child) { return this->next_child; }

	Family* n(this);
	Family* m(this->next_sibling);

	while (m && n == m->prev_child)
		m = (n = m)->next_sibling;

	return m;
}

const Family* Family::next_descendant()const
{ return const_cast<Family*>(this)->next_descendant(); }

#////////////////////////////////////////////////

void Family::Push(Family* child) {
	for (Family* i(this); i; i = i->parent) {
		if (i == child) {
			// child is this or this's ancestor, Push failed
			return;
		}
	}

	child->Pop()->parent = this;

	if (this == this->prev_child) {
		child->prev_sibling = child->next_sibling = this;
		this->prev_child = this->next_child = child;
	} else {
		child->prev_sibling = this->prev_child;
		this->prev_child->next_sibling = child;

		child->next_sibling = this;
		this->prev_child = child;
	}
}

Family* Family::Pop() {
	if (this->parent) {
		if (this->parent == this->prev_sibling) {
			if (this->parent == this->next_sibling) {
				this->parent->prev_child = this->parent->next_child = this->parent;
			} else {
				this->parent->next_child = this->next_sibling;
				this->next_sibling->prev_sibling = this->parent;
			}
		} else if (this->parent == this->next_sibling) {
			this->prev_sibling->next_sibling = this->parent;
			this->parent->prev_child = this->prev_sibling;
		} else {
			this->prev_sibling->next_sibling = this->next_sibling;
			this->next_sibling->prev_sibling = this->prev_sibling;
		}

		this->parent = nullptr;
		this->prev_sibling = this->next_sibling = nullptr;
		this->prev_child = this->next_child = this;
	}

	return this;
}

}
}