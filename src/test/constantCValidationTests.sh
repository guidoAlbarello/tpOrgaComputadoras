#!/bin/bash
cd ..

COLOR="\033[33m"
DEF_COLOR="\033[0m"

echo -e "$COLOR"
echo -e "PRUEBAS DE VALIDACION DE PARAMETROS: CONSTANTE C\n"

function runAndPrint {
  echo -e "$COLOR"
  echo -e  "CORRIENDO: $PRUEBA\n"
  echo -e "$DEF_COLOR"
  echo "salida: "
  echo `$PRUEBA`
  echo -e "\n"
}

PRUEBA="./tp0 -C 300x200"
runAndPrint


PRUEBA="./tp0 -C 10+5i"
runAndPrint

PRUEBA="./tp0 -C"
runAndPrint

PRUEBA="./tp0 -C asdf"
runAndPrint

PRUEBA="./tp0 -C 10+i"
runAndPrint

PRUEBA="./tp0 -C -0.4+0.6i"
runAndPrint
