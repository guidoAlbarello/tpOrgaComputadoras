#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <stdbool.h>

#define C_REAL_PART 0.285
#define WIDTH 640
#define HEIGHT 480
#define OFFSET_REAL_PART 0
#define OFFSET_IMAGINARY_PART 0
#define SPACE_HEIGHT 4
#define SPACE_WIDTH 4
#define BRIGHT_BOOST 1
#define DEFAULT_FILE "file.pgm"
#define MAX_ITERACION 255
#define COND_CORTE_MOD_CUADRADO 4.0

#define WIDTH_OPTION 'w'
#define HEIGHT_OPTION 'H'
#define FILE_OPTION 'o'
#define RESOLUTION 'r'
#define CONSTANTC 'C'
#define CENTER 'c'
#define ERROR_INVALID_RESOLUTION "fatal: invalid resolution specification."
#define ERROR_INVALID_CONSTANTC "fatal: invalid constant c specification."
#define ERROR_UNKNOWN_ARGUMENT "fatal: invalid parameter specification."
#define ERROR_OPTION_WITH_NO_PARAMETER "fatal: some of the input parameters were not specified."
#define ERROR_INVALID_CENTER "fatal: invalid center specification."
#define ERROR_INVALID_WIDTH "fatal: invalid width specification."
#define ERROR_INVALID_HEIGHT "fatal: invalid height specification."
#define ERROR_INVALID_FILE "fatal: invalid file specification."
#define ERROR_TRYING_TO_OPEN_THE_FILE "fatal: the system could not open the output file."
#define ERROR_TRYING_TO_WRITE_TO_FILE "fatal: the system could not write to output file."
#define POSIBLE_OPTIONS "r:C:c:w:H:o:"


typedef struct ComplexNumber{
	double realPart;
	double imaginaryPart;
} ComplexNumber;


typedef struct SetSpace {
	ComplexNumber offset;
	ComplexNumber constantC;
	double width;
	double height;
} SetSpace;

typedef struct Pixel {
	unsigned char bright;
	ComplexNumber position;
} Pixel;

typedef struct GraphicSettings {
	int widthResolution;
	int heightResolution;
	Pixel **pixelGrid;
	FILE *fileOutput;
} GraphicSettings;







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




bool isAValidNumberInAString(char* numberRepresentedAsAString) {
	if (strlen(numberRepresentedAsAString) == 0)
		return false;
	int i;
	for (i = 0; i < strlen(numberRepresentedAsAString); i++) {
		if (!isdigit(numberRepresentedAsAString[i]))
			return false;
	}
	return true;
}



void invalidParameter(char* errorMSG) {
	fprintf(stderr, "%s\n", errorMSG);
	exit(EXIT_FAILURE);
}



bool validateResolutionArgument(char* argument, int* width, int* height) {
	//Resolution must be NUMBERxNUMBER ( 100x100 )
	if (strlen(argument) == 0)
		return false;
	char delimiter[1] = "x";
	char* firstNumberString = strsep(&argument, delimiter);
	char* secondNumberString = strsep(&argument, delimiter);
	if (!firstNumberString || !secondNumberString) {
		return false;
	}

	if (!isAValidNumberInAString(firstNumberString) ||
		!isAValidNumberInAString(secondNumberString)) {
		return false;
	}

	*width = atoi(firstNumberString);
	*height = atoi(secondNumberString);
	if (*width > 0 && *height > 0) {
		return true;
	}
	return false;
}



bool containsTheImaginaryIndicator(char* imaginaryNumberString) {
	if (imaginaryNumberString[strlen(imaginaryNumberString) - 1] != 'i') {
		return false;
	}
	return true;
}



bool isAValidDoubleInAString(char* number, double* d) {
	if (strlen(number) == 0)
		return false;
	return sscanf(number, "%lf", d);

}





