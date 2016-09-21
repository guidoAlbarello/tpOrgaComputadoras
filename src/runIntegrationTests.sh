
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

PRUEBA="./tp0 -c 0.01+0i -r 1x1 -o -"
runAndPrint


PRUEBA="./tp0 -c 10+0i -r 1x1 -o -"

runAndPrint

PRUEBA="./tp0 -c 0+0i -r 0x1 -o -"
runAndPrint

PRUEBA="./tp0 -o /tmp"
runAndPrint

PRUEBA="./tp0 -c 1+3 -o -"
runAndPrint

PRUEBA="./tp0 -c "" -o -"
runAndPrint
