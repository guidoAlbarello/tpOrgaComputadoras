#include <mips/regdef.h>


.set noreorder
.cpload t9
.set reorder


					O_FP = 60
					O_GP = 56
					O_AO = 64
					O_CR = 0
					O_CI = 4
					O_ZR = 8
					O_ZI = 12
					O_SR = 16
					O_SI = 20
					O_ABSZ = 24
					O_X = 28
					O_Y = 32
					O_C = 36
					O_RES = 40
					O_CPR = 44
					O_CPI = 48
					O_FD = 52
					BUFFSIZE = 40


		            .data
		    
		    
.MACRO store_word
					sb t7, 0(t8)
					srl t7, t7, 8
					sb t7, 1(t8)
					srl t7, t7, 8
					sb t7, 2(t8)
					srl t7,t7, 8
					sb t7, 3(t8)
.ENDM
		    
		    
		    
		            buffer: .space BUFFSIZE
		            TextoError: .asciiz "i/o error.\n" 
		                         
endline:        	.asciiz   "\n"
header:         	.asciiz "P2\n"





					.text
				
					.ent mips32_plot
					.globl mips32_plot
mips32_plot:   
		            #inicializacion stack frame
		            subu sp, sp, 64
		            sw $fp, O_FP(sp)
		            sw gp, O_GP(sp)
		            move $fp, sp
		
		            #cargamos params en el stack frame del caller
		            sw a0, O_AO($fp)
		            move s6, a0
		
		            #inicializamos cpr y cpi
		            lw t0, 24(s6)
		            sw t0, O_CPR($fp)
		            lw t0, 28(s6)
		            sw t0, O_CPI($fp)
		
		            lw t0, 44(s6)
		            sw t0, 52($fp)
		
		            move s3, zero 			#inicializamos contador de cantidad de bytes en buffer a cero
		            li s4, BUFFSIZE			#limite del buffer
		            #escribimos cabecera
					lw t0, 32(s6)
					lw t1, 36(s6)
					lw t2, 40(s6)
					la t6, header 
		            la t4, buffer				#cargamos adres de buffer a escribir
					lh t7, 0(t6)
		            sh t7, 0(t4)			
					lb t7, 2(t6)
					sb t7, 2(t4)
					
					addiu t8,t4,3			#storeword byte a byte
					move t7,t0
					store_word 				# sw t0, 3(t4)
					
					la t0, endline
					lb t7, 0(t0)
					sb t7, 7(t4)
					sw t1, 8(t4)
					sb t7, 12(t4)
					
					addiu t8,t4,13			#storeword byte a byte
					move t7,t2
					store_word 				#sw t2, 13(t4)
					
					
					sb t7, 17(t4) 
		            addiu s3, s3, 18
		
		            #calculos de fractal
		            sw zero, O_Y($fp)
		            lw s0, O_Y($fp)
		            lw t0, 4(s6)
		            sw t0, O_CI($fp)
		            l.s $f11, O_CI($fp)
		            l.s $f17, 36(s6)
		            
#Print del header


loopY:        		mtc1 s0, $f10			#pasar int a float
		            cvt.s.w $f10, $f10  	#pasar int a float. esto tal vez s epuede obviar creando x y c como floats de una. ero como no es el tipo de dato dado me suena mal
		            c.lt.s $f10, $f17
		            bc1f salirLoopY
		            sw zero, O_X($fp)
		            lw s1, O_X($fp)
		            lw t0, 0(s6)
		            sw t0, O_CR($fp)
		            l.s $f13, O_CR($fp)
		            l.s $f16, 32(s6)

loopX:        		mtc1 s1, $f12			#pasar int a float
		            cvt.s.w $f12, $f12
		            c.lt.s $f12, $f16
		            bc1f salirLoopX
		            l.s $f0, O_CR($fp)
		            s.s $f0, O_ZR($fp)
		            l.s $f0, O_CI($fp)
		            s.s $f0, O_ZI($fp)
		
		            sw zero, O_C($fp)
		            lw s2, O_C($fp)
		            l.s $f15, 40(s6)


