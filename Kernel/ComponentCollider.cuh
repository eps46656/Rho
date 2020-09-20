#ifndef RHO__define_guard__Kernel__ComponentCollider_cuh
#define RHO__define_guard__Kernel__ComponentCollider_cuh

#include "init.cuh"
#include "Component.cuh"

namespace rho {

class ComponentCollider: public Component {
public:
	struct Material {
		Num refraction_index;
		Num3 transmittance;

		RHO__cuda bool Check() const;

		RHO__cuda Material* set_default();
		RHO__cuda Material* set(Num refraction_index, Num transmittance_0,
								Num transmittance_1, Num transmittance_2);
		RHO__cuda Material* set_refraction_index(Num refraction_index);
		RHO__cuda Material* set_transmittance(Num transmittance_0,
											  Num transmittance_1,
											  Num transmittance_2);
	};

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda const Space* root() const override;

	RHO__cuda Domain* domain();
	RHO__cuda const Domain* domain() const;

	RHO__cuda Material& material();
	RHO__cuda const Material& material() const;
	RHO__cuda Texture* texture() const;

	RHO__cuda ComponentCollider* set_domain(Domain* domain);
	RHO__cuda ComponentCollider* set_texture(Texture* texture);

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda ComponentCollider(Domain* domain = nullptr,
								Texture* texture = nullptr);

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda bool Refresh() const override;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda virtual bool Contain(const Num* point) const;

private:
	Domain* domain_raw_;
	mutable const Domain* domain_;
	Material material_;
	Texture* texture_;
};

}

#endif