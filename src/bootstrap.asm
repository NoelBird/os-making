[org 0]             ; 메모리 내 초기 로딩 위치
[bits 16]           ; 타겟 프로세서의 모드를 지정 - https://www.nasm.us/xdoc/2.10.09/html/nasmdoc6.html
    jmp 0x07c0:start    ; far jump
; 레지스터 초기화
start:
    mov ax, cs          ; cs에는 0x07C0이 들어가 있습니다.
    mov ds, ax          ; ds를 cs와 같게 해줍니다.

    mov ax, 0xB800      ; 비디오 메모리의 세그먼트를
    mov es, ax          ; es 레지스터에 넣습니다.
    mov di, 0           ; 제일 윗줄의 처음에 쓸 것이라고 알림
    mov ax, word [msgBack]  ; 써야 할 데이터의 주소 값을 지정
    mov cx, 0x7FF       ; 화면 전체에 쓰기 위해서는
                        ; 0x7FF(10진수 2047)개의 WORD가 필요합니다.

paint:
    mov word [es:di], ax    ; 비디오 메모리에 씁니다.
    add di, 2               ; 한 WORD를 썼으므로 2를 더합니다.
    dec cx                  ; 한 WORD를 썼으므로 CX의 값을 하나 줄입니다.
    jnz paint               ; CX가 0이 아니면 paint로 점프하여 나머지를 더 씁니다.

    mov edi, 0              ; 제일 윗줄의 처음에 쓸 것이라고 지정
    mov byte [es:edi], 'A'  ; 비디오 메모리에 write
    inc edi                 ; 한 개의 BYTE를 썼으므로 1을 더합니다.
    mov byte [es:edi], 0x06 ; 배경색을 write
    inc edi                 ; 한 개의 BYTE를 썼으므로 1을 더합니다.
    mov byte [es:edi], 'B'
    inc edi
    mov byte [es:edi], 0x06
    inc edi
    mov byte [es:edi], 'C'
    inc edi
    mov byte [es:edi], 0x06
    inc edi
    mov byte [es:edi], '1'
    inc edi
    mov byte [es:edi], 0x06
    inc edi
    mov byte [es:edi], '2'
    inc edi
    mov byte [es:edi], 0x06
    inc edi
    mov byte [es:edi], '3'
    inc edi
    mov byte [es:edi], 0x06
    jmp $                       ; 이 번지에서 무한루프를 돕니다.

msgBack db '.', 0x67            ; 배경색으로 사용할 데이터

times 510-($-$$) db 0           ; 여기에서 509번지까지 0으로 채웁니다.
dw 0xAA55                       ; 510번지에 0x55를, 511번지에 0xAA를 넣어둡니다.
                                ; 0xAA55는 부팅 가능한 것을 알리는 역할을 합니다.
                                ; 0xAA55는 510~511번지에 들어 있어야 합니다.

; 다른 예시 코드
; entry:
;     mov ax, 0      ; ax 레지스터 초기화
;     mov ss, ax     ; ss 레지스터 초기화
;     mov ds, ax
;     mov es, ax
;     mov si, msg     ; si 레지스터에 msg 레이블 위치를 저장

; print:
;     mov al, [si]    ; al 레지스터에 si 번지 메모리 내용을 넣음
;     mov ah, 0x0e    ; ah 레지스터에 0x0e 넣음(한글자 출력 용도)
;     int 0x10        ; 화면에 한 글자를 출력하는 비디오 BIOS 명령

; msg:
;     db "A"          ; 출력할 문자

; jmp 0x1fe           ; 부트 섹터 끝자리 510번째 바이트로 점프