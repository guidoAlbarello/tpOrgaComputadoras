echo "Corriendo: ./tp1 -o std.pgm"

./tp1 -o "std.pgm"

echo "Diferencias entre el archivo generado con el .S y el generado con el .c" 

comm -3 "std.pgm" "images/std.pgm"


echo "Corriendo: ./tp1 -C -1.125-0.21650635094611i -o dos.pgm"


./tp1 -C -1.125-0.21650635094611i -o dos.pgm


echo "Diferencias entre el archivo generado con el .S y el generado con el .c" 


comm -3 "dos.pgm" "images/dos.pgm"
