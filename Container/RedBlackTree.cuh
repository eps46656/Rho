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

		template<typename... Args> RHO__cuda Node(Args&&... args);
	};

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

	template<typename T_t, typename RedBlackTree_t, typename Node_t>
	struct Iterator_ {
	public:
		friend class RedBlackTree<T, Compare>;

		RHO__cuda Iterator_(const Iterator_& iter);

		RHO__cuda operator bool() const;

#///////////////////////////////////////////////////////////////////////////////

		Iterator_& operator=(const Iterator_& iter) &;

#///////////////////////////////////////////////////////////////////////////////

		RHO__cuda bool operator==(const Iterator_& iter) const;
		RHO__cuda bool operator!=(const Iterator_& iter) const;

		RHO__cuda T_t& operator*() const;
		RHO__cuda T_t* operator->() const;

		RHO__cuda Iterator_& operator++();
		RHO__cuda Iterator_& operator--();

	private:
		RedBlackTree_t* tree_;
		Node_t* node_;

		RHO__cuda Iterator_(RedBlackTree_t* tree, Node_t* node);
	};

	using Iterator = Iterator_<T, RedBlackTree, Node>;
	using ConstIterator = Iterator_<const T, const RedBlackTree, const Node>;

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

	static constexpr bool black = false;
	static constexpr bool red = true;

	RHO__cuda size_t size() const;
	RHO__cuda bool empty() const;

	RHO__cuda const Compare& compare() const;

	RHO__cuda Iterator begin();
	RHO__cuda Iterator end();

	RHO__cuda ConstIterator begin() const;
	RHO__cuda ConstIterator end() const;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda RedBlackTree(Compare compare = Compare());

	RHO__cuda ~RedBlackTree();

#///////////////////////////////////////////////////////////////////////////////

	template<typename Index> RHO__cuda Iterator Find(const Index& index);

	template<typename Index>
	RHO__cuda ConstIterator Find(const Index& index) const;

	template<typename... Args>
	RHO__cuda pair<Node*, bool> Insert(Args&&... args);

	RHO__cuda Iterator Remove(const Iterator& iter);

	RHO__cuda void Erase(const Iterator& iter);

	template<typename Index> RHO__cuda void FindErase(const Index& index);

	RHO__cuda void Clear();

private:
	size_t size_;
	Compare compare_;
	Node* root_;

	template<typename Index> RHO__cuda Node* Find_(const Index& index) const;

	RHO__cuda void Release_(Node* node);
};

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

#define RHO__rbt RedBlackTree<T, Compare>

template<typename T, typename Compare> size_t RHO__rbt::size() const {
	return this->size_;
}

template<typename T, typename Compare> bool RHO__rbt::empty() const {
	return !this->size_;
}

template<typename T, typename Compare>
const Compare& RHO__rbt::compare() const {
	return this->compare_;
}

template<typename T, typename Compare>
typename RedBlackTree<T, Compare>::Iterator RHO__rbt::begin() {
	if (!this->root_) { return { this, nullptr }; }
	RedBlackTreeNode* n(this->root_);
	while (n->l) { n = n->l; }
	return { this, static_cast<Node*>(n) };
}

template<typename T, typename Compare>
typename RHO__rbt::Iterator RHO__rbt::end() {
	return { this, nullptr };
}

template<typename T, typename Compare>
typename RHO__rbt::ConstIterator RHO__rbt::begin() const {
	if (!this->root_) { return { this, nullptr }; }
	RedBlackTreeNode* n(this->root_);
	while (n->l) { n = n->l; }
	return { this, static_cast<Node*>(n) };
}

template<typename T, typename Compare>
typename RHO__rbt::ConstIterator RHO__rbt::end() const {
	return { this, nullptr };
}

#///////////////////////////////////////////////////////////////////////////////

template<typename T, typename Compare>
RHO__rbt::RedBlackTree(Compare compare):
	size_(0), compare_(compare), root_(nullptr) {}

template<typename T, typename Compare> RHO__rbt::~RedBlackTree() {
	this->Clear();
}

#///////////////////////////////////////////////////////////////////////////////

template<typename T, typename Compare>
template<typename Index>
typename RHO__rbt::Iterator RHO__rbt::Find(const Index& index) {
	return { this, this->Find_(index) };
}

template<typename T, typename Compare>
template<typename Index>
typename RHO__rbt::ConstIterator RHO__rbt::Find(const Index& index) const {
	return { this, this->Find_(index) };
}

template<typename T, typename Compare>
template<typename Index>
typename RHO__rbt::Node* RHO__rbt::Find_(const Index& index) const {
	for (Node* node(this->root_); node;) {
		if (this->compare_(index, node->value))
			node = static_cast<Node*>(node->l);
		else if (this->compare_(node->value, index))
			node = static_cast<Node*>(node->r);
		else
			return node;
	}

	return nullptr;
}

