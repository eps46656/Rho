#include "init.cuh"

namespace rho {

struct MassPoint {
	Num mass;
	Vector vel;
};

void Collide(Num& dst_x_vel, Num& dst_y_vel, Num x_mass, Num x_vel, Num y_mass,
			 Num y_vel, Num e);

// e : coefficient of restitution

void Collide(Vector& dst_x_vel, Vector& dst_y_vel, MassPoint& x, MassPoint& y,
			 const Vector& orth);

void Collide(Vector& dst_x, Vector& dst_y, MassPoint& x, MassPoint& y,
			 const Vector& orth);

}