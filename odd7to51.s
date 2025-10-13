//==============================================================
// Autor: Juan Carmona con ChatGPT Tutor ARM64
// Descripción: Imprimir los enteros impares del 7 al 51
// Plataforma: Raspberry Pi 4 / Ubuntu ARM64
// Compilar:  as -o impares.o impares.s && ld -o impares impares.o
// Ejecutar:  ./impares
//==============================================================

.section .data
buffer: .space 16
newline: .asciz "\n"

.section .text
.global _start

_start:
    mov x19, #7              // número inicial (impar)
    mov x20, #51             // número final

bucle:
    mov x0, x19              // número actual
    adr x1, buffer           // dirección del buffer
    bl int_to_ascii          // convierte número → texto
    // devuelve longitud en x9 y puntero correcto en x1

    // syscall write(1, buffer, longitud)
    mov x8, #64              // syscall write
    mov x0, #1               // stdout
    mov x2, x9               // longitud
    svc #0

    // imprimir salto de línea
    mov x8, #64
    mov x0, #1
    adr x1, newline
    mov x2, #1
    svc #0

    add x19, x19, #2         // siguiente número impar (+2)
    cmp x19, x20
    ble bucle                // mientras x19 <= x20

    // salir
    mov x8, #93
    mov x0, #0
    svc #0


//--------------------------------------------------------------
// int_to_ascii(x0 = número, x1 = buffer)
// Devuelve: x1 -> inicio del texto, x9 -> longitud
//--------------------------------------------------------------
int_to_ascii:
    add x1, x1, #15          // comenzar desde el final del buffer
    mov x9, #0               // contador de dígitos

convert_loop:
    mov x2, #10
    udiv x3, x0, x2          // x3 = número / 10
    msub x4, x3, x2, x0      // x4 = número - (x3*10)
    add x4, x4, #'0'         // convierte dígito a ASCII
    strb w4, [x1], #-1       // guarda carácter
    add x9, x9, #1
    mov x0, x3               // x0 = x0 / 10
    cbnz x0, convert_loop

    add x1, x1, #1           // retrocede al primer carácter
    ret
