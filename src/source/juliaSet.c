#include <juliaSet.h>


double squareAbsoluteValue(ComplexNumber z){

	double squareSum = (z.realPart * z.realPart) + (z.imaginaryPart * z.imaginaryPart);
	return squareSum;
}

unsigned char calculateEscapeVelocity(ComplexNumber z, ComplexNumber c){
	int i;
	for(i = 0; i < MAX_ITERACION; i++){
		if(squareAbsoluteValue(z) > COND_CORTE_MOD_CUADRADO)
			break;
		double oldRealPart = z.realPart;
		double oldImaginaryPart = z.imaginaryPart;
		z.realPart = (oldRealPart * oldRealPart) - (oldImaginaryPart * oldImaginaryPart) + c.realPart;
		z.imaginaryPart = (2 * oldRealPart * oldImaginaryPart) + c.imaginaryPart;
	}

	return i;
}

