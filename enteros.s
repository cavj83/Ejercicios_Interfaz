.global _start

_start:
    mov x0, #9
    mov x1, #43

loop:
    // imprimir número actual
    mov x8, #64          // syscall write
    mov x2, #1           // longitud
    adr x3, num
    svc #0

    add x0, x0, #1
    cmp x0, x1
    ble loop

    mov x8, #93          // exit
    mov x0, #0
    svc #0

.data
num: .ascii "9\n"
