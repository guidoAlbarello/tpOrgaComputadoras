#!/bin/bash

make

echo -e  "ARGUMENTO: -C 300x200\n"
echo "salida: "
./tp0 -C 300x200
echo -e "\n"

echo -e  "ARGUMENTO: -C 10+5i\n"
echo "salida: "
./tp0 -C 10+5i
echo -e "\n"

echo -e  "ARGUMENTO: -C \n"
echo "salida: "
./tp0 -C

echo -e "\n"

echo -e  "ARGUMENTO: -C asdf\n"
echo "salida: "
./tp0 -C asdf
echo -e "\n"

echo -e  "ARGUMENTO: -C 10+i\n"
echo "salida: "
./tp0 -C 10+i
echo -e "\n"

echo -e  "ARGUMENTO: -C -0.4+0.6i\n"
echo "salida: "
./tp0 -C -0.4+0.6i
echo -e "\n"
