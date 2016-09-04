#!/bin/bash

gcc JuliaSet.c -o resValidation
echo -e  "ARGUMENTO: -r 300x200\n"
echo "salida: "
./resValidation -r 300x200
echo -e "\n"

echo -e  "ARGUMENTO: -r 100x\n"
echo "salida: "
./resValidation -r 100x
echo -e "\n"

echo -e  "ARGUMENTO: -r \n"
echo "salida: "
./resValidation -r

echo -e "\n"

echo -e  "ARGUMENTO: -r asdf\n"
echo "salida: "
./resValidation -r asdf
echo -e "\n"

echo -e  "ARGUMENTO: -r 10x1alskdj\n"
echo "salida: "
./resValidation -r 10x1alskdj
echo -e "\n"
