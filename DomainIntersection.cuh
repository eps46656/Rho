#ifndef RHO__define_guard__DomainIntersection_cuh
#define RHO__define_guard__DomainIntersection_cuh

#include "Kernel/Kernel.cuh"

namespace rho {

class DomainIntersection: public DomainComplex {
public:
	const cntr::Vector<Domain*>& domain() const;

	void add_domain(Domain* domain);

#///////////////////////////////////////////////////////////////////////////////

	DomainIntersection() = default;
	DomainIntersection(const cntr::Vector<Domain*>& domain);
	DomainIntersection(std::initializer_list<Domain*> domain);

#///////////////////////////////////////////////////////////////////////////////

	void Refresh() const override;
	bool ReadyForRendering() const override;

#///////////////////////////////////////////////////////////////////////////////

	bool Contain(const Vector& root_point) const override;
	bool EdgeContain(const Vector& root_point) const override;
	bool FullContain(const Vector& root_point) const override;
	ContainType GetContainType(const Vector& root_point) const override;

#///////////////////////////////////////////////////////////////////////////////

	RayCastData RayCast(const Ray& ray) const override;
	RayCastDataVector RayCastFull(const Ray& ray) const override;

#///////////////////////////////////////////////////////////////////////////////

	bool IsTanVector(const Vector& root_point,
					 const Vector& root_vector) const override;

private:
	mutable cntr::Vector<Domain*> domain_;
};

}

#endif