bool isAValidComplexNumberString(char* argument, double* realPart, double* imaginaryPart) {
	if (strlen(argument) == 0)
		return false;

	double realSign = 1;
	double imaginarySign = 1;

	char delimiter[2];
	if (argument[0] == '+') {
		strsep(&argument, "+");
	}
	else {
		if (argument[0] == '-') {
			strsep(&argument, "-");
			realSign = -1;
		}
	}

	if (strchr(argument, '+')) {
		strcpy(delimiter, "+");
	}
	else {
		if (strchr(argument, '-')) {
			strcpy(delimiter, "-");
			imaginarySign = -1;
		}
	}

	char* realNumberString = strsep(&argument, delimiter);
	char* imaginaryNumberString = strsep(&argument, delimiter);
	if (!realNumberString || !imaginaryNumberString) {
		return false;
	}

	if (!containsTheImaginaryIndicator(imaginaryNumberString)) {
		return false;
	}

	imaginaryNumberString = strsep(&imaginaryNumberString, "i");


	if (!isAValidDoubleInAString(realNumberString, realPart) ||
		!isAValidDoubleInAString(imaginaryNumberString, imaginaryPart)) {
		return false;
	}

	*realPart *= realSign;
	*imaginaryPart *= imaginarySign;

	return true;
}




bool validateConstantCArgument(char* argument, SetSpace* setSpace) {
	double* cRealPart = &((*setSpace).constantC.realPart);
	double* cImaginaryPart = &((*setSpace).constantC.imaginaryPart);
	if (!isAValidComplexNumberString(argument, cRealPart, cImaginaryPart)) {
		return false;
	}
	return true;
}




bool validateCenterArgument(char* argument, SetSpace* setSpace) {
	double* centerRealPart = &((*setSpace).offset.realPart);
	double* centerImaginaryPart = &((*setSpace).offset.imaginaryPart);
	if (!isAValidComplexNumberString(argument, centerRealPart, centerImaginaryPart)) {
		return false;
	}
	return true;
}




bool validateHeightArgument(char* argument, SetSpace* setSpace) {
	if (!isAValidDoubleInAString(argument, &(setSpace->height))) return false;
	if (setSpace->height <= 0) return false;
	return true;
}

bool validateWidthArgument(char* argument, SetSpace* setSpace) {
	if (!isAValidDoubleInAString(argument, &(setSpace->width))) return false;
	if (setSpace->width <= 0) return false;
	return true;
}


bool shouldPrintToStandardOutput(char* argument) {
	if (strcmp(argument, "-")) {
		return true;
	}
	return false;
}




FILE* getFileOutput(char *aFileName) {
	 FILE* outputFile = fopen(aFileName, "wb");

	return outputFile;
}


SetSpace *initializeDefaultSpace() {

	SetSpace *aNewSpace = malloc(sizeof(SetSpace));

	aNewSpace->offset.realPart = OFFSET_REAL_PART;
	aNewSpace->offset.imaginaryPart = OFFSET_IMAGINARY_PART;

	aNewSpace->constantC.realPart = C_REAL_PART;
	//No toma si defino una constante con ese valor
	aNewSpace->constantC.imaginaryPart = -0.01;

	aNewSpace->width = SPACE_WIDTH;
	aNewSpace->height = SPACE_HEIGHT;

	return aNewSpace;
}



GraphicSettings *initializeGraphicSettings(int widtRes, int heightRes, char* file, bool printToAFile) {

	GraphicSettings * aNewGraphicSettings = malloc(sizeof(GraphicSettings));
	aNewGraphicSettings->widthResolution = widtRes;
	aNewGraphicSettings->heightResolution = heightRes;


	int i,j;
	//aNewGraphicSettings->pixelGrid = malloc(sizeof(Pixel) * aNewGraphicSettings->widthResolution * aNewGraphicSettings->heightResolution);
	aNewGraphicSettings->pixelGrid = (Pixel **)malloc(sizeof(Pixel *) * aNewGraphicSettings->heightResolution);
	for (i = 0; i < aNewGraphicSettings->heightResolution; i++) {
		aNewGraphicSettings->pixelGrid[i] = (Pixel *)malloc(sizeof(Pixel) * aNewGraphicSettings->widthResolution);
		for (j = 0; j < aNewGraphicSettings->widthResolution; j++) {
			Pixel aNewPixel;
			aNewPixel.position.realPart = i;
			aNewPixel.position.imaginaryPart = j;
			aNewPixel.bright = 0;
			aNewGraphicSettings->pixelGrid[i][j] = aNewPixel;
		}
	}

	if (printToAFile) {
		 aNewGraphicSettings->fileOutput = getFileOutput(file);
		 if(aNewGraphicSettings->fileOutput == NULL){
				int i;
			 	for( i = 0; i < aNewGraphicSettings->heightResolution;i++){
		 			free(aNewGraphicSettings->pixelGrid[i]);
			 	}
			 	free(aNewGraphicSettings->pixelGrid);
			 	free(aNewGraphicSettings);
				return NULL;
		 }
	}
	else {
		aNewGraphicSettings->fileOutput = stdout;
	}

	return aNewGraphicSettings;
}


