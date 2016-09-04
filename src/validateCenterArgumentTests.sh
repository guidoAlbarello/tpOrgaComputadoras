#!/bin/bash

make

echo -e  "ARGUMENTO: -c 300x200\n"
echo "salida: "
./tp0 -c 300x200
echo -e "\n"

echo -e  "ARGUMENTO: -c 10+5i\n"
echo "salida: "
./tp0 -c 10+5i
echo -e "\n"

echo -e  "ARGUMENTO: -c \n"
echo "salida: "
./tp0 -c

echo -e "\n"

echo -e  "ARGUMENTO: -c asdf\n"
echo "salida: "
./tp0 -c asdf
echo -e "\n"

echo -e  "ARGUMENTO: -c 10+i\n"
echo "salida: "
./tp0 -c 10+i
echo -e "\n"

echo -e  "ARGUMENTO: -c 10+10\n"
echo "salida: "
./tp0 -c 10+10
echo -e "\n"
