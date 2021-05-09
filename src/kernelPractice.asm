[org 0]
[bits 16]

start:
    mov ax, cs  ; CS에는 0x1000이 들어 있다.
    mov ds, ax
    xor ax, ax
    mov ss, ax  ; stack segment는 0으로 세팅

    lea esi, [msgKernel]    ; 문자열이 있는 곳의 주소를 구함
    mov ax, 0xB800
    mov es, ax              ; es에 0xB800을 넣는다
    mov edi, 0              ; 화면의 제일 처음 부분부터 시작할 것이다.
    call printf
    jmp $

printf:
    push eax                ; 먼저 있던 eax 값을 스택에 보존해 놓는다.

printf_loop:
    mov al, byte [esi]      ; esi가 가리키는 주소에서 문자를 하나 가져온다.
    mov byte [es:edi], al   ; 문자를 화면에 나타낸다.
    or al, al               ; al이 0인지를 알아본다.
    jz printf_end           ; 0이라면 print_end로 점프한다.
    inc edi                 ; 0이 아니라면 edi를 1 증가시켜
    mov byte [es:edi], 0x06 ; 문자색과 배경색의 값을 넣는다.
    inc esi                 ; 다음 문자를 꺼내기 위해 esi를 하나 증가시킨다.
    inc edi                 ; 화면에 다음 문자를 나타내기 위해 edi를 증가시킨다.
    jmp printf_loop         ; 루프를 돈다.

printf_end:
    pop eax                 ; 스택에 보존했던 eax를 다시 꺼낸다.
    ret                     ; 호출한 부분으로 돌아간다.

msgKernel db "We are in kernel program", 0
