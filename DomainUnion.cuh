#ifndef RHO__define_guard__DomainUnion_cuh
#define RHO__define_guard__DomainUnion_cuh

#include"Kernel/Kernel.cuh"

namespace rho {

class DomainUnion :public DomainComplex {

public:

	struct RayCastTemp {
		cntr::Vector<cntr::Vector<RayCastData>> rcdvv;
		cntr::Vector<RayCastData*> rcdv_a;
		cntr::Vector<RayCastData*> rcdv_b;
	};

#////////////////////////////////////////////////

	cntr::Vector<Domain*>& domain();
	const cntr::Vector<Domain*>& domain()const;

#////////////////////////////////////////////////

	DomainUnion* add_domain(Domain* domain);
	DomainUnion* sub_domain(Domain* domain);

#////////////////////////////////////////////////

	DomainUnion() = default;
	DomainUnion(const cntr::Vector<Domain*>& domain);
	DomainUnion(std::initializer_list<Domain*> domain);

#////////////////////////////////////////////////

	void Refresh()const override;
	bool ReadyForRendering()const override;

#////////////////////////////////////////////////

	bool Contain(const Vector& root_point)const override;

#////////////////////////////////////////////////

	RayCastData RayCast(const Ray& ray)const override;
	cntr::Vector<RayCastData> RayCastFull(const Ray& ray)const override;

private:
	cntr::Vector<Domain*> domain_;

	RHO__cuda RayCastTemp* RayCast_(const Ray& ray)const;
};

}

#endif