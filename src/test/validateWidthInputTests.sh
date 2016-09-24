cd ..

COLOR="\033[31m"
DEF_COLOR="\033[0m"

function runAndPrint {
  echo -e "$COLOR"
  echo -e  "CORRIENDO: $PRUEBA\n"
  echo -e "$DEF_COLOR"
  echo "salida: "
  echo `$PRUEBA`
  echo -e "\n"
}

echo -e "$COLOR"
echo -e "PRUEBAS DE VALIDACION DE PARAMETROS: ANCHO DEL RECTANGULO\n"


PRUEBA="./tp0 -o "file.pgm" -w 3"
runAndPrint

PRUEBA="./tp0 -o "file.pgm" -w 1.02"
runAndPrint

PRUEBA="./tp0 -o "file.pgm" -w asdf"
runAndPrint

PRUEBA="./tp0 -o "file.pgm" -w "
runAndPrint

PRUEBA="./tp0 -o "file.pgm" -w 0"
runAndPrint
