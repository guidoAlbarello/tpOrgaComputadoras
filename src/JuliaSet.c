#include <stdio.h>
#include <math.h>

#define C_REAL_PART -0.4
#define C_IMAGINARY_PART 0.6
#define WIDTH 7680
#define HEIGHT 4320
#define OFFSET_REAL_PART 2.5
#define OFFSET_IMAGINARY_PART 2.5
#define SPACE_HEIGHT 10
#define SPACE_WIDTH 10
#define BRIGHT_BOOST 3

typedef struct ComplexNumber{
	double realPart;
	double imaginaryPart;
} ComplexNumber;

typedef struct SetSpace{
	ComplexNumber offset;													// primero los declare como punteros asi no los pasamos por valor, pero la verdad son dos putos doubles,paja, sacando q prefieras q sea asi jojo
	ComplexNumber constantC;
	double width;
	double height;
} SetSpace;

typedef struct Pixel{
	unsigned char bright;
	ComplexNumber position;
} Pixel;

typedef struct GraphicSettings{
	Pixel *pixelGrid;
	FILE *fileOuptut;
} GraphicSettings;

SetSpace *initializeSpace();
GraphicSettings *initializeGraphicSettings();
void findJuliaSet (SetSpace *aSpace, Pixel *pixels);
void printOutput(FILE *anOutput);
FILE *getFileOutput(GraphicSettings *aGraphicSettings);
int getResolution(char *aType, char *anImageResolution);
ComplexNumber getComplexNumber(char *aComplexNumberStringFormat);

int main(int argc, char *argv[]){												//por ahora argv tiene el orden = 1. archivo 2. resolucion 
																				//3. offset 4. C 5. width 6. height  				
	SetSpace *aSpace = initializeSpace();
	GraphicSettings *theGraphicSettings = initializeGraphicSettings();
	

	findJuliaSet(aSpace, (*theGraphicSettings).pixelGrid);
	printOutput(theGraphicSettings);


	free(aSpace);
	aSpace = NULL;
	free(theGraphicSettings);
	theGraphicSettings = NULL;

	return 0;
}


SetSpace *initializeSpace(){

	SetSpace *aNewSpace = malloc(sizeof(SetSpace));

	(*aNewSpace).offset.realPart = OFFSET_REAL_PART;
	(*aNewSpace).offset.imaginaryPart = OFFSET_IMAGINARY_PART;
						
	(*aNewSpace).constantC.realPart = C_REAL_PART;
	(*aNewSpace).constantC.imaginaryPart = C_IMAGINARY_PART;

	(*aNewSpace).width = SPACE_WIDTH;									// hay una mejor que atoi que chequea errores
	(*aNewSpace).height = SPACE_HEIGHT;

	return aNewSpace;
}


GraphicSettings *initializeGraphicSettings(){

	GraphicSettings * aNewGraphicSettings = malloc(sizeof(GraphicSettings));

	int widthResolution = WIDTH; 	//getResolution("width", argv[1]);
	int heightResolution = HEIGHT; 	//getResolution("height", argv[1]);

	(*aNewGraphicSettings).pixelGrid = malloc(sizeof(Pixel) * widthResolution * heightResolution);
	for(int i = 0; i < heightResolution; i++){
		for(int j = 0; j < widthResolution; j++){
			Pixel aNewPixel;
			aNewPixel.position.realPart = i;
			aNewPixel.position.imaginaryPart = j;
			aNewPixel.bright = 0; 
			(*aNewGraphicSettings).pixelGrid[i * widthResolution + j] = aNewPixel;
		}
	}

	(*aNewGraphicSettings).fileOuptut = getFileOutput("asd");

	return aNewGraphicSettings;
}

void printOutput(GraphicSettings *aGraphicSettings){

	fprintf((*aGraphicSettings).fileOuptut, "P5\n%u %u 255\n", WIDTH, HEIGHT);
	for(int i = 0; i < HEIGHT; i++){
		for(int j = 0; j < WIDTH; j++){
			char pixelToWrite = (*aGraphicSettings).pixelGrid[i * WIDTH + j].bright * BRIGHT_BOOST;
			fputc(pixelToWrite, (*aGraphicSettings).fileOuptut);
		}
	}
	fclose((*aGraphicSettings).fileOuptut);
}

FILE *getFileOutput(char *aFileName[]){
	FILE *outputFile = fopen("Prueba.pgm", "wb");
	if (outputFile == NULL)
		perror("Error");
}

int getResolution(char *aType, char *anImageResolution){
	return 1920;
}

/*ComplexNumber getComplexNumber(char *aComplexNumberStringFormat){

}*/

double absoluteValue(ComplexNumber z){

	double squareSum = (z.realPart * z.realPart) + (z.imaginaryPart * z.imaginaryPart);
	return (double) sqrt(squareSum);
}

unsigned char calculateEscapeVelocity(ComplexNumber z, ComplexNumber c){
	int i;
	for(i = 0; i < 256; i++){
		if(absoluteValue(z) > 2)
			break;
		double oldRealPart = z.realPart;
		double oldImaginaryPart = z.imaginaryPart;
		z.realPart = (oldRealPart * oldRealPart) - (oldImaginaryPart * oldImaginaryPart) + c.realPart;
		z.imaginaryPart = (2 * oldRealPart * oldImaginaryPart) + c.imaginaryPart;
	}

	return i;
}

void calculatePixelsPosition(SetSpace *aSpace, Pixel *pixels){
	double scaleFactorRealAxis = (*aSpace).width / WIDTH;
	double scaleFactorImaginaryAxis = (*aSpace).height / HEIGHT;

	double middlePointRealAxis = scaleFactorRealAxis / 2;
	double middlePointImaginaryAxis = scaleFactorImaginaryAxis / 2;

	double startPointRealAxis = (*aSpace).offset.realPart - (*aSpace).width/2 + middlePointRealAxis;
	double startPointImaginaryAxis = (*aSpace).offset.imaginaryPart - (*aSpace).height/2 + middlePointImaginaryAxis;	

	double positionIncrementRealAxis = startPointRealAxis;
	double positionIncrementImaginaryAxis = startPointImaginaryAxis;
	for(int i = 0; i < HEIGHT; i++){
		for(int j = 0; j < WIDTH; j++){

			if(i == 0 && j == 0){
				pixels[i * WIDTH + j].position.realPart = startPointRealAxis;
				pixels[i * WIDTH + j].position.imaginaryPart = startPointImaginaryAxis;
			} else {
				pixels[i * WIDTH + j].position.realPart = positionIncrementRealAxis;;
				pixels[i * WIDTH + j].position.imaginaryPart = positionIncrementImaginaryAxis;				
			}

			positionIncrementRealAxis += middlePointRealAxis;
		}
		positionIncrementImaginaryAxis += middlePointImaginaryAxis;
		positionIncrementRealAxis = startPointRealAxis;
	}
}

void findJuliaSet (SetSpace *aSpace, Pixel *pixels){
	
	calculatePixelsPosition(aSpace, pixels);

	for(int i = 0; i < HEIGHT; i++){
		for(int j = 0; j < WIDTH; j++){
			pixels[i * WIDTH + j].bright = calculateEscapeVelocity(pixels[i * WIDTH + j].position, (*aSpace).constantC);
		}
	}
}
