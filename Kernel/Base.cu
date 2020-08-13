#include "define.cuh"
#include "Kernel.cuh"

namespace rho {

RHO__cuda bool C_next(size_t x, size_t y, size_t* data) {
	if (data[0] == x - y) { return false; }

	size_t i(y);
	for (--i; data[i] == x - (y - i); --i)
		;
	++data[i];
	for (++i; i != y; ++i) { data[i] = data[i - 1] + 1; }

	return true;
}

bool Complement(dim_t col_dim, dim_t row_dim, Num* data) {
	if (row_dim < col_dim) { return false; }
	if (col_dim == row_dim) { return true; }

	dim_t co(row_dim - col_dim - 1);

	if (co) {
		Num m[(RHO__max_dim - 1) * (RHO__max_dim - 1)];
		Num* v(m + (RHO__max_dim - 2) * (RHO__max_dim - 1));
		size_t c[RHO__max_dim - 1];

		for (dim_t i(0); i != co; ++i) { c[i] = i; }

		for (dim_t k(0); k != co; ++k) {
			c[co - k] = RHO__max_dim;

			for (;;) {
				for (size_t i(0); i != col_dim; ++i) {
					Num* m_i(m + RHO__max_dim * i);
					size_t* c_i(c);

					for (size_t j(0); j != row_dim; ++j) {
						if (j == *c_i) {
							++c_i;
						} else {
							*m_i = data[RHO__max_dim * i + j];
							++m_i;
						}
					}
				}

				cross(v, m, col_dim + 1);

				if (!is_zero(row_dim, v)) { break; }

				if (c[0] == col_dim + 1) { return false; }

				size_t i(co - 1);
				while (c[i] == col_dim + 1 + i) { --i; }

				++c[i];
				for (++i; i != co; ++i) { c[i] = c[i - 1] + 1; }
			}

			Num* v_i(v);
			size_t* c_i(c);

			for (size_t i(0); i != row_dim; ++i) {
				if (i == *c_i) {
					data[RHO__max_dim * col_dim + i] = 0;
					++c_i;
				} else {
					data[RHO__max_dim * col_dim + i] = *v_i;
					++v_i;
				}
			}

			++col_dim;
		}
	}

	cross(data + RHO__max_dim * col_dim, data, row_dim);

	return !is_zero(row_dim, data + RHO__max_dim * col_dim);
}

bool Complement(Matrix& matrix) {
	if (Complement(matrix.col_dim(), matrix.row_dim(), matrix)) {
		matrix.set_col_dim(matrix.row_dim());
		return true;
	}

	return false;
}

}