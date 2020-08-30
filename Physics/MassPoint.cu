#include "MassPoint.cuh"

namespace rho {

void Collide(Num& dst_x_vel, Num& dst_y_vel, Num x_mass, Num x_vel, Num y_mass,
			 Num y_vel, Num e) {
	dst_x_vel =
		((x_vel) * (x_mass - y_mass * e) + (y_vel) * (x_mass * (1 + e))) /
		(x_mass + y_mass);

	dst_y_vel =
		((x_vel) * (y_mass * (1 + e)) + (y_vel) * (y_mass - x_mass * e)) /
		(x_mass + y_mass);
}

void Collide(Vector& dst_x_vel, Vector& dst_y_vel, Num x_mass,
			 const Vector& x_vel, Num y_mass, const Vector& y_vel,
			 const Vector& orth, Num e) {
	RHO__debug_if(x_vel.size() != orth.size() || y_vel.size() != orth.size()) {
		RHO__throw(, __func__, "dim error");
	}

	size_t dim(orth.size());

	Num x_vel_sq(0);
	Num x_vel_dot_orth(0);

	Num y_vel_sq(0);
	Num y_vel_dot_orth(0);

	Num orth_sq(0);

	for (size_t i(0); i != dim; ++i) {
		x_vel_sq += sq(x_vel[i]);
		x_vel_dot_orth += x_vel[i] * orth[i];

		y_vel_sq += sq(y_vel[i]);
		y_vel_dot_orth += y_vel[i] * orth[i];

		orth_sq = sq(orth[i]);
	}

	Num orth_l(sqrt(orth_sq));

	Num x_orth_vel_l_;
	Num y_orth_vel_l_;

	Collide(x_orth_vel_l_, y_orth_vel_l_, x_mass, x_vel_dot_orth / orth_l,
			y_mass, y_vel_dot_orth / orth_l, e);

	Vec x_orth_vel_;
	Vec y_orth_vel_;

#pragma unroll
	for (size_t i(0); i != RHO__max_dim; ++i) {
		dst_x_vel[i] = x_vel[i] - orth[i] * (x_vel_dot_orth / orth_sq +
											 x_orth_vel_l_ / orth_l);
		dst_y_vel[i] = y_vel[i] - orth[i] * (y_vel_dot_orth / orth_sq +
											 y_orth_vel_l_ / orth_l);
	}
}

/*
void Collide(
	Vector& dst_x, Vector& dst_y,
	MassPoint& x, MassPoint& y) {

	dst_x=
}*/

void Collide(Vector& dst_x, Vector& dst_y, MassPoint& x, MassPoint& y,
			 const Vector& orth, Num e) {}

}