/* TODO:
 * 	Agregar -v version
 * 	-h help
 */


bool inputValidationAndInitialization(int argc, char* argv[], SetSpace** setSpace, GraphicSettings** graphicSettings) {

	int widthResolution = WIDTH;
	int heightResolution = HEIGHT;
	bool printToAFile = true;

	char file[] = DEFAULT_FILE;
	*setSpace = initializeDefaultSpace();

	int argumentOption;
	opterr = 0;
	while ((argumentOption = getopt(argc, argv, POSIBLE_OPTIONS)) != -1)
		switch (argumentOption)
		{
		case RESOLUTION:
			if (!validateResolutionArgument(optarg, &widthResolution, &heightResolution)) {
				free((*setSpace));
				invalidParameter(ERROR_INVALID_RESOLUTION);
			}
			break;

		case CONSTANTC:
			if (!validateConstantCArgument(optarg, *setSpace)) {
				free((*setSpace));
				invalidParameter(ERROR_INVALID_CONSTANTC);
			}
			break;

		case CENTER:
			if (!validateCenterArgument(optarg, *setSpace)) {
				free((*setSpace));
				invalidParameter(ERROR_INVALID_CENTER);
			}
			break;

		case HEIGHT_OPTION:
			if (!validateHeightArgument(optarg, *setSpace)) {
				free((*setSpace));
				invalidParameter(ERROR_INVALID_HEIGHT);
			}
			break;

		case WIDTH_OPTION:
			if (!validateWidthArgument(optarg, *setSpace)) {
				free((*setSpace));
				invalidParameter(ERROR_INVALID_WIDTH);
			}
			break;
		case FILE_OPTION:
			if (strlen(optarg) == 0 || !optarg) {
				free((*setSpace));
				invalidParameter(ERROR_INVALID_FILE);
			}
			printToAFile = shouldPrintToStandardOutput(optarg);
			if (printToAFile) {
				strcpy(file, optarg);
			}
			break;
		case '?'://ALGUN PARAMETRO NO TIENE PAR
			free((*setSpace));
			invalidParameter(ERROR_OPTION_WITH_NO_PARAMETER);
			break;
		default:
			free((*setSpace));
			invalidParameter(ERROR_UNKNOWN_ARGUMENT);
			abort();
		}

	*graphicSettings = initializeGraphicSettings(widthResolution, heightResolution, file, printToAFile);

	if(*graphicSettings == NULL){
		fprintf(stderr, "%s\n", ERROR_TRYING_TO_OPEN_THE_FILE);
		return false;
	}

	return true;
}

/* TODO:
 * Arreglar el codigo para que use header = P2 y no tener que tener un if si el archivo es stdout. Lo pidieron asi ellos.
 * El output tiene que tener end of lines por cada fila:
 *
 * fila1
 * fila2
 * fila3
 */


bool printOutput(GraphicSettings *aGraphicSettings) {

	fprintf(aGraphicSettings->fileOutput, "P2 \n %u %u 255 \n", aGraphicSettings->widthResolution, aGraphicSettings->heightResolution);
	int i,j;
	for ( i = 0; i < aGraphicSettings->heightResolution; i++) {
		for ( j = 0; j < aGraphicSettings->widthResolution; j++) {
			unsigned char pixelToWrite = aGraphicSettings->pixelGrid[i][j].bright;

			//fputc(pixelToWrite, aGraphicSettings->fileOutput);
			fprintf( aGraphicSettings->fileOutput,"%u",pixelToWrite);
			if (ferror(aGraphicSettings->fileOutput)){
				return false;
			}
		}
		fprintf( aGraphicSettings->fileOutput,"\n");
	}
	if (aGraphicSettings->fileOutput != stdout)
		fclose(aGraphicSettings->fileOutput);
	return true;
}