template<typename T, typename Compare>
template<typename... Args>
rho::pair<typename RHO__rbt::Node*, bool> RHO__rbt::Insert(Args&&... args) {
	Node* node(New<Node>(Forward<Args>(args)...));

	if (this->size_) {
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

		while (this->root_->p) this->root_ = static_cast<Node*>(this->root_->p);
	} else {
		this->root_ = node;
	}

	++this->size_;

	return pair<Node*, bool>(node, true);
}

template<typename T, typename Compare>
typename RHO__rbt::Iterator RHO__rbt::Remove(const Iterator& iter) {
	if (this == iter.tree_) { this->Release_(iter.node_); }
	return iter;
}

template<typename T, typename Compare> void RHO__rbt::Release_(Node* node) {
	--this->size_;

	if (this->size_) {
		if (this->root_ == node) {
			if (!(this->root_ = static_cast<Node*>(node->l)))
				this->root_ = static_cast<Node*>(node->r);
		}

		node->Remove();

		while (this->root_->p) this->root_ = static_cast<Node*>(this->root_->p);
	} else {
		this->root_ = nullptr;
		node->p = nullptr;
	}
}

template<typename T, typename Compare>
void RHO__rbt::Erase(const Iterator& iter) {
	if (this != iter.tree_) { return; }
	this->Release_(iter.node_);
	Delete(iter.node_);
	const_cast<Iterator&>(iter).tree_ = nullptr;
}

template<typename T, typename Compare>
template<typename Index>
void RHO__rbt::FindErase(const Index& index) {
	Node* node(this->Find_(index));
	this->Release_(node);
	Delete(node);
}

template<typename T, typename Compare> void RHO__rbt::Clear() {
	if (!this->size_) { return; }

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
	this->root_ = nullptr;
}

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

template<typename T, typename Compare>
template<typename... Args>
RHO__rbt::Node::Node(Args&&... args): value(Forward<Args>(args)...) {}

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

#define RHO__iter Iterator_<T_t, RedBlackTree_t, Node_t>
#define RHO__rbt_iter RHO__rbt::RHO__iter

template<typename T, typename Compare>
template<typename T_t, typename RedBlackTree_t, typename Node_t>
RHO__rbt_iter::Iterator_(RedBlackTree_t* tree, Node_t* node):
	tree_(tree), node_(node) {}

template<typename T, typename Compare>
template<typename T_t, typename RedBlackTree_t, typename Node_t>
RHO__rbt_iter::Iterator_(const Iterator_& iter):
	tree_(iter.tree_), node_(iter.node_) {}

template<typename T, typename Compare>
template<typename T_t, typename RedBlackTree_t, typename Node_t>
RHO__rbt_iter::operator bool() const {
	return this->node_;
}

#///////////////////////////////////////////////////////////////////////////////

template<typename T, typename Compare>
template<typename T_t, typename RedBlackTree_t, typename Node_t>
RHO__rbt_iter& RHO__rbt_iter::operator=(const Iterator_& iter) & {
	this->tree_ = iter.tree_;
	this->node_ = iter.node_;
}

#///////////////////////////////////////////////////////////////////////////////

template<typename T, typename Compare>
template<typename T_t, typename RedBlackTree_t, typename Node_t>
bool RHO__rbt_iter::operator==(const RHO__iter& iter) const {
	return this->node_ == iter.node_;
}

template<typename T, typename Compare>
template<typename T_t, typename RedBlackTree_t, typename Node_t>
bool RHO__rbt_iter::operator!=(const RHO__iter& iter) const {
	return this->node_ != iter.node_;
}

#///////////////////////////////////////////////////////////////////////////////

template<typename T, typename Compare>
template<typename T_t, typename RedBlackTree_t, typename Node_t>
T_t& RHO__rbt_iter::operator*() const {
	return this->node_->value;
}

template<typename T, typename Compare>
template<typename T_t, typename RedBlackTree_t, typename Node_t>
T_t* RHO__rbt_iter::operator->() const {
	return &this->node_->value;
}

template<typename T, typename Compare>
template<typename T_t, typename RedBlackTree_t, typename Node_t>
typename RHO__rbt_iter& RHO__rbt_iter::operator++() {
	this->node_ = static_cast<Node_t*>(this->node_->next());
	return *this;
}

template<typename T, typename Compare>
template<typename T_t, typename RedBlackTree_t, typename Node_t>
typename RHO__rbt_iter& RHO__rbt_iter::operator--() {
	this->node_ = static_cast<Node_t*>(this->node_->prev());
	return *this;
}

}
}

#undef RHO__throw__local
#undef RHO__rbt
#undef RHO__iter
#undef RHO__rbt_iter

#endif