#ifndef RHO__define_guard__Container__RedBlackTree_cuh
#define RHO__define_guard__Container__RedBlackTree_cuh

#include "../define.cuh"
#include "../Base/memory.cuh"
#include "../Base/pair.cuh"
#include "../Base/operator.cuh"
#include "RedBlackTreeNode.cuh"

#define RHO__throw__local(desc)                                                \
	RHO__throw(cntr::RedBlackTree<T, Compare>, __func__, desc);

namespace rho {
namespace cntr {

template<typename T, typename Compare = op::lt<T>> class RedBlackTree {
public:
	struct Node: private RedBlackTreeNode {
		friend class RedBlackTree<T, Compare>;

		T value;

		template<typename... Args>
		RHO__cuda Node(Args&&... args): value(Forward<Args>(args)...) {}
	};

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

	template<template<typename> typename Mode> struct Iterator_ {
	public:
		friend class RedBlackTree<T, Compare>;

		using T_t = typename Mode<T>::type;
		using RedBlackTree_t = typename Mode<RedBlackTree<T, Compare>>::type;
		using Node_t = typename Mode<Node>::type;

#///////////////////////////////////////////////////////////////////////////////

		RHO__cuda Iterator_(const Iterator_& iter):
			tree_(iter.tree_), node_(iter.node_) {}

		RHO__cuda operator bool() const { return this->node_; }

#///////////////////////////////////////////////////////////////////////////////

		Iterator_& operator=(const Iterator_& iter) & {
			this->tree_ = iter.tree_;
			this->node_ = iter.node_;
		}

#///////////////////////////////////////////////////////////////////////////////

		RHO__cuda bool operator==(const Iterator_& iter) const {
			return this->node_ == iter.node_;
		}
		RHO__cuda bool operator!=(const Iterator_& iter) const {
			return this->node_ != iter.node_;
		}

		RHO__cuda T_t& operator*() const { return this->node_->value; }
		RHO__cuda T_t* operator->() const { return &this->node_->value; }

		RHO__cuda Iterator_& operator++() {
			this->node_ = static_cast<Node_t*>(this->node_->next());
			return *this;
		}
		RHO__cuda Iterator_& operator--() {
			this->node_ = static_cast<Node_t*>(this->node_->prev());
			return *this;
		}

	private:
		RedBlackTree_t* tree_;
		Node_t* node_;

		RHO__cuda Iterator_(RedBlackTree_t* tree, Node_t* node):
			tree_(tree), node_(node) {}
	};

	using Iterator = Iterator_<Identity>;
	using ConstIterator = Iterator_<AddConst>;

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

	static constexpr bool black = false;
	static constexpr bool red = true;

	RHO__cuda size_t size() const { return this->size_; }
	RHO__cuda bool empty() const { return this->size_ == 0; }

	RHO__cuda const Compare& compare() const { return this->compare_; }

	RHO__cuda Iterator begin() {
		if (!this->root_) { return { this, nullptr }; }
		RedBlackTreeNode* n(this->root_);
		while (n->l) { n = n->l; }
		return { this, static_cast<Node*>(n) };
	}
	RHO__cuda Iterator end() { return { this, nullptr }; }

	RHO__cuda ConstIterator begin() const {
		if (!this->root_) { return { this, nullptr }; }
		RedBlackTreeNode* n(this->root_);
		while (n->l) { n = n->l; }
		return { this, static_cast<Node*>(n) };
	}
	RHO__cuda ConstIterator end() const { return { this, nullptr }; }

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda RedBlackTree(Compare compare = Compare()):
		size_(0), compare_(compare), root_(nullptr), temp_(nullptr) {}

	RHO__cuda ~RedBlackTree() {
		this->Clear();
		Free(this->temp_);
	}

#///////////////////////////////////////////////////////////////////////////////

	template<typename Index> RHO__cuda Iterator Find(const Index& index) {
		return { this, this->Find_(index) };
	}

	template<typename Index>
	RHO__cuda ConstIterator Find(const Index& index) const {
		return { this, this->Find_(index) };
	}

	RHO__cuda pair<Node*, bool> InsertNode(Node* node) {
		if (this->size_ == 0) {
			this->root_ = node;
		} else {
			for (Node* n(this->root_);;) {
				if (this->compare_(node->value, n->value)) {
					if (!n->l) {
						n->InsertL(node);
						break;
					}

					n = static_cast<Node*>(n->l);
				} else if (this->compare_(n->value, node->value)) {
					if (!n->r) {
						n->InsertR(node);
						break;
					}

					n = static_cast<Node*>(n->r);
				} else {
					return pair<Node*, bool>(node, false);
				}
			}

			while (this->root_->p) {
				this->root_ = static_cast<Node*>(this->root_->p);
			}
		}

		++this->size_;

		return pair<Node*, bool>(node, true);
	}

	template<typename... Args> RHO__cuda bool Insert(Args&&... args) {
		/*Node* node(New<Node>(Forward<Args>(args)...));

		if (this->InsertNode(node).second) { return true; }

		delete node;
		return false;*/

		if (!this->temp_) { this->temp_ = Malloc<Node>(1); }

		if (this->InsertNode(new (this->temp_) Node(Forward<Args>(args)...))
				.second) {
			this->temp_ = nullptr;
			return true;
		}

		this->temp_->value.~T();
		return false;
	}

	RHO__cuda Iterator Release(const Iterator& iter) {
		if (this == iter.tree_) { this->Release_(iter.node_); }
		return iter;
	}

	RHO__cuda void Erase(const Iterator& iter) {
		/*if (this != iter.tree_) { return; }
		this->Release_(iter.node_);
		Delete(iter.node_);
		const_cast<Iterator&>(iter).tree_ = nullptr;*/
		if (this != iter.tree_) { return; }
		const_cast<Iterator&>(iter).tree_ = nullptr;
		this->Release_(iter.node_);

		if (this->temp_) {
			iter.node_->value.~T();
			Free(iter.node_);
		} else {
			(this->temp_ = iter.node_)->value.~T();
		}
	}

	template<typename Index> RHO__cuda void FindErase(const Index& index) {
		/*Node* node(this->Find_(index));
		this->Release_(node);
		Delete(node);*/

		Node* node(this->Find_(index));
		this->Release_(node);

		if (this->temp_) {
			node->value.~T();
			Free(node);
		} else {
			(this->temp_ = node)->value.~T();
		}
	}

	RHO__cuda void Clear() {
		/*if (!this->size_) { return; }

		Node** i(Malloc<Node*>(this->size_));
		i[0] = this->root_;

		Node** end(i + this->size_);

		for (Node** j(i + 1); i != end; ++i) {
			if ((*i)->l) {
				*j = static_cast<Node*>((*i)->l);
				++j;
			}

			if ((*i)->r) {
				*j = static_cast<Node*>((*i)->r);
				++j;
			}

			(*i)->value.~T();
			Free(*i);
		}

		Free(i - this->size_);

		this->size_ = 0;
		this->root_ = nullptr;*/

		if (!this->root_) { return; }

		RedBlackTreeNode* n(this->root_);
		while (n->l) { n = n->l; }
		for (RedBlackTreeNode* m; m = n->next(); n = m) {
			static_cast<Node*>(n)->value.~T();
			Free(n);
		}

		this->size_ = 0;
		this->root_ = nullptr;

		if (this->temp_) {
			static_cast<Node*>(n)->value.~T();
			Free(n);
		} else {
			(this->temp_ = static_cast<Node*>(n))->value.~T();
		}
	}

private:
	size_t size_;
	Compare compare_;
	Node* root_;
	Node* temp_;

	template<typename Index> RHO__cuda Node* Find_(const Index& index) const {
		for (Node* node(this->root_); node;) {
			if (this->compare_(index, node->value)) {
				node = static_cast<Node*>(node->l);
			} else if (this->compare_(node->value, index)) {
				node = static_cast<Node*>(node->r);
			} else {
				return node;
			}
		}

		return nullptr;
	}

	RHO__cuda void Release_(Node* node) {
		if (--this->size_) {
			if (this->root_ == node) {
				if (!(this->root_ = static_cast<Node*>(node->l))) {
					this->root_ = static_cast<Node*>(node->r);
				}
			}

			node->Release();

			while (this->root_->p) {
				this->root_ = static_cast<Node*>(this->root_->p);
			}
		} else {
			this->root_ = nullptr;
			node->p = nullptr;
		}
	}
};

}
}

#undef RHO__throw__local

#endif