void calculatePixelsPosition(SetSpace *aSpace, Pixel **pixels, int resolutionWidth, int resolutionHeight) {
	double scaleFactorRealAxis = (*aSpace).width / resolutionWidth;
	double scaleFactorImaginaryAxis = (*aSpace).height / resolutionHeight;

	double middlePointRealAxis = scaleFactorRealAxis / 2;
	double middlePointImaginaryAxis = scaleFactorImaginaryAxis / 2;

	double startPointRealAxis = (*aSpace).offset.realPart - (*aSpace).width / 2 + middlePointRealAxis;
	double startPointImaginaryAxis = (*aSpace).offset.imaginaryPart - (*aSpace).height / 2 + middlePointImaginaryAxis;

	double positionIncrementRealAxis = startPointRealAxis;
	double positionIncrementImaginaryAxis = startPointImaginaryAxis;
	
	int i,j;
	for (i = 0; i < resolutionHeight; i++) {
		for (j = 0; j < resolutionWidth; j++) {

			if (i == 0 && j == 0) {
				pixels[i][j].position.realPart = startPointRealAxis;
				pixels[i][j].position.imaginaryPart = startPointImaginaryAxis;
			}
			else {
				pixels[i][j].position.realPart = positionIncrementRealAxis;;
				pixels[i][j].position.imaginaryPart = positionIncrementImaginaryAxis;
			}

			positionIncrementRealAxis += scaleFactorRealAxis;
		}
		positionIncrementImaginaryAxis += scaleFactorImaginaryAxis;
		positionIncrementRealAxis = startPointRealAxis;
	}
}



void findJuliaSet(SetSpace *aSpace, Pixel **pixels, int width, int  height) {

	calculatePixelsPosition(aSpace, pixels, width, height);
	int i,j;
	for (i = 0; i < height; i++) {
		for (j = 0; j < width; j++) {
			pixels[i][j].bright = calculateEscapeVelocity(pixels[i][j].position, (*aSpace).constantC);
		}
	}
}


void clean(SetSpace* aSpace, GraphicSettings* theGraphicSettings){
	if(aSpace != NULL)
		free(aSpace);
	if(theGraphicSettings != NULL){
		if (theGraphicSettings->pixelGrid != NULL) {
			int i;
			for(i = 0; i < theGraphicSettings->heightResolution;i++){
				if(theGraphicSettings->pixelGrid[i] != NULL)
					free(theGraphicSettings->pixelGrid[i]);
			}
			free(theGraphicSettings->pixelGrid);
		}
		free(theGraphicSettings);
	}
}


int main(int argc, char *argv[]) {

	SetSpace* aSpace;
	GraphicSettings* theGraphicSettings;

	if(!inputValidationAndInitialization(argc, argv, &aSpace, &theGraphicSettings)){
		clean(aSpace,theGraphicSettings);
		exit(EXIT_FAILURE);
	}


	findJuliaSet(aSpace, theGraphicSettings->pixelGrid, theGraphicSettings->widthResolution, theGraphicSettings->heightResolution);

	if(!printOutput(theGraphicSettings)){
		clean(aSpace,theGraphicSettings);
		fprintf(stderr, "%s\n", ERROR_TRYING_TO_WRITE_TO_FILE);
		exit(EXIT_FAILURE);
	}

	/*
		printf("ATRIBUTOS: \n Resolution width: %d\n Resolution height %d\n offset: %lf + %lf i\n constantC: %lf + %lf i\n Rectangle: %lf x %lf\n", theGraphicSettings->widthResolution,theGraphicSettings->heightResolution,
		aSpace->offset.realPart, aSpace->offset.imaginaryPart,aSpace->constantC.realPart, aSpace->constantC.imaginaryPart,
		aSpace->width,aSpace->height );
	*/
	clean(aSpace,theGraphicSettings);
	return 0;
}
