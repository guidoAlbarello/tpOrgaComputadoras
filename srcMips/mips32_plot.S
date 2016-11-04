#include <mips/regdef.h>
#include <sys/syscall.h>


					
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
					BUFFSIZE = 8192

		            .data
		    
					.align 2
					
terminator:   .asciiz ""
		    
numbers: .ascii "0123456789"
		    
		    
		    
buffer: .space BUFFSIZE + 3
		             

header:         	.ascii "P2\n"
endline:        	.ascii   "\n"

TextoError: .asciiz "i/o error.\n" 
		             
		             
		            

					.text
				
				
					.globl mips32_plot
mips32_plot:   
		            #inicializacion stack frame
		            subu sp, sp, 68
		            sw $fp, O_FP(sp)
		            sw gp, O_GP(sp)
		            move $fp, sp
		            move t0, $fp
		
		            #cargamos params en el stack frame del caller
		            sw a0, O_AO($fp)
		            move s6, a0
		
		            #inicializamos cpr y cpi
		            lw t0, 24(s6)
		            sw t0, O_CPR($fp)
		            lw t0, 28(s6)
		            sw t0, O_CPI($fp)
		
		            lw t0, 44(s6)
		            sw t0, O_FD($fp)
		
		            move s3, zero 			#inicializamos contador de cantidad de bytes en buffer a cero
		            
		            #escribimos cabecera
					
					
					
					la t6, header 
		            la t4, buffer				#cargamos adres de buffer a escribir
					
					#GUARDO HEADER
					lb t7, 0(t6)
		            sb t7, 0(t4)
		            lb t7, 1(t6)
		            sb t7, 1(t4)
		            lb t7, 2(t6)
		            sb t7, 2(t4)
		            
		            addiu s3, s3, 3
		            
		            #GUARDO XRES DE A BYTES
		            lw s2, 32(s6)	
		            la t9, xres_endline
		            b print_uinteger
		            
		            #GUARDO UN ENDLINE
xres_endline:		la t3, endline
					lb t3, 0(t3)
					addu t7,t4,s3
					sb t3, 0(t7)
					addiu s3, s3, 1
					
					#GUARDO YRES DE A BYTES
					lw s2, 36(s6)	# yres
		            la t9, yres_endline
		            b print_uinteger
		            
		            #otro endline
yres_endline:		la t3, endline
					lb t3, 0(t3)
					addu t7,t4,s3
					sb t3, 0(t7)
					addiu s3, s3, 1
					
					#CARGO LAS SHADES
					lw s2, 40(s6)	
					la t9, lastHeaderEndLine
					b print_uinteger
					
					
					#ultimo endline header
lastHeaderEndLine:	la t3, endline
					lb t3, 0(t3)
					addu t7,t4,s3
					sb t3, 0(t7)
					addiu s3, s3, 1
		            			
					
		
		            #calculos de fractal
		            sw zero, O_Y($fp)
		            lw s0, O_Y($fp)
		            lw t0, 4(s6)
		            sw t0, O_CI($fp)
		            l.s $f16, O_CI($fp)
		            lw s7, 36(s6)
		            
		            

		            
		            
#Print del header


loopY:        		bge s0,s7, salirLoopY
		            sw zero, O_X($fp)
		            lw s1, O_X($fp)
		            lw t0, 0(s6)
		            sw t0, O_CR($fp)
		            l.s $f14, O_CR($fp)
		            lw s5, 32(s6)

loopX:        		bge s1,s5,salirLoopX
		            #l.s $f0, O_CR($fp)
		           # s.s $f0, O_ZR($fp)
		           # l.s $f0, O_CI($fp)
		           # s.s $f0, O_ZI($fp)
					

					#prueba
					s.s $f14, O_ZR($fp)		
					s.s $f16, O_ZI($fp)

		            sw zero, O_C($fp)
		            #lw s2, O_C($fp)
		            move s2, zero
		            lw s4, 40(s6)


