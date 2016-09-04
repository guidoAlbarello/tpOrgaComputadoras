#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <juliaSet.h>
#include <unistd.h>
#include <string.h>
#include <stdbool.h>

#define C_REAL_PART -0.4
#define C_IMAGINARY_PART 0.6
#define WIDTH 7680
#define HEIGHT 4320
#define OFFSET_REAL_PART 2.5
#define OFFSET_IMAGINARY_PART 2.5
#define SPACE_HEIGHT 10
#define SPACE_WIDTH 10
#define BRIGHT_BOOST 3
#define DEFAULT_FILE "file.pgm"

#define RESOLUTION 'r'
#define CONSTANTC 'C'
#define CENTER 'c'
#define ERROR_INVALID_RESOLUTION "fatal: invalid resolution specification."
#define ERROR_INVALID_CONSTANTC "fatal: invalid constant c specification."
#define ERROR_UNKNOWN_ARGUMENT "fatal: invalid parameter specification"
#define ERROR_OPTION_WITH_NO_PARAMETER "fatal: some of the input parameters were not specified"
#define ERROR_INVALID_CENTER "fatal: invalid center specification"
#define POSIBLE_OPTIONS "r:C:c:"


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
	int widthResolution;
	int heightResolution;
	Pixel *pixelGrid;
	FILE *fileOuptut;
} GraphicSettings;











bool isAValidNumberInAString(char* numberRepresentedAsAString);
void invalidParameter(char* errorMSG);
bool validateResolutionArgument(char* argument, int* width, int* height);
void inputValidationAndInitialization(int argc, char* argv[], SetSpace** setSpace,GraphicSettings** graphicSettings);
SetSpace *initializeDefaultSpace();
GraphicSettings *initializeGraphicSettings(int widtRes, int heightRes,char* file);
void printOutput(GraphicSettings *aGraphicSettings);
FILE *getFileOutput(char *aFileName);
int getResolution(char *aType, char *anImageResolution);

unsigned char calculateEscapeVelocity(ComplexNumber z, ComplexNumber c);
void calculatePixelsPosition(SetSpace *aSpace, Pixel *pixels, int resolutionWidth, int resolutionHeight);
void findJuliaSet (SetSpace *aSpace, Pixel *pixels, int width,int height);






bool isAValidNumberInAString(char* numberRepresentedAsAString){
  if(strlen(numberRepresentedAsAString) == 0)
    return false;
  for(int i = 0; i < strlen(numberRepresentedAsAString); i++){
    if(!isdigit(numberRepresentedAsAString[i]))
            return false;
  }
  return true;
}



void invalidParameter(char* errorMSG){
  printf("%s\n",errorMSG);
  exit(EXIT_FAILURE);
}



bool validateResolutionArgument(char* argument, int* width, int* height){
  //Resolution must be NUMBERxNUMBER ( 100x100 )
  if(strlen(argument) == 0)
    return false;
  char delimiter[1] = "x";
  char* firstNumberString = strsep(&argument,delimiter);
  char* secondNumberString = strsep(&argument,delimiter);
  if(!firstNumberString || !secondNumberString){
    return false;
  }

  if(!isAValidNumberInAString(firstNumberString) ||
  !isAValidNumberInAString(secondNumberString)){
    return false;
  }

	*width = atoi(firstNumberString);
	*height = atoi(secondNumberString);
	return true;
}



bool containsTheImaginaryIndicator(char* imaginaryNumberString){
	if(imaginaryNumberString[strlen(imaginaryNumberString)-1] != 'i'){
		return false;
	}
	return true;
}



bool isAValidDoubleInAString(char* number,double* d){
	if (strlen(number) == 0)
		return false;
	return sscanf (number,"%lf",d);

}





