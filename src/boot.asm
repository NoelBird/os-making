%include "src/init.inc"

[org 0]
    jmp 07C0h:start

start:
    mov ax, cs
    mov ds, ax
    mov es, ax

    mov ax, 0xB800
    mov es, ax
    mov di, 0
    mov ax, word [msgBack]
    mov cx, 0x7FF

paint:
    mov word [es:di], ax
    add di, 2
    dec cx
    jnz paint

read:
    mov ax, 0x1000          ; ES:BX = 1000:0000
    mov es, ax
    mov bx, 0

    mov ah, 2               ; 디스크에 있는 데이터를 es:bx 주소로
    mov al, 2               ; 2섹터를 읽을 것이라고 알림
    mov ch, 0               ; 0번째 실린더
    mov cl, 2               ; 2번째 섹터부터 읽기 시작합니다.
    mov dh, 0               ; Head=0
    mov dl, 0               ; Drive=0, A: 드라이브
    int 13h

    jc read; 에러가 나면 다시 함

    mov dx, 0x3F2   ; 플로피디스크 드라이브의
    xor al, al      ; 모터를 끈다.
    out dx, al

    jmp 0x1000:0000

msgBack db '.', 0x67

times 510-($-$$) db 0
dw 0AA55h