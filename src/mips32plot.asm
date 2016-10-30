.align 2
.set noreorder
.cpload t9
.set reorder
.eqv O_FP 60
.eqv O_GP 56
.eqv O_AO 64
.eqv O_CR 0
.eqv O_CI 4
.eqv O_ZR 8
.eqv O_ZI 12
.eqv O_SR 16
.eqv O_SI 20
.eqv O_ABSZ 24
.eqv O_X 28 
.eqv O_Y 32 
.eqv O_C 36 
.eqv O_RES 40 
.eqv O_CPR 44
.eqv O_CPI 48 
.eqv O_FP 52 
.eqv BUFFSIZE 8192

.text

#inicializacion stack frame
subu $sp, $sp, 64
sw $fp, O_FP($sp)
sw $gp, O_GP($sp)
move $fp, $sp

#cargamos params en el stack frame del caller
sw $a0, O_A0($fp)
move $s6, $a0

#inicializamos cpr y cpi 
lw $t0, 24($s6)
sw $t0, O_CPR($fp)
lw $t0, 28($s6)
sw $t0, O_CPI($fp)

lw $t0, 44($s6)
sw $t0, 52($fp)

move $s3, $r0 		#inicializamos contador de cantidad de bytes en buffer a cero
li $s4, BUFFSIZE	#limite del buffer
#escribimos cabecera


#calculos de fractal
sw $r0, O_Y($fp)
lw $s0, O_Y($fp)
lw $t0, 4($s6)
sw $t0, O_CI($fp)
lwcz $f11, O_CI($fp)
lwcz $f17, 36($s6)

loopY:mtc1 $s0, $f10				#pasar int a float
cvt.s.w $f10, $f10  				#pasar int a float. esto tal vez s epuede obviar creando x y c como floats de una. ero como no es el tipo de dato dado me suena mal	
c.lt.s $f10, $f17								
bclf salirLoopY 
sw $r0, O_X($fp)
lw $s1, O_X($fp)
lw $t0, 0($s6)
sw $t0, O_CR($fp)
lwcz $f13, O_CR($fp)	
lwcz $f16, 32($s6)

loopX: $s1, $f12				#pasar int a float
cvt.s.w $f12, $f12
c.lt.s $f12, $f16								
bclf salirLoopX 
lwcz $f0, O_CR($fp)
swcz $f0, O_ZR($fp)
lwcz $f0, O_CI($fp)
swcz $f0, O_ZI($fp)

sw $r0, O_C($fp)
lw $s2, O_C($fp)
lwcz $f15, 40($s6)
loopC: $s2, $f14				#pasar int a float
cvt.s.w $f14, $f14
c.lt.s $f14, $f15								#compare f14 < f15
bclf salirLoopC 												#salta si no cumple 	
lwcz $f0, O_ZR($fp)
lwcz $f1, O_ZI($fp)
mul.s $f2, $f0, $f0
mul.s $f3, $f1, $f1 
add.s $f4, $f0, $f1
li.s $f5, 4.0
c.gt.s $f4, $f5 
bclt salirLoopC				#break

sub.s $f4, $f2, $f3
lwcz $f5, O_CPR($fp)
add.s $f8, $f4, $f5
swcz $f8, O_SR($fp)			#$sr = ...

mul.s $f4, $f0, $f1
li.s $f5, 2.0
mul.s $f4, $f4, $f5
lwcz $f5, O_CPI($fp)
add.s $f9, $f4, $f5
swcz $f9, O_SI($fp)			#si = ...

swcz $f8, O_ZR($fp)			#zr = sr
swcz $f9, O_ZI($fp)			#zi = si

addiu $s2, $s2, 1	#++c
b loopC
salirLoopC: bgt $s3, $s4, escribirEnArchivo
la $t0, buffer				#cargamos adres de buffer a escribir 
li $t2, 4
mul $t1, $s3, $t2 
addu $t0, $t0, $t1
sw $s2, 0($t0)			#guardamos c en buffer
addiu $s3, $s3, 1

incrementoLoopX: addiu $s1, $s1, 1	
lwcz $f0, 16($s6) 														
add.s $f13, $f13, $f0	
b loopX

salirLoopX: addiu $s0, $s0, 1	
lwcz $f0, 20($s6) 														
add.s $f11, $f11, $f0
b loopY

salirLoopY:	#el flush y cerrar programa, stack frame y listo
salir: #aca se limpia la pila y desp se returnea al ra (guarda q a aca puede saltar desde cuando hay error al escribir. tener en cuenta q lo unico q cambia es q devuelve error code -1. entonces a partir de aca solo se tendria q hacer la limpieza de pila y retorno. guardar el argumento de v0 si todo se realizo correctamente antes de esta parte, asi no sobreescibe el valor de retorno si llegase a haber error en la escritura de archivo)
escribirEnArchivo: li $v0, 15			#write syscal value
lw $t0, O_FP($fp)
move $a0, $t0
la $a1, buffer
move $a2, $s3 #aca puede ir $s3 o BUFFSIZE porq tecnicamente siempre entraria aca cuando elbufer se llena. pero por si acaso dejo s3 por si es la ultima escritura y no se llega a llenar el buffer. cualquer cosa si hay algun problema lo cambiamos
syscall
blt $v0, $r0, mostrarError
b incrementoLoopX

mostrarError: li $v0, 15   #write syscal
li $a0, 2			#stderrr file descriptor
la $a1, TextoError
li $a2, 10				#cantidad de bytes a ecribir. largo de cadena de texto
syscall
li $v0, -1 
b salir 
.data
buffer: .space BUFFSIZE
TextoError: .asciiz "i/o error.\n"