loopC: 		  		bge s2,s4, salirLoopC

		            l.s $f0, O_ZR($fp)
		            l.s $f6, O_ZI($fp)
		            mul.s $f2, $f0, $f0
		            mul.s $f12, $f6, $f6
		            add.s $f4, $f2, $f12
		            li.s $f10, 4
		            c.le.s $f10, $f4
		            bc1t salirLoopC				#break
		
		            sub.s $f4, $f2, $f12
		            l.s $f10, O_CPR($fp)
		            add.s $f8, $f4, $f10
		            s.s $f8, O_SR($fp)			#sr = ...
		
		            mul.s $f4, $f0, $f6
		            li.s $f10, 2
		            mul.s $f4, $f4, $f10
		            l.s $f10, O_CPI($fp)
		            add.s $f18, $f4, $f10
		            s.s $f18, O_SI($fp)			#si = ...
		
		            s.s $f8, O_ZR($fp)			#zr = sr
		            s.s $f18, O_ZI($fp)			#zi = si
		
		            addiu s2, s2, 1	#++c
		            b loopC

salirLoopC:   		li t0,BUFFSIZE
					bge s3, t0, escribirEnArchivo1
		            la t0, buffer				#cargamos adres de buffer a escribir
		           
		            addu t0, t0, s3
		           
		            la t9, escribirEndLine
					b print_uinteger			#sb s2, 0(t0)			#guardamos c en buffer
											#b escribirEndLine
											
					
					
					
escribirEnArchivo1:	li v0, SYS_write			#write syscal value
                    lw a0, O_FD($fp)
                    la a1, buffer
                    move a2, s3
                    
                    la t0, terminator
                    lb t0, 0(t0)
                    addu t1, a1, s3
                    sb t0, 0(t1)
                    
                    syscall
                    
                    blt v0, zero, mostrarError
					move s3, zero
					la t1, buffer
                    
                    la t0, terminator
                    lb t0, 0(t0)
                    addu t1, t1, s3
                    sb t0, 0(t1)
					
                    b salirLoopC
					
escribirEndLine:	li t0,BUFFSIZE
					bge s3, t0, escribirEnArchivo2
					la t0, buffer				
					la t4, endline
					lb t4, 0(t4)
				    addu t0, t0, s3
		            sb t4, 0(t0)			
		            addiu s3, s3, 1
					b incrementoLoopX
					
escribirEnArchivo2:	li v0, SYS_write			#write syscal value
                    lw a0, O_FD($fp)
                    la a1, buffer
                    
                    la t0, terminator
                    lb t0, 0(t0)
                    addu t1, a1, s3
                    sb t0, 0(t1)
                    move a2, s3
                    
                    
                    syscall
					
                    blt v0, zero, mostrarError
                    
                    la t1, buffer
                    
                    la t0, terminator
                    lb t0, 0(t0)
                    addu t1, t1, s3
                    sb t0, 0(t1)
                    
                    
					move s3, zero
					
					
					
                    b escribirEndLine
					
incrementoLoopX:  	addiu s1, s1, 1
	                l.s $f0, 16(s6)
	                add.s $f14, $f14, $f0
	                b loopX

salirLoopX: 		addiu s0, s0, 1
					l.s $f0, 20(s6)
					sub.s $f16, $f16, $f0
					b loopY

#el flush y cerrar programa, stack frame y listo


salirLoopY:         beqz s3, salir
					li v0, SYS_write			#write syscal value
                    lw a0, O_FD($fp)
                    la a1, buffer
                    
                    la t0, terminator
                    lb t0, 0(t0)
                    addu t1, a1, s3
                    sb t0, 0(t1)
                    
                    move a2, s3 
                    syscall
                    
                    blt v0, zero, mostrarError
					li v0, 0

salir:              lw gp, O_GP($fp)
                    lw $fp, O_FP($fp)
                    addiu sp,sp, 68
                    jr ra

mostrarError: 		li v0, SYS_write   #write syscal
		            li a0, 2			#stderrr file descriptor
		            la a1, TextoError
		            li a2, 10				#cantidad de bytes a ecribir. largo de cadena de texto
		            syscall
		            lw gp, O_GP(sp)
                    move $fp, sp
		            li v0, -1
		            b salir
		            
		            
		          
		            
		 	




print_uinteger:		li t0, 10
					li t7,10
					
					move t1,s2
					li t6, 1
					
					
calculoOrden:		divu t1,s2,t7
					blt t1,t6, finCalculo
					mul t7,t7,10
					b calculoOrden
					
finCalculo:			divu t7,t7,10
loopImpresion:		blt t7, t6, fin
					divu t1, s2, t7
					la t2, numbers
					addu t2,t2,t1
					lb	t1, 0(t2)
					
		            la t3 , buffer
					addu t3,t3,s3
					sb 	t1, 0(t3)
					addiu s3,s3,1
					
					remu s2,s2,t7
					
					divu t7,t7,10
					
					b loopImpresion
							
fin:				jr t9

