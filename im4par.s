//==============================================================
// Autor: Juan Carmona con ChatGPT Tutor ARM64
// Descripción: Introducir un número y determinar si es par o impar
// Plataforma: Raspberry Pi 4 / Ubuntu ARM64
// Compilar:  as -o parimpar.o Ejercicios_interfaz/parimpar.s && ld -o parimpar parimpar.o
// Ejecutar:  ./parimpar
//==============================================================

.section .data
msg_ingreso: .asciz "Introduce un número: "
msg_par:     .asciz "El número es PAR\n"
msg_impar:   .asciz "El número es IMPAR\n"
buffer:      .space 32

.section .text
.global _start

_start:
    //----------------------------------------------------------
    // Mostrar mensaje de entrada
    //----------------------------------------------------------
    mov x8, #64              // syscall write
    mov x0, #1               // stdout
    adr x1, msg_ingreso
    mov x2, #20              // longitud
    svc #0

    //----------------------------------------------------------
    // Leer número desde teclado
    //----------------------------------------------------------
    mov x8, #63              // syscall read
    mov x0, #0               // stdin
    adr x1, buffer           // destino
    mov x2, #32              // bytes a leer
    svc #0

    //----------------------------------------------------------
    // Convertir cadena ASCII -> número (x19)
    //----------------------------------------------------------
    adr x1, buffer
    mov x19, #0

convert_loop:
    ldrb w2, [x1], #1
    cmp w2, #10              // '\n'
    beq end_convert
    sub w2, w2, #'0'
    mul x19, x19, #10
    add x19, x19, x2
    b convert_loop

end_convert:
    //----------------------------------------------------------
    // Determinar si es par o impar
    //----------------------------------------------------------
    and x0, x19, #1          // bit menos significativo
    cbz x0, es_par           // si 0 -> par

es_impar:
    mov x8, #64
    mov x0, #1
    adr x1, msg_impar
    mov x2, #20
    svc #0
    b salir

es_par:
    mov x8, #64
    mov x0, #1
    adr x1, msg_par
    mov x2, #17
    svc #0

salir:
    mov x8, #93
    mov x0, #0
    svc #0
