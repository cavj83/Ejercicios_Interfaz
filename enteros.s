//==============================================================
// Autor: ChatGPT Tutor ARM64
// Descripción: Imprimir los enteros del 9 al 43
// Plataforma: Raspberry Pi / Ubuntu ARM64
//==============================================================

.section .data
buffer: .space 16
newline: .asciz "\n"

.section .text
.global _start

_start:
    mov x19, #9          // número inicial
    mov x20, #43         // número final

loop:
    // convertir número en texto decimal
    mov x0, x19          // número actual
    adr x1, buffer       // dirección donde guardar texto
    bl int_to_ascii      // convierte número → string
    // salida: longitud en x9

    // syscall write(stdout, buffer, longitud)
    mov x8, #64
    mov x0, #1
    adr x1, buffer
    mov x2, x9
    svc #0

    // imprimir salto de línea
    mov x8, #64
    mov x0, #1
    adr x1, newline
    mov x2, #1
    svc #0

    add x19, x19, #1     // siguiente número
    cmp x19, x20
    ble loop              // mientras x19 <= x20

    // syscall exit(0)
    mov x8, #93
    mov x0, #0
    svc #0


//--------------------------------------------------------------
// Subrutina: int_to_ascii
// Convierte el entero sin signo en x0 a texto en x1
// Devuelve longitud en x9
//--------------------------------------------------------------
int_to_ascii:
    mov x2, x1
    add x1, x1, #15
    mov x3, #0

convert_loop:
    mov x4, x0
    mov x5, #10
    udiv x0, x0, x5          // x0 = x0 / 10
    msub x6, x0, x5, x4      // x6 = x4 - x0*10 → resto
    add x6, x6, #'0'         // convertir a ASCII
    strb w6, [x1], #-1       // guardar carácter
    add x3, x3, #1
    cbnz x0, convert_loop

    add x1, x1, #1
    mov x9, x3
    ret
