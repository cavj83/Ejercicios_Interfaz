// test_fpu.s
.global _start
_start:
    fmov d0, #1.0
    fmov d1, #2.0
    fadd d0, d0, d1
    mov  x8, #93
    mov  x0, #0
    svc  #0
