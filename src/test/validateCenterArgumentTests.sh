#!/bin/bash

cd ..

COLOR="\033[95m"
DEF_COLOR="\033[0m"

function runAndPrint {
  echo -e "$COLOR"
  echo -e  "CORRIENDO: $PRUEBA\n"
  echo -e "$DEF_COLOR"
  echo "salida: "
  echo `$PRUEBA`
  echo -e "\n"
}



PRUEBA="./tp0 -c 300x200"
runAndPrint

PRUEBA="./tp0 -c 10+5i"
runAndPrint

PRUEBA="./tp0 -c"
runAndPrint

PRUEBA="./tp0 -c asdf"
runAndPrint

PRUEBA="./tp0 -c 10+i"
runAndPrint

PRUEBA="./tp0 -c 10+10"
runAndPrint

PRUEBA="./tp0 -c +5i"
runAndPrint
