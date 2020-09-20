#include "define.cuh"
#include "Kernel.cuh"

namespace rho {

bool ComponentCollider::Material::Check() const {
	return this->refraction_index.ge<1>() &&

		   this->transmittance[0].ge<0>() && this->transmittance[1].ge<0>() &&
		   this->transmittance[2].ge<0>() &&

		   this->transmittance[0].le<1>() && this->transmittance[1].le<1>() &&
		   this->transmittance[2].le<1>();
}

ComponentCollider::Material* ComponentCollider::Material::set_default() {
	this->refraction_index = 1;
	this->transmittance[0] = 0;
	this->transmittance[1] = 0;
	this->transmittance[2] = 0;
	return this;
}

ComponentCollider::Material*
ComponentCollider::Material::set(Num refraction_index, Num transmittance_0,
								 Num transmittance_1, Num transmittance_2) {
	this->refraction_index = refraction_index;
	this->transmittance[0] = transmittance_0;
	this->transmittance[1] = transmittance_1;
	this->transmittance[2] = transmittance_2;
	return this;
}

ComponentCollider::Material*
ComponentCollider::Material::set_refraction_index(Num refraction_index) {
	this->refraction_index = refraction_index;
	return this;
}

ComponentCollider::Material* ComponentCollider::Material::set_transmittance(
	Num transmittance_0, Num transmittance_1, Num transmittance_2) {
	this->transmittance[0] = transmittance_0;
	this->transmittance[1] = transmittance_1;
	this->transmittance[2] = transmittance_2;
	return this;
}

#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////
#///////////////////////////////////////////////////////////////////////////////

const Space* ComponentCollider::root() const {
	return this->domain_ ? this->domain_->root() : nullptr;
}

#///////////////////////////////////////////////////////////////////////////////

Domain* ComponentCollider::domain() { return this->domain_raw_; }
const Domain* ComponentCollider::domain() const { return this->domain_raw_; }
Texture* ComponentCollider::texture() const { return this->texture_; }

ComponentCollider::Material& ComponentCollider::material() {
	return this->material_;
}
const ComponentCollider::Material& ComponentCollider::material() const {
	return this->material_;
}

ComponentCollider* ComponentCollider::set_domain(Domain* domain) {
	this->domain_raw_ = domain;
	return this;
}

ComponentCollider* ComponentCollider::set_texture(Texture* texture) {
	this->texture_ = texture;
	return this;
}

#///////////////////////////////////////////////////////////////////////////////

ComponentCollider::ComponentCollider(Domain* domain, Texture* texture):
	Component(Type::collider), domain_raw_(domain), domain_(nullptr),
	texture_(texture) {}

#///////////////////////////////////////////////////////////////////////////////

bool ComponentCollider::Refresh() const {
	if (!this->domain_raw_ || !(this->domain_ = this->domain_raw_->Refresh())) {
		return false;
	}

	this->texture_->Refresh();

	return true;
}

#///////////////////////////////////////////////////////////////////////////////

bool ComponentCollider::Contain(const Num* point) const {
	return this->domain_ && this->domain_->Contain(point);
}

}