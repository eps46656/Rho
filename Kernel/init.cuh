#ifndef RHO__define_guard__Kernel__init_cuh
#define RHO__define_guard__Kernel__init_cuh

#include "../define.cuh"
#include "../Base/search.cuh"
#include "../Base/sort.cuh"
#include "../Calculus/Calculus.cuh"
#include "../Container/Array.cuh"
#include "../Container/EnumerateVector.cuh"
#include "../Container/BidirectionalNode.cuh"
#include "../Container/List.cuh"
#include "../Container/Map.cuh"
#include "../Container/RedBlackTree.cuh"
#include "../Pointer/Any.cuh"
#include "../Pointer/Unique.cuh"

#///////////////////////////////////////////////////////////////////////////////

namespace rho {

using double_t = double;
using code_t = unsigned int;
using enum_t = unsigned int;
using priority_t = size_t;

template<typename T, size_t N> using Array_t = cntr::Array<T, N>;

using Num3 = cntr::Array<Num, 3>;

template<typename T, typename Compare = op::lt<T>>
using RBT = cntr::RedBlackTree<T, Compare>;

template<typename Index, typename Value,
		 typename Compare = cntr::MapCompare<Index, Value>>
using Map_t = cntr::Map<Index, Value, Compare>;

#define RHO__Domain__RayCastFull_max_rcd 8

#if (RHO__Domain__RayCastFull_max_rcd < 8)
	#error RHO__Domain__RayCastFull_max_rcd must bigger than 8
#endif

#define RHO__Domain__RayCastFull_in_phase                                      \
	(RHO__Domain__RayCastFull_max_rcd + 100)

#///////////////////////////////////////////////////////////////////////////////

class Spinlock;

#///////////////////////////////////////////////////////////////////////////////

class Manager;
class Space;
class Object;

#///////////////////////////////////////////////////////////////////////////////

class Domain;
class DomainSole;
class DomainComplex;

#///////////////////////////////////////////////////////////////////////////////

class Component;
class ComponentCollider;
class ComponentLight;
class ComponentLightAmbience;
class ComponentLightPoint;

#///////////////////////////////////////////////////////////////////////////////

struct ComponentContainerCmp;

using ComponentContainer = RBT<Component*, ComponentContainerCmp>;
using ConstComponentContainer = RBT<const Component*, ComponentContainerCmp>;

#///////////////////////////////////////////////////////////////////////////////

class Texture;
class TextureSolid;

#///////////////////////////////////////////////////////////////////////////////

struct Ray;
class Camera;

struct Tod;

struct RayCastDataCore;
using RayCastData = ptr::Unique<RayCastDataCore>;
using RayCastDataPair = cntr::Array<RayCastData, 2>;
using RayCastDataVector =
	cntr::Array<RayCastData, RHO__Domain__RayCastFull_max_rcd>;

struct RefractionData;

}

#endif
