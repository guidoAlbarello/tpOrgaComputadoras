#!/bin/bash

cd ..

COLOR="\033[96m"
DEF_COLOR="\033[0m"



echo -e "$COLOR"
echo -e "PRUEBAS DE VALIDACION DE PARAMETROS: RESOLUCION\n"


function runAndPrint {
  echo -e "$COLOR"
  echo -e  "CORRIENDO: $PRUEBA\n"
  echo -e "$DEF_COLOR"
  echo "salida: "
  echo `$PRUEBA`
  echo -e "\n"
}

PRUEBA="./tp0 -r 300x200"
runAndPrint

PRUEBA="./tp0 -r 100x"
runAndPrint

PRUEBA="./tp0 -r"
runAndPrint

PRUEBA="./tp0 -r asdf"
runAndPrint

PRUEBA="./tp0 -r 10x1alskdj"
runAndPrint
