#include "define.cuh"
#include "Kernel.cuh"

namespace rho {

RayCastDataCore::Phase::Phase(int value): value(value & 0b11) {}

RayCastDataCore::Phase::Phase(bool fr, bool to):
	value((fr ? 0b01 : 0b00) | (to ? 0b10 : 0b00)) {}

bool RayCastDataCore::Phase::fr() const { return this->value & 0b01; }
bool RayCastDataCore::Phase::to() const { return this->value & 0b10; }

void RayCastDataCore::Phase::fr(bool fr) {
	if (fr) {
		this->value |= 0b01;
	} else {
		this->value &= 0b10;
	}
}

void RayCastDataCore::Phase::to(bool to) {
	if (to) {
		this->value |= 0b10;
	} else {
		this->value &= 0b01;
	}
}

void RayCastDataCore::Phase::set(bool fr, bool to) {
	this->value = (fr ? 0b01 : 0b00) | (to ? 0b10 : 0b00);
}

void RayCastDataCore::Phase::reverse() { this->value ^= 0b11; }

#///////////////////////////////////////////////////////////////////////////////

RayCastDataCore::~RayCastDataCore() {}

#///////////////////////////////////////////////////////////////////////////////

bool operator==(const RayCastData& x, const RayCastData& y) {
	return x && y && (x->t == y->t);
}

bool operator==(const RayCastData& x, Num t) { return x && x->t == t; }

bool operator==(Num t, const RayCastData& x) { return x && t == x->t; }

bool operator<(const RayCastData& x, const RayCastData& y) {
	return x && (!y || x->t < y->t);
}

bool operator<(Num t, const RayCastData& x) { return !x || t < x->t; }

bool operator<(const RayCastData& x, Num t) { return x && x->t < t; }

bool operator<=(const RayCastData& x, const RayCastData& y) { return !(y < x); }

bool operator<=(Num t, const RayCastData& x) { return !(x < t); }

bool operator<=(const RayCastData& x, Num t) { return !(t < x); }

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

bool Contain(size_t size, RayCastData* rcd, Num t) {
	for (size_t i(0); i != size; ++i) {
		if ((*rcd)->t < t) { continue; }
		return !(t < (*rcd)->t) || (*rcd)->phase.fr();
	}

	return rcd[size - 1]->phase.to();
}

}
