#include"define.cuh"
#include"Kernel.cuh"

namespace rho {

const Domain* ComponentCollider::domain()const
{ return this->domain_; }

Texture* ComponentCollider::texture()const
{ return this->texture_; }

ComponentCollider* ComponentCollider::
set_domain(const Domain* domain) {
	this->domain_ = domain;
	return this;
}

ComponentCollider* ComponentCollider::
set_texture(Texture* texture) {
	this->texture_ = texture;
	return this;
}

#////////////////////////////////////////////////

ComponentCollider::ComponentCollider(
	Object* object, const Domain* domain, Texture* texture) :

	Component(Type::collider, object),
	domain_(domain),
	texture_(texture ? texture :
			 this->manager()->default_texture()) {}

#////////////////////////////////////////////////

bool ComponentCollider::Refresh()const {
	return this->root_ == this->domain_->root() &&
		this->domain_->Refresh() && this->texture_->Refresh();
}

#////////////////////////////////////////////////

bool ComponentCollider::Contain(const Vector& point)const
{ return this->domain_->Contain(point); }

#////////////////////////////////////////////////

RayCastData ComponentCollider::
RayCast(const Ray& ray)const {
	RayCastData r(this->domain_->RayCast(ray));

	if (r) {
		r->cmpt_collider =
			const_cast<ComponentCollider*>(this);
	}

	return r;
}

bool ComponentCollider::
RayCastFull(RayCastDataVector& rcdv, const Ray& ray)const {
	bool phase(this->domain_->RayCastFull(rcdv, ray));

	for (size_t i(0); i != rcdv.size(); ++i) {
		rcdv[i]->cmpt_collider =
			const_cast<ComponentCollider*>(this);
	}

	return phase;
}

void ComponentCollider::RayCastForRender(
	RayCastDataPair& rcdp, const Ray& ray)const {

	this->domain_->RayCastForRender(
		rcdp,
		const_cast<ComponentCollider*>(this),
		ray);
}

}