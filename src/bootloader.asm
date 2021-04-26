[org 0]
    jmp 07C0h:start

; cs, ds, es 세그먼트를 초기화
start:
    mov ax, cs;     BIOS에서 cs를 0, ip를 07c0으로 셋팅했음
    mov ds, ax
    mov es, ax
    
    mov ax, 0xB800
    mov es, ax  ; es에 비디오 메모리 영역을 넣음
    mov di, 0   ; destination index를 0으로 세팅
    mov ax, word [msgBack]
    mov cx, 0x7FF   ;2047

paint:  ; 화면 전부를 .으로 찍음
    mov word [es:di], ax
    add di, 2
    dec cx
    jnz paint


; int 0x13 어느 섹터로 부터 몇 개의 섹터를 읽어라
; PARAMETERS
; AH	02h
; AL	Sectors To Read Count
; CH	Cylinder
; CL	Sector
; DH	Head
; DL	Drive
; ES:BX	Buffer Address Pointer

; RESULTS
; CF	Set On Error, Clear If No Error
; AH	Return Code
; AL	Actual Sectors Read Count

; 램의 0x1000번지로 ax를 복사하는 루틴
read:
    mov ax, 0x1000  ; ES:BX = 1000:0000 ; 복사 목적지의 주소값
    mov es, ax
    mov bx, 0

    mov ah, 2   ; 디스크에 있는 데이터를 es:bx의 주소로
    mov al, 1   ; 1 섹터를 읽을 것이다; 플로피디스크의 한 섹터는 512byte
    mov ch, 0   ; 0번째 실린더
    mov cl, 2   ; 2번째 섹터부터 읽기 시작한다.
    mov dh, 0   ; Head=0
    mov dl, 0   ; Drive=0, A: 드라이브
    int 0x13    ; Read!

    jc read     ; 에러가 나면 다시 함; 에러 발생의 경우 flag 레지스터의 CF 플래그가 1로 세팅됨

    jmp 0x1000:0000 ; kernel.bin이 위치한 곳으로 점프한다.

msgBack db '.', 0x67

times 510-($-$$) db 0
dw 0AA55h