bool isAValidComplexNumberString(char* argument,double* realPart, double* imaginaryPart){
	if(strlen(argument) == 0)
    return false;

	double realSign = 1;
	double imaginarySign = 1;

	char delimiter[2];
	if( argument[0] == '+'){
		strsep(&argument,"+");
	}
	else{
		if (argument[0] == '-'){
			strsep(&argument,"-");
			realSign = -1;
		}
	}

	if(strchr(argument,'+')){
		strcpy(delimiter, "+");
	}
	else{
		if(strchr(argument,'-')){
			strcpy(delimiter, "-");
			imaginarySign = -1;
		}

	}

  char* realNumberString = strsep(&argument,delimiter);
  char* imaginaryNumberString = strsep(&argument,delimiter);
  if(!realNumberString || !imaginaryNumberString){
    return false;
  }

	if( !containsTheImaginaryIndicator(imaginaryNumberString)){
		return false;
	}

	imaginaryNumberString = strsep(&imaginaryNumberString,"i");


  if(!isAValidDoubleInAString(realNumberString,realPart) ||
  !isAValidDoubleInAString(imaginaryNumberString,imaginaryPart)){
    return false;
  }

	*realPart *= realSign;
	*imaginaryPart *= imaginarySign;

	return true;
}





bool validateConstantCArgument(char* argument,SetSpace* setSpace){
	double* cRealPart = &((*setSpace).constantC.realPart);
	double* cImaginaryPart = &((*setSpace).constantC.imaginaryPart);
	if(!isAValidComplexNumberString(argument,cRealPart,cImaginaryPart)){
		return false;
	}
	return true;
}




bool validateCenterArgument(char* argument,SetSpace* setSpace){
	double* centerRealPart = &((*setSpace).offset.realPart);
	double* centerImaginaryPart = &((*setSpace).offset.imaginaryPart);
	if(!isAValidComplexNumberString(argument,centerRealPart,centerImaginaryPart)){
		return false;
	}
	return true;
}




void inputValidationAndInitialization(int argc, char* argv[], SetSpace** setSpace,GraphicSettings** graphicSettings){

	int widthResolution = WIDTH;
	int heightResolution = HEIGHT;

	char file[] = DEFAULT_FILE;
	*setSpace = initializeDefaultSpace();

	int argumentOption;
	opterr = 0;
	while ((argumentOption = getopt (argc, argv, POSIBLE_OPTIONS)) != -1)
		switch (argumentOption)
			{
			case RESOLUTION:
				if(!validateResolutionArgument(optarg,&widthResolution,&heightResolution)){
					free((*setSpace));
					invalidParameter(ERROR_INVALID_RESOLUTION);
				}
				break;

			case CONSTANTC:
				if(!validateConstantCArgument(optarg,*setSpace)){
					free((*setSpace));
					invalidParameter(ERROR_INVALID_CONSTANTC);
				}
				break;

			case CENTER:
				if(! validateCenterArgument(optarg,*setSpace)){
					free((*setSpace));
					invalidParameter(ERROR_INVALID_CENTER);
				}
				break;

			case '?'://ALGUN PARAMETRO NO TIENE PAR
				free((*setSpace));
				invalidParameter(ERROR_OPTION_WITH_NO_PARAMETER);
				break;
			default:
				free((*setSpace));
				invalidParameter(ERROR_UNKNOWN_ARGUMENT);
				abort ();
			}

	*graphicSettings = initializeGraphicSettings(widthResolution,heightResolution,file);

}



SetSpace *initializeDefaultSpace(){

	SetSpace *aNewSpace = malloc(sizeof(SetSpace));

	(*aNewSpace).offset.realPart = OFFSET_REAL_PART;
	(*aNewSpace).offset.imaginaryPart = OFFSET_IMAGINARY_PART;

	(*aNewSpace).constantC.realPart = C_REAL_PART;
	(*aNewSpace).constantC.imaginaryPart = C_IMAGINARY_PART;

	(*aNewSpace).width = SPACE_WIDTH;									// hay una mejor que atoi que chequea errores
	(*aNewSpace).height = SPACE_HEIGHT;

	return aNewSpace;
}



GraphicSettings *initializeGraphicSettings(int widtRes, int heightRes,char* file){

	GraphicSettings * aNewGraphicSettings = malloc(sizeof(GraphicSettings));
	(*aNewGraphicSettings).widthResolution = widtRes;
	(*aNewGraphicSettings).heightResolution = heightRes;

	(*aNewGraphicSettings).pixelGrid = malloc(sizeof(Pixel) * (*aNewGraphicSettings).widthResolution * (*aNewGraphicSettings).heightResolution);
	for(int i = 0; i < (*aNewGraphicSettings).heightResolution; i++){
		for(int j = 0; j < (*aNewGraphicSettings).widthResolution; j++){
			Pixel aNewPixel;
			aNewPixel.position.realPart = i;
			aNewPixel.position.imaginaryPart = j;
			aNewPixel.bright = 0;
			(*aNewGraphicSettings).pixelGrid[i * (*aNewGraphicSettings).widthResolution + j] = aNewPixel;
		}
	}
	(*aNewGraphicSettings).fileOuptut = getFileOutput(file);
	return aNewGraphicSettings;
}



