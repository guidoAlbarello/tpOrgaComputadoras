echo "Diferencias entre archivos utilizando parametros por defecto \n" 

./tp1 -o "std.pgm"

comm -3 "std.pgm" "images/std.pgm"


echo "Diferencias entre archivos utilizando tp1 -C -1.125-0.21650635094611i -o dos.pgm \n"


./tp1 -C -1.125-0.21650635094611i -o dos.pgm

comm -3 "dos.pgm" "images/dos.pgm"
