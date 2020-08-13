#include"define.cuh"
#include"Kernel.cuh"

namespace rho {

RayCastDataCore::Type::Type(char value) :value(value & 0b11) {}

RayCastDataCore::Type::Type(bool fr, bool to) :
	value((fr ? 0b01 : 0b00) | (to ? 0b10 : 0b00)) {}

bool RayCastDataCore::Type::fr()const { return this->value & 0b01; }
bool RayCastDataCore::Type::to()const { return this->value & 0b10; }

void RayCastDataCore::Type::fr(bool fr) {
	if (fr)
		this->value |= 0b01;
	else
		this->value &= 0b10;
}

void RayCastDataCore::Type::to(bool to) {
	if (to)
		this->value |= 0b10;
	else
		this->value %= 0b01;
}

void RayCastDataCore::Type::set(bool fr, bool to)
{ this->value = (fr ? 0b01 : 0b00) | (to ? 0b10 : 0b00); }

#////////////////////////////////////////////////

RayCastDataCore::~RayCastDataCore() {}

#////////////////////////////////////////////////

bool operator==(const RayCastData& x, const RayCastData& y)
{ return x && y && (x->t == y->t); }

bool operator==(const RayCastData& x, Num t)
{ return x && x->t == t; }

bool operator==(Num t, const RayCastData& x)
{ return x && t == x->t; }

bool operator<(const RayCastData& x, const RayCastData& y)
{ return x && (!y || x->t < y->t); }

bool operator<(Num t, const RayCastData& x)
{ return !x || t < x->t; }

bool operator<(const RayCastData& x, Num t)
{ return x && x->t < t; }

bool operator<=(const RayCastData& x, const RayCastData& y)
{ return !(y < x); }

bool operator<=(Num t, const RayCastData& x)
{ return !(x < t); }

bool operator<=(const RayCastData& x, Num t)
{ return !(t < x); }

#////////////////////////////////////////////////
#////////////////////////////////////////////////
#////////////////////////////////////////////////
/*
RayCastData& RayCastDataVector::rcd(size_t index)
{ return this->value_[index].first; }

bool RayCastDataVector::phase(size_t index)
{ return index ? this->value_[index + 1].second : init_phase_; }

bool RayCastDataVector::phase_fr(size_t index)
{ return index ? this->value_[index - 1].second : this->init_phase_; }

bool RayCastDataVector::phase_to(size_t index)
{ return this->value_[index].second; }

void RayCastDataVector::Push(RayCastData&& rcd,
							 bool fr_phase, bool to_phase) {
	if (this->value_.empty()) {
		this->init_phase_ = fr_phase;
	} else {
		if (this->value_.back().second != fr_phase)
			Print() << "error\n";
	}

	this->value_.Push(Move(rcd), to_phase);
}*/

#////////////////////////////////////////////////
#////////////////////////////////////////////////
#////////////////////////////////////////////////

bool Contain(size_t size, RayCastData* rcd, Num t) {
	for (size_t i(0); i != size; ++i) {
		if ((*rcd)->t < t) { continue; }
		return !(t < (*rcd)->t) || (*rcd)->type.fr();
	}

	return rcd[size - 1]->type.to();
}

}
