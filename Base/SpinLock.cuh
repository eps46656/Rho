#ifndef RHO__define_guard__Base__SpinLock_cuh
#define RHO__define_guard__Base__SpinLock_cuh

struct SpinLock {
public:
	void Lock() {
		while (atomicOr(this->value_, 1)) {}
	}

	void Unlock() { atomicAnd(this->value_, 0); }

private:
	int value_ = 0;
};

#endif