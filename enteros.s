//==============================================================
// Autor: [Juan Carmona]
// Fecha: 9-Oct-2025
// Descripción: Imprimir los enteros del 9 al 43 (inclusive)
// Plataforma: Raspberry Pi 4 (ARMv8-A AArch64 – Raspberry Pi OS 64-bit)
// Compilar:  as -o print_range.o print_range.s && ld -o print_range print_range.o
// Ejecutar:  ./print_range
//==============================================================

.section .data
buffer: .space 16                 // espacio para convertir número en texto
newline: .asciz "\n"

.section .text
.global _start

_start:
    mov x19, #9                  // número inicial
    mov x20, #43                 // número final

loop:
    // convertir número en texto decimal
    mov x0, x19                  // x0 = número
    adr x1, buffer               // puntero a buffer
    bl int_to_ascii              // convierte x0 → string en buffer

    // imprimir número
    mov x8, #64                  // syscall write
    mov x0, #1                   // stdout
    adr x1, buffer               // puntero a buffer
    mov x2, x9                   // longitud devuelta por int_to_ascii
    svc #0

    // imprimir salto de línea
    mov x8, #64
    mov x0, #1
    adr x1, newline
    mov x2, #1
    svc #0

    add x19, x19, #1             // siguiente número
    cmp x19, x20
    ble loop

    // salir del programa
    mov x8, #93                  // syscall exit
    mov x0, #0
    svc #0


//--------------------------------------------------------------
// Subrutina: int_to_ascii
// Convierte el entero sin signo en x0 a ASCII y lo guarda en x1
// Devuelve en x9 la longitud del texto resultante
//--------------------------------------------------------------
int_to_ascii:
    mov x2, x1                   // apuntador inicial del buffer
    add x1, x1, #15              // apuntar al final del buffer
    mov w3, #0                   // contador de dígitos

convert_loop:
    mov x4, x0
    mov x5, #10
    udiv x0, x0, x5              // x0 = x0 / 10
    msub x6, x0, x5, x4          // x6 = resto (número % 10)
    add x6, x6, #'0'             // convertir a ASCII
    strb w6, [x1], #-1           // guardar byte y mover atrás
    add w3, w3, #1
    cbnz x0, convert_loop

    add x1, x1, #1               // mover a primer carácter del número
    mov x9, x3                   // longitud del texto
    mov x0, x2                   // (opcional) devolver dirección base
    ret