loopC: 		  		mtc1 s2, $f14				#pasar int a float
		            cvt.s.w $f14, $f14
		            c.lt.s $f14, $f15			#compare $f14 < $f15
		            bc1f salirLoopC 			#salta si no cumple
		            l.s $f0, O_ZR($fp)
		            l.s $f1, O_ZI($fp)
		            mul.s $f2, $f0, $f0
		            mul.s $f3, $f1, $f1
		            add.s $f4, $f0, $f1
		            li.s $f5, 4
		            c.le.s $f5, $f4
		            bc1t salirLoopC				#break
		
		            sub.s $f4, $f2, $f3
		            l.s $f5, O_CPR($fp)
		            add.s $f8, $f4, $f5
		            s.s $f8, O_SR($fp)			#sr = ...
		
		            mul.s $f4, $f0, $f1
		            li.s $f5, 2
		            mul.s $f4, $f4, $f5
		            l.s $f5, O_CPI($fp)
		            add.s $f9, $f4, $f5
		            s.s $f9, O_SI($fp)			#si = ...
		
		            s.s $f8, O_ZR($fp)			#zr = sr
		            s.s $f9, O_ZI($fp)			#zi = si
		
		            addiu s2, s2, 1	#++c
		            b loopC

salirLoopC:   		bge s3, s4, escribirEnArchivo1
		            la t0, buffer				#cargamos adres de buffer a escribir
		            li t2, 4
		            mul t1, s3, t2
		            addu t0, t0, t1
		            sb s2, 0(t0)			#guardamos c en buffer
		            addiu s3, s3, 1
					b escribirEndLine
					
escribirEnArchivo1:	li v0, 15			#write syscal value
                    lw a0, O_FD($fp)
                    la a1, buffer
                    move a2, s3                     
                    syscall
                    blt v0, zero, mostrarError
					move s3, zero
                    b salirLoopC
					
escribirEndLine:	bge s3, s4, escribirEnArchivo2
					la t0, buffer				
					la t4, endline
					lb t3, 0(t4)
		            li t2, 4
		            mul t1, s3, t2
		            addu t0, t0, t1
		            sb t3, 0(t0)			
		            addiu s3, s3, 1
					b incrementoLoopX
					
escribirEnArchivo2:	li v0, 15			#write syscal value
                    lw a0, O_FD($fp)
                    la a1, buffer
                    move a2, s3                     
                    syscall
                    blt v0, zero, mostrarError
					move s3, zero
                    b escribirEndLine
					
incrementoLoopX:  	addiu s1, s1, 1
	                l.s $f0, 16(s6)
	                add.s $f13, $f13, $f0
	                b loopX

salirLoopX: 		addiu s0, s0, 1
					l.s $f0, 20(s6)
					add.s $f11, $f11, $f0
					b loopY

#el flush y cerrar programa, stack frame y listo


salirLoopY:         beqz s3, salir
					li v0, 15			#write syscal value
                    lw a0, O_FD($fp)
                    la a1, buffer
                    move a2, s3 #aca puede ir s3 o BUFFSIZE porq tecnicamente
                    #siempre entraria aca cuando elbufer se llena. pero por si
                    #acaso dejo s3 por si es la ultima escritura y no se llega a
                    #llenar el buffer. cualquer cosa si hay algun problema lo
                    #cambiamos
                    syscall
                    blt v0, zero, mostrarError
					li v0, 0

salir:              lw gp, O_GP($fp)
                    lw $fp, O_FP($fp)
                    addiu sp,sp, 64
                    jr ra

mostrarError: 		li v0, 15   #write syscal
		            li a0, 2			#stderrr file descriptor
		            la a1, TextoError
		            li a2, 10				#cantidad de bytes a ecribir. largo de cadena de texto
		            syscall
		            li v0, -1
		            b salir
		            
