[org 0]
[bits 16]

start:
    mov ax, cs              ; CS에는 0x1000이 들어 있습니다.
    mov ds, ax

    xor ax, ax
    mov ss, ax

    cli                     ; EFLAGS 레지스터의 IF(interrupt flag)를 0으로 clear <=> sti: IF비트를 1로 set. inturrupt 활성화

    lgdt[gdtr]              ; gdtr 포인터에 따라서 gdt를 등록시키는 명령어

    mov eax, cr0
    or eax, 0x00000001
    mov cr0, eax

    jmp $+2                 ; 왜 이부분에서 jmp $+2 를 하지..? nop을 2개 쓰고..?
    nop
    nop
    db 0x66                 ; 0x66, 0x67, 0xEA는 잘 gdt가 등록 되었다는 의미인지..?
    db 0x67
    db 0xEA
    dd PM_Start             ; 여기로 점프..?
    dw SysCodeSelector      ; 이 GDT를 사용해서....?

;--------------------------------------------;
;********* 여기부터 Protected Mode입니다. ****;
;--------------------------------------------;
[bits 32]

PM_Start:
    mov bx, SysDataSelector
    mov ds, bx
    mov es, bx
    mov fs, bx
    mov gs, bx
    mov ss, bx

    xor eax, eax
    mov ax, VideoSelector
    mov es, ax
    mov edi, 80*2*10+2*10
    lea esi, [ds:msgPMode]
    call printf

    jmp $

;--------------------------------------------;
;************** Sub Routines ****************;
;--------------------------------------------;
printf:
    push eax

printf_loop:
    or al, al
    jz printf_end
    mov al, byte [esi]
    mov byte [es:edi], al
    inc edi
    mov byte [es:edi], 0x06
    inc esi
    inc edi
    jmp printf_loop

printf_end:
    pop eax
    ret

msgPMode db "We are in Protected Mode", 0

;-----------------------------------------;
;************** GDT Table ****************;
;-----------------------------------------;
gdtr:
    dw gdt_end - gdt - 1    ; GDT의 limit
    dd gdt+0x010000          ; GDT의 베이스 어드레스(물리주소)
                            ; [org 0] 가 첫 줄에 있는데, 그것 때문에 0을 기준으로 이 어셈블리 파일 내의 메모리 계산을 함.
                            ; 실제로 진행하고 있는 물리 메모리 주소는 0x010000 이기 때문에 그 값을 더해줌

gdt:
    dw 0                    ; limit 0 ~ 15비트
    dw 0                    ; 베이스 어드레스의 하위 두 바이트
    db 0                    ; 베이스 어드레스 16~32비트
    db 0                    ; 타입
    db 0                    ; limit 16~19비트, 플래그
    db 0                    ; 베이스 어드레스 32~24비트

; 코드 세그먼트 디스크립터
SysCodeSelector equ 0x08    ; 세그먼트 셀렉터에 들어갈 값(디스크립터를 찾기 위한 인덱스 + TI + RPL)
    dw 0xFFFF               ; limit:0xFFFF
    dw 0x0000               ; base 0~15bit
    db 0x01                 ; base 16~32bit
    db 0x9A                 ; P:1, DPL:0, Code, non-conforming, readable
    db 0xCF                 ; G:1, D:1, limit 16~19 bit:0xF
    db 0x00                 ; base 24~32 bit

; 데이터 세그먼트 디스크립터
SysDataSelector equ 0x10    ; 세그먼트 셀렉터에 들어갈 값(디스크립터를 찾기 위한 인덱스 + TI + RPL)
    dw 0xFFFF               ; limit 0xFFFF
    dw 0x0000               ; base 0~15 bit
    db 0x01                 ; base 16~23 bit
    db 0x92                 ; P:1, DPL: 0, data, expand-up, writable
    db 0xCF                 ; G:1, D:1, limit 16~19 bit:0xF
    db 0x00                 ; base 24~32 bit

; 비디오 세그먼트 디스크립터
VideoSelector equ 0x18      ; 세그먼트 셀렉터에 들어갈 값(디스크립터를 찾기 위한 인덱스 + TI + RPL)
    dw 0xFFFF               ; limit 0xFFFF
    dw 0x8000               ; base 0~15 bit
    db 0x0B                 ; base 16~23 bit
    db 0x92                 ; P:1, DPL:0, data, expand-up, writable
    db 0x40                 ; G:0, D:1, limit 16~19 bit:0
    db 0x00                 ; base 24~32 bit
gdt_end: