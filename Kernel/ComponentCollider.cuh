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
		RHO__cuda void SetDefault();
		RHO__cuda void Set(Num refration_index, Num transmittance_0,
						   Num transmittance_1, Num transmittance_2);
	};

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda const Domain* domain() const;
	RHO__cuda Material& material();
	RHO__cuda const Material& material() const;
	RHO__cuda const Texture* texture() const;

	RHO__cuda ComponentCollider* set_object(Object* object);
	RHO__cuda ComponentCollider* set_domain(const Domain* domain);
	RHO__cuda ComponentCollider* set_texture(const Texture* texture);

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda ComponentCollider(Object* object, const Domain* domain = nullptr,
								Texture* texture = nullptr);

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda bool Refresh() const override;

#///////////////////////////////////////////////////////////////////////////////

	RHO__cuda virtual bool Contain(const Num* point) const;

private:
	const Domain* domain_;
	Material material_;
	const Texture* texture_;
};

}

#endif