void printOutput(GraphicSettings *aGraphicSettings){

	fprintf((*aGraphicSettings).fileOuptut, "P5\n%u %u 255\n", (*aGraphicSettings).widthResolution, (*aGraphicSettings).heightResolution);
	for(int i = 0; i < (*aGraphicSettings).heightResolution; i++){
		for(int j = 0; j < (*aGraphicSettings).widthResolution; j++){
			char pixelToWrite = (*aGraphicSettings).pixelGrid[i * (*aGraphicSettings).widthResolution + j].bright * BRIGHT_BOOST;
			fputc(pixelToWrite, (*aGraphicSettings).fileOuptut);
		}
	}
	fclose((*aGraphicSettings).fileOuptut);
}



FILE *getFileOutput(char *aFileName){
	FILE *outputFile = fopen(aFileName, "wb");
	if (outputFile == NULL)
		perror("Error");
	return outputFile;
}



int getResolution(char *aType, char *anImageResolution){
	return 1920;
}



/*ComplexNumber getComplexNumber(char *aComplexNumberStringFormat){

}*/











void calculatePixelsPosition(SetSpace *aSpace, Pixel *pixels, int resolutionWidth, int resolutionHeight){
	double scaleFactorRealAxis = (*aSpace).width / resolutionWidth;
	double scaleFactorImaginaryAxis = (*aSpace).height / resolutionHeight;

	double middlePointRealAxis = scaleFactorRealAxis / 2;
	double middlePointImaginaryAxis = scaleFactorImaginaryAxis / 2;

	double startPointRealAxis = (*aSpace).offset.realPart - (*aSpace).width/2 + middlePointRealAxis;
	double startPointImaginaryAxis = (*aSpace).offset.imaginaryPart - (*aSpace).height/2 + middlePointImaginaryAxis;

	double positionIncrementRealAxis = startPointRealAxis;
	double positionIncrementImaginaryAxis = startPointImaginaryAxis;
	for(int i = 0; i < resolutionHeight; i++){
		for(int j = 0; j < resolutionWidth; j++){

			if(i == 0 && j == 0){
				pixels[i * resolutionWidth + j].position.realPart = startPointRealAxis;
				pixels[i * resolutionWidth + j].position.imaginaryPart = startPointImaginaryAxis;
			} else {
				pixels[i * resolutionWidth + j].position.realPart = positionIncrementRealAxis;;
				pixels[i * resolutionWidth + j].position.imaginaryPart = positionIncrementImaginaryAxis;
			}

			positionIncrementRealAxis += middlePointRealAxis;
		}
		positionIncrementImaginaryAxis += middlePointImaginaryAxis;
		positionIncrementRealAxis = startPointRealAxis;
	}
}



void findJuliaSet (SetSpace *aSpace, Pixel *pixels, int width,int  height){

	calculatePixelsPosition(aSpace, pixels, width, height);

	for(int i = 0; i < height; i++){
		for(int j = 0; j < width; j++){
			pixels[i * width + j].bright = calculateEscapeVelocity(pixels[i * width + j].position, (*aSpace).constantC);
		}
	}
}



int main(int argc, char *argv[]){												//por ahora argv tiene el orden = 1. archivo 2. resolucion
																				//3. offset 4. C 5. width 6. height
	SetSpace* aSpace;
	GraphicSettings* theGraphicSettings;
	inputValidationAndInitialization(argc, argv, &aSpace, &theGraphicSettings);
	findJuliaSet(aSpace, (*theGraphicSettings).pixelGrid,(*theGraphicSettings).widthResolution,(*theGraphicSettings).heightResolution);
	printOutput(theGraphicSettings);

	free(aSpace);
	free(theGraphicSettings);

	return 0;
}
