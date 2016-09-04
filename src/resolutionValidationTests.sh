#!/bin/bash

make

echo -e  "ARGUMENTO: -r 300x200\n"
echo "salida: "
./tp0 -r 300x200
echo -e "\n"

echo -e  "ARGUMENTO: -r 100x\n"
echo "salida: "
./tp0 -r 100x
echo -e "\n"

echo -e  "ARGUMENTO: -r \n"
echo "salida: "
./tp0 -r

echo -e "\n"

echo -e  "ARGUMENTO: -r asdf\n"
echo "salida: "
./tp0 -r asdf
echo -e "\n"

echo -e  "ARGUMENTO: -r 10x1alskdj\n"
echo "salida: "
./tp0 -r 10x1alskdj
echo -e "\n"
