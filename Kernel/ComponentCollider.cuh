#ifndef RHO__define_guard__Kernel__ComponentCollider_cuh
#define RHO__define_guard__Kernel__ComponentCollider_cuh

#include "init.cuh"
#include "Component.cuh"

namespace rho {

class ComponentCollider: public Component {
public:
	RHO__cuda const Domain* domain() const;
	RHO__cuda Texture* texture() const;

	RHO__cuda ComponentCollider* set_domain(const Domain* domain);
	RHO__cuda ComponentCollider* set_texture(Texture* texture);

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda ComponentCollider(Object* object, const Domain* domain = nullptr,
								Texture* texture = nullptr);

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda bool Refresh() const override;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda virtual bool Contain(const Vector& point) const;

	RHO__cuda virtual RayCastData RayCast(const Ray& ray) const;
	RHO__cuda virtual bool RayCastFull(RayCastDataVector& rcdv,
									   const Ray& ray) const;
	RHO__cuda virtual void RayCastForRender(RayCastDataPair& rcdp,
											const Ray& ray) const;

private:
	const Domain* domain_;
	Texture* texture_;
};

}

#endif