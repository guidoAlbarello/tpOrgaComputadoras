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
		    
.MACRO store_word
					sb t7, 3(t8)
					srl t7, t7, 8
					sb t7, 2(t8)
					srl t7, t7, 8
					sb t7, 1(t8)
					srl t7,t7, 8
					sb t7, 0(t8)
.ENDM

		            .data
		    
					.align 2
		    
buffer: .space BUFFSIZE
		             

header:         	.asciiz "P2\n"
endline:        	.asciiz   "\n"

TextoError: .asciiz "i/o error.\n" 
		             


					.text
				
				
					.globl mips32_plot
mips32_plot:   
		            #inicializacion stack frame
		            subu sp, sp, 64
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
					lw t0, 32(s6)
					lw t1, 36(s6)
					lw t2, 40(s6)
					la t6, header 
		            la t4, buffer				#cargamos adres de buffer a escribir
					lw t7, 0(t6)
		            sw t7, 0(t4)
		            
		            sw t0, 4(t4)
		            la t3, endline
					lw t3, 0(t3)
					sw t3, 8(t4)
					
		            sw t1, 12(t4)
					sw t3, 16(t4)
					
					sw t2, 20(t4)
					sw t3, 24(t4)
		            			

		            addiu s3, s3, 28
					
					li v0, SYS_write
					li a0, 1
					la a1, buffer
					li a2, 28
					syscall
		
		
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
		            l.s $f0, O_CR($fp)
		            s.s $f0, O_ZR($fp)
		            l.s $f0, O_CI($fp)
		            s.s $f0, O_ZI($fp)
		
		            sw zero, O_C($fp)
		            lw s2, O_C($fp)
		            lw s4, 40(s6)


loopC: 		  		bge s2,s4, salirLoopC
		            l.s $f0, O_ZR($fp)
		            l.s $f6, O_ZI($fp)
		            mul.s $f2, $f0, $f0
		            mul.s $f12, $f6, $f6
		            add.s $f4, $f0, $f6
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
		            
		            
		            
					sw s2, 0(t0)			#guardamos c en buffer
		            addiu s3, s3, 4
					b escribirEndLine
					
escribirEnArchivo1:	li v0, SYS_write			#write syscal value
                    lw a0, O_FD($fp)
                    la a1, buffer
                    move a2, s3
                    syscall
                    lw gp, O_GP(sp)
					move $fp, sp
                    blt v0, zero, mostrarError
					move s3, zero
                    b salirLoopC
					
escribirEndLine:	li t0,BUFFSIZE
					bge s3, t0, escribirEnArchivo2
					la t0, buffer				
					la t4, endline
					
				    addu t0, t0, s3
		            sw t4, 0(t0)			
		            addiu s3, s3, 4
					b incrementoLoopX
					
escribirEnArchivo2:	li v0, SYS_write			#write syscal value
                    lw a0, O_FD($fp)
                    la a1, buffer
                    move a2, s3
                    syscall
                    lw gp, O_GP(sp)
					move $fp, sp
					
                    blt v0, zero, mostrarError
					move s3, zero
                    b escribirEndLine
					
incrementoLoopX:  	addiu s1, s1, 1
	                l.s $f0, 16(s6)
	                add.s $f14, $f14, $f0
	                b loopX

salirLoopX: 		addiu s0, s0, 1
					l.s $f0, 20(s6)
					add.s $f16, $f16, $f0
					b loopY

#el flush y cerrar programa, stack frame y listo


salirLoopY:         beqz s3, salir
					li v0, SYS_write			#write syscal value
                    lw a0, O_FD($fp)
                    la a1, buffer
                    move a2, s3 #aca puede ir s3 o BUFFSIZE porq tecnicamente
                    #siempre entraria aca cuando elbufer se llena. pero por si
                    #acaso dejo s3 por si es la ultima escritura y no se llega a
                    #llenar el buffer. cualquer cosa si hay algun problema lo
                    #cambiamos
                    syscall
                    lw gp, O_GP(sp)
                    move $fp, sp
                    
                    blt v0, zero, mostrarError
					li v0, 0

salir:              lw gp, O_GP($fp)
                    lw $fp, O_FP($fp)
                    addiu sp,sp, 64
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
		            
