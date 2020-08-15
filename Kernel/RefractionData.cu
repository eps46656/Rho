#include "define.cuh"
#include "Kernel.cuh"

namespace rho {

RefractionData::RefractionData(const RayCastData& rcd, const Tod& tod,
							   const ComponentCollider::Material* x,
							   const ComponentCollider::Material* y) {
	Num n(y->refraction_index / x->refraction_index);

	if (n.eq<1>()) {
		this->transmittance = 1;
		this->parallel_ratio = 1;
		return;
	}

	Num p_length_sq(sq(rcd->domain->dim_r(), tod.tan));
	Num n_length_sq(sq(rcd->domain->dim_r(), tod.orth));

#///////////////////////////////////////////////////////////////////////////////

	Num k(sq(n) * (p_length_sq + n_length_sq) - p_length_sq);

	if (k.lt<0>()) {
		this->transmittance = 0;
		return;
	}

	this->parallel_ratio = sqrt(n_length_sq / k);

#///////////////////////////////////////////////////////////////////////////////

	Num cos(sqrt(n_length_sq / (p_length_sq + n_length_sq)));
	Num sin(sqrt(p_length_sq / (p_length_sq + n_length_sq)));

	k = sqrt(sq(n) - sq(sin));

	this->transmittance = (sq(cos - k) / sq(cos + k) +
						   sq(sq(n) * cos - k) / sq(sq(n) * cos + k)) /
						  2;
}

}