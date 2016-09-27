
cd ..

COLOR="\033[33m"
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
echo -e "PRUEBAS DE VALIDACION DE PARAMETROS: ALTO DEL RECTANGULO\n"

PRUEBA="./tp0 -o "file.pgm" -H -200"
runAndPrint

PRUEBA="./tp0 -o "file.pgm" -H 300"
runAndPrint

PRUEBA="./tp0 -o "file.pgm" -H 3"
runAndPrint

PRUEBA="./tp0 -o "file.pgm" -H 1.02"
runAndPrint

PRUEBA="./tp0 -o "file.pgm" -H asdf"
runAndPrint

PRUEBA="./tp0 -o "file.pgm" -H "
runAndPrint

PRUEBA="./tp0 -o "file.pgm" -H 0"
runAndPrint
