;command:  nasm pmtest1.asm -o pmtest1.bin

;const,macro and some declare
%include  "pm.inc" 


org 07c00h
    jmp LABEL_BEGIN
[SECTION .gdt]
    
LABEL_GDT:          Descriptor  0   ,                  0   ,   0   ;empty descriptor
LABEL_DESC_CODE32:  Descriptor  0   ,  SegCode32Len -  1   ,   DA_C + DA_32 ;
LABEL_DESC_VIDEO:   Descriptor  0B800h, 0ffffh, DA_DRW  ;

;GDT End

GdtLen  equ $ - LABEL_GDT   ;length of GDT
GdtPtr  dw  GdtLen - 1      ;limit of GDT
        dd  0

;GDT selector

SelectorCode32  equ LABEL_DESC_CODE32   - LABEL_GDT
SelectorVideo   equ LABEL_DESC_VIDEO    - LABEL_GDT

;End of [SECTION .gdt]


[SECTION .s16]
[BITS   16]
LABEL_BEGIN:
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0100h

;initial 32 bit code descrptor

    xor eax,eax
    mov ax, ds
    shl eax,4
    add eax,LABEL_SEG_CODE32
    mov word [LABEL_DESC_CODE32 + 2],ax
    shr eax,16
    mov byte [LABEL_DESC_CODE32 + 4],al
    mov byte [LABEL_DESC_CODE32 + 7],ah
    
    lgdt [GdtLen]

    cli

    in  al,92h
    or  al,00000010b
    out 92h,al

    mov eax,cr0
    or  eax,1
    mov cr0,eax
    
    jmp dword SelectorCode32:0

;END of [SECTION .s16]

[SECTION .s32]  ;32 bit code segment  jmp into real pattern
[BITS 32]

LABEL_SEG_CODE32:

    mov ax,SelectorVideo
    mov gs,ax   ;vedio segment selector
    
    mov edi,(80*11+79)*2        ;11st row  ,79th column on screen
    mov ah,0ch
    mov al,'P'
    mov [gs:edi],ax

    jmp $

SegCode32Len equ $ - LABEL_SEG_CODE32
;END of [SECTION .s32]









