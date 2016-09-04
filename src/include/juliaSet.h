#ifndef JULIA_H
#define	JULIA_H

#define MAX_ITERACION 255
#define COND_CORTE_MOD_CUADRADO 4.0
#include <complex.h>

double squareAbsoluteValue(ComplexNumber z);
unsigned char calculateEscapeVelocity(ComplexNumber z, ComplexNumber c);

#endif	/* JULIA_H */

