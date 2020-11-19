#include "define.cuh"
#include "Kernel.cuh"

namespace rho {

RayCastData::Phase::Phase(int value): value(value & 0b11) {}

RayCastData::Phase::Phase(bool fr, bool to):
	value((fr ? 0b01 : 0b00) | (to ? 0b10 : 0b00)) {}

#///////////////////////////////////////////////////////////////////////////////

RayCastData::Phase& RayCastData::Phase::operator=(const Phase& phase) {
	this->value = phase.value;
}

#///////////////////////////////////////////////////////////////////////////////

bool RayCastData::Phase::fr() const { return this->value & 0b01; }
bool RayCastData::Phase::to() const { return this->value & 0b10; }

void RayCastData::Phase::fr(bool fr) {
	if (fr) {
		this->value |= 0b01;
	} else {
		this->value &= 0b10;
	}
}

void RayCastData::Phase::to(bool to) {
	if (to) {
		this->value |= 0b10;
	} else {
		this->value &= 0b01;
	}
}

void RayCastData::Phase::set(bool fr, bool to) {
	this->value = (fr ? 0b01 : 0b00) | (to ? 0b10 : 0b00);
}

void RayCastData::Phase::reverse() { this->value ^= 0b11; }

#///////////////////////////////////////////////////////////////////////////////

RayCastData* RayCastData::prev() const {
	return static_cast<RayCastData*>(this->BNode::prev());
}

RayCastData* RayCastData::next() const {
	return static_cast<RayCastData*>(this->BNode::next());
}

#///////////////////////////////////////////////////////////////////////////////

RayCastData::RayCastData(): domain(nullptr) {}

RayCastData::RayCastData(const RayCastData& rcd):
	domain(rcd.domain), t(rcd.t), phase(rcd.phase) {
#pragma unroll
	for (size_t i(0); i != RHO__max_dim; ++i) { this->spare[i] = rcd.spare[i]; }
}

RayCastData::operator bool() const { return this->domain != nullptr; }

RayCastData::~RayCastData() { this->Destroy(); }

#///////////////////////////////////////////////////////////////////////////////

RayCastData& RayCastData::operator=(RayCastData& rcd) {
	this->Destroy();
	if (!rcd.domain) { return *this; }
	this->domain = rcd.domain;
	this->t = rcd.t;
	this->phase = rcd.phase;
	Copy<RHO__max_dim>(this->spare, rcd.spare);
	rcd.domain = nullptr;
	return *this;
}

#///////////////////////////////////////////////////////////////////////////////

void RayCastData::Destroy() {
	if (this->domain == nullptr) { return; }
	this->domain->RayCastDataDeleter(*this);
	this->domain = nullptr;
}

#///////////////////////////////////////////////////////////////////////////////

bool operator==(const RayCastData& x, const RayCastData& y) {
	return x && y && (x.t == y.t);
}

bool operator==(const RayCastData& x, Num t) { return x && x.t == t; }

bool operator==(Num t, const RayCastData& x) { return x && t == x.t; }

bool operator<(const RayCastData& x, const RayCastData& y) {
	return x && (!y || x.t < y.t);
}

bool operator<(Num t, const RayCastData& x) { return !x || t < x.t; }

bool operator<(const RayCastData& x, Num t) { return x && x.t < t; }

bool operator<=(const RayCastData& x, const RayCastData& y) { return !(y < x); }

bool operator<=(Num t, const RayCastData& x) { return !(x < t); }

bool operator<=(const RayCastData& x, Num t) { return !(t < x); }

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
/*
size_t RayCastDataPool::size() const { return this->size_; }
bool RayCastDataPool::empty() const { return this->size_ == 0; }

#///////////////////////////////////////////////////////////////////////////////

RayCastDataPool::RayCastDataPool(): size_(0) {}

RayCastDataPool::~RayCastDataPool() {
	while (!this->node_.sole()) { Delete(this->node_.prev()); }
}

#///////////////////////////////////////////////////////////////////////////////

void RayCastDataPool::Push(RayCastData* rcd) {
	++this->size_;
	rcd->Destroy(*this);
	this->node_.PushPrev(rcd);
}

void RayCastDataPool::PushAll(BNode& rcdl) {
	while (!rcdl.sole()) {
		++this->size_;
		static_cast<RayCastData*>(rcdl.prev())->Destroy(*this);
		this->node_.PushPrev(rcdl.prev());
	}
}

RayCastData* RayCastDataPool::Pop() {
	if (this->empty()) { return New<RayCastData>(); }

	--this->size_;
	return static_cast<RayCastData*>(this->node_.prev()->Pop());
}*/

/*
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

RayCastDataList::RayCastDataList(RayCastDataPool& pool): pool_(&pool) {}

RHO__cuda ~RayCastDataList() { this->pool_->Push(*this); }*/
}