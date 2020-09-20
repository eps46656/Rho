#include "define.cuh"
#include "Kernel.cuh"

namespace rho {

dim_t Component::root_dim() const { return this->root()->root_dim(); }

bool Component::latest() const { return this->latest_; }

#///////////////////////////////////////////////////////////////////////////////

Component::Component(Type type): type(type), latest_(false) {}

#///////////////////////////////////////////////////////////////////////////////

void Component::SetLatestFalse_() { this->latest_ = false; }

#///////////////////////////////////////////////////////////////////////////////

bool operator<(const Component& x, const Component& y) { return &x < &y; }

}