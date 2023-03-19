[org 0x100]

jmp start

;===========================================================================
OVER1: db ' _____   ___  ___  ___ _____   _____  _   _ ___________ ',0
OVER2: db '|  __ \ / _ \ |  \/  ||  ___| |  _  || | | |  ___| ___ \',0
OVER3: db '| |  \// /\ \| .  . || |_   | | | || | | | |__ | |_/ /',0
OVER4: db '| | __ |  _  || |\/| ||  __|  | | | || | | |  __||    / ',0
OVER5: db '| |\ \| | | || |  | || |__  \ \_/ /\ \_/ / |___| |\ \ ',0
OVER6: db ' \____/\_| |_/\_|  |_/\____/   \___/  \___/\____/\_| \_|',0
name: db 'CATCH IT!',0
inst1: db '                         COLLECT PLUS SIGNS IN ',0
inst3:db'                      GAME ENDS AFTER 120 SECONDS',0
inst2: db '                      OR IF YOU BUMP INTO  ',0
msg1: db 'GREEN PLUS - 5 POINTS', 0
msg2: db 'BLUE PLUS - 10 POINTS', 0
msg3: db 'PURPLE PLUS - 15 POINTS', 0
msg4: db 'PRESS ENTER TO CONTINUE',0
msg5: db 'Time:   s',0
msg6: db 'Score: ',0
msg7: db '        RESULTS ',0
msg8: db '    GREEN  SIGNS: ',0
msg9: db '    BLUE   SIGNS: ',0
msg10: db '    PURPLE SIGNS: ',0
msg11: db '    TOTAL SCORE: ',0
msg12: db'   PRESS ANY KEY TO CONTINUE',0
msg13:db'       PRESS r TO RESTART',0
msg14:db'SELECT BUCKET COLOUR                                                                By default black',0
;msg15:db''
msg16:db'Press p for purple                                                                    o for orange                                                                    r for red                                                                       c for cyan                                                                      b for blue                                                                      g for green',0
msg17:db'SELECT DIFFICULTY',0
msg18:db'Press e for easy                                                                Press n for normal                                                              Press d for difficulty     ',0
bucketcolour: dB 00000000b
oldisr: dd 0
tickcount: dw 0
seconds: dw 0
bCount: db 0
gCount: db 0
pCount: db 0
score: dw 0
loopvalue1: db 0x1F
loopvalue2: db 0x17
loopvalue3: db 0x11
delayvalue: dw 0xffff
;===========================================================================
; subroutine to print a string
; takes the x position, y position, attribute, and address of a null
; terminated string as parameters
printstr: 	push bp
			mov bp, sp
			push es
			push ax
			push cx
			push si
			push di
			push ds ; push segment of string
			mov ax, [bp+4]
			push ax ; push offset of string
			call strlen ; calculate string length
			cmp ax, 0 ; is the string empty
			jz exit ; no printing if string is empty
			mov cx, ax ; save length in cx
			mov ax, 0xb800
			mov es, ax ; point es to video base
			mov al, 80 ; load al with columns per row
			mul byte [bp+8] ; multiply with y position
			add ax, [bp+10] ; add x position
			shl ax, 1 ; turn into byte offset
			mov di,ax ; point di to required location
			mov si, [bp+4] ; point si to string
			mov ah, [bp+6] ; load attribute in ah
			cld ; auto increment mode

			nextchar:	lodsb ; load next char in al
						stosw ; print char/attribute pair
						loop nextchar ; repeat for the whole string

			exit:		pop di
						pop si
						pop cx
						pop ax
						pop es
						pop bp
						ret 8
;===========================================================================
; subroutine to set the background colour
setbckgrnd: push es
			push ax
			push cx
			push di
			mov ax, 0xb800
			mov es, ax ; point es to video base
			xor di, di ; point di to top left column
			mov al,20h;space character
			mov ah,01110000b;light gray background
			mov cx, 2000 ; number of screen locations
			cld ; auto increment mode
			rep stosw ; clear the whole screen
			pop di
			pop cx
			pop ax
			pop es
			ret
;===========================================================================
; subroutine to calculate the length of a string
; takes the segment and offset of a string as parameters
strlen:		push bp
			mov bp,sp
			push es
			push cx
			push di
			les di, [bp+4] ; point es:di to string
			mov cx, 0xffff ; load maximum number in cx
			xor al, al ; load a zero in al
			repne scasb ; find zero in the string
			mov ax, 0xffff ; load maximum number in ax
			sub ax, cx ; find change in cx
			dec ax ; exclude null from length
			pop di
			pop cx
			pop es
			pop bp
			ret 4
;===========================================================================
;subroutine to draw falling object
;takes the x position, y position and a number indicating which object
FallObj:	push bp
			mov bp, sp
			push es
			push ax
			push di
			mov ax, 0xb800
			mov es, ax ; point es to video base
			mov al, 80 ; load al with columns per row
			mul byte [bp+4] ; multiply with y position
			add ax, [bp+6] ; add x position
			shl ax, 1 ; turn into byte offset
			mov di,ax ; point di to required location

			mov ax,[bp+8]
			cmp ax,1
			je green
			cmp ax,2
			je blue
			cmp ax,3
			je purple
			jmp cross
		green:	mov al,20h; space character
				mov ah,00100000b; green background for plus sign
				jmp contFallObj

		blue:	mov al,20h; space character
				mov ah,00010000b; blue background for plus sign
				jmp contFallObj

		purple: mov al,20h;space character
				mov ah,01010000b;purple background for plus sign
				jmp contFallObj

		contFallObj:mov word [es:di],ax ; set space colour

					add di,160 ; move 1 space down 
					mov word [es:di],ax ; set space colour

					sub di,2 ; move 1 space left 
					mov word [es:di],ax ; set space colour

					add di,4 ; move 2 space right 
					mov word [es:di],ax ; set space colour

					sub di,2 ; move 1 space left 
					add di,160 ; move one space down
					mov word [es:di],ax ; set space colour
					jmp FallObjEnd
		cross:		mov al,20h;space character
					mov ah,01000000b;red background for cross

					mov word [es:di],ax ; set space colour

					add di,4 ; move 2 space right 
					mov word [es:di],ax ; set space colour

					add di,320 ; move 2 space down 
					mov word [es:di],ax ; set space colour

					sub di,4 ; move 2 space left
					mov word [es:di],ax ; set space colour

					add di,2 ; move 1 space right 
					sub di,160 ; move 1 space up
					mov word [es:di],ax ; set space colour
		FallObjEnd:	pop di
					pop ax
					pop es
					pop bp

					ret 6
;===========================================================================
;subroutine to draw brown bucket
;takes the x position and y position
bucket:		push bp
			mov bp, sp
			push es
			push ax
			push di
			mov ax, 0xb800
			mov es, ax ; point es to video base
			mov al, 80 ; load al with columns per row
			mul byte [bp+4] ; multiply with y position
			add ax, [bp+6] ; add x position
			shl ax, 1 ; turn into byte offset
			mov di,ax ; point di to required location
			
			mov al,20h;space character
			mov ah,[bp+8];brown background for bucket

			mov word [es:di],ax ; set space colour

			add di,160 ; move 1 space down 
			mov word [es:di],ax ; set space colour

			add di,160 ; move 1 space down 
			mov word [es:di],ax ; set space colour

			add di,2 ; move 1 space right 
			mov word [es:di],ax ; set space colour

			add di,2 ; move 1 space right 
			mov word [es:di],ax ; set space colour

			add di,2 ; move 1 space right 
			mov word [es:di],ax ; set space colour

			add di,2 ; move 1 space right 
			mov word [es:di],ax ; set space colour

			sub di,160 ; move 1 space up
			mov word [es:di],ax ; set space colour

			sub di,160 ; move 1 space up
			mov word [es:di],ax ; set space colour

			pop di
			pop ax
			pop es
			pop bp

			ret 6					
;===========================================================================
startscreen:mov ch, 32 	;hide
 			mov ah, 1 	;the
 			int 10h		;cursor

			mov ah, 0x10 ; service 10 – vga attributes
			mov al, 03 ; subservice 3 – toggle blinking
			mov bl, 01 ; enable blinking bit
			int 0x10 ; call BIOS video service
			call setbckgrnd ; set the background colour

			mov ax, 35
			push ax ; push x position
			mov ax, 0
			push ax ; push y position
			mov ax, 01110000b ; black text on light gray background
			push ax ; push attribute
			mov ax, name
			push ax ; push offset of string
			call printstr ; print the string

			mov ax, 0
			push ax ; push x position
			mov ax, 3
			push ax ; push y position
			mov ax, 01110100b ; red text on light gray background
			push ax ; push attribute
			mov ax, inst1
			push ax ; push offset of string
			call printstr ; print the string
			push ds ; push string segment
			push ax ; push offset of string
			call strlen	; get string length
			
			push word[bucketcolour]
			add ax,3
			push ax

			mov ax,1
			push ax
			call bucket

			mov ax, 1
			push ax ; push x position
			mov ax, 6
			push ax ; push y position
			mov ax, 01110100b ; red text on light gray background
			push ax ; push attribute
			mov ax, inst3
			push ax ; push offset of string
			call printstr ; print the string
			push ds ; push string segment
			push ax ; push offset of string
			call strlen	; get string length
			


			push 4 ; number for cross
			add ax,3
			push ax
			mov ax,5
			push ax
			call FallObj

			mov ax, 5
			push ax ; push x position
			mov ax, 7
			push ax ; push y position
			mov ax, 01110100b ; red text on light gray background
			push ax ; push attribute
			mov ax, inst2
			push ax ; push offset of string
			call printstr ; print the string
			push ds ; push string segment
			push ax ; push offset of string
			call strlen	; get string length


			mov ax, 25
			push ax ; push x position
			mov ax, 10
			push ax ; push y position
			mov ax, 01110100b ; red text on light gray background
			push ax ; push attribute
			mov ax, msg1
			push ax ; push offset of string
			call printstr ; print the string
			push ds ; push string segment
			push ax ; push offset of string
			call strlen	; get string length
			push 1 ; number for green plus sign
			add ax,32 ; set x position for plus sign
			push ax
			mov ax, 9 ; set y position for plus sign
			push ax
			call FallObj ; set plus sign
			
			mov ax, 25
			push ax ; push x position
			mov ax, 14
			push ax ; push y position
			mov ax, 01110100b ; red text on light gray background
			push ax ; push attribute
			mov ax, msg2
			push ax ; push offset of string
			call printstr ; print the string
			push ds ; push string segment
			push ax ; push offset of string
			call strlen	; get string length
			push 2 ; number for blue plus sign
			add ax,32 ; set x position for plus sign
			push ax
			mov ax, 13 ; set y position for plus sign
			push ax
			call FallObj ; set plus sign
			
			mov ax, 25
			push ax ; push x position
			mov ax, 18
			push ax ; push y position
			mov ax, 01110100b ; red text on light gray background
			push ax ; push attribute
			mov ax, msg3
			push ax ; push offset of string
			call printstr ; print the string
			push ds ; push string segment
			push ax ; push offset of string
			call strlen	; get string length
			push 3 ; number for purple plus sign
			add ax,30 ; set x position for plus sign
			push ax
			mov ax, 17 ; set y position for plus sign
			push ax
			call FallObj ; set plus sign

			mov ax, 25
			push ax ; push x position
			mov ax, 22
			push ax ; push y position
			mov ax, 11110100b ; red text on light gray background
			push ax ; push attribute
			mov ax, msg4
			push ax ; push offset of string
			call printstr ; print the string

				waitEnter:	call ReadChar
							cmp ah,28 ; check if key pressed was enter
							jne waitEnter ; go back until enter is pressed
			ret
;===========================================================================
;subroutine to read a character, returns scancode of character in ah
ReadChar:	mov ah, 0 ; service 0 – get keystroke
			int 0x16 ; call BIOS keyboard service
			ret
;===========================================================================
; timer interrupt service routine
timer: 		push ax
			push bx
			push cx
			push dx
			push si
			push di
			push es
			push ds
			pushf
 
 			inc word [cs:tickcount] ; increment tick count			
 			mov ax, [cs:tickcount]
 			mov bl, 18
 			div bl
 			xor ah,ah 
 			mov [cs:seconds], ax

	 		mov al, 0x20
			out 0x20, al ; end of interrupt 

			popf
 			pop ds
 			pop es
 			pop di
 			pop si
 			pop dx
 			pop cx
 			pop bx
 			pop ax
 			iret
;===========================================================================
;takes x position, y position, attribute and number to print
printnum:	push bp
			mov bp, sp
			push es
			push ax
			push cx
			push si
			push di
			push bx
			push dx
			
			mov ax, 0xb800
			mov es, ax ; point es to video base
			mov al, 80 ; load al with columns per row
			mul byte [bp+8] ; multiply with y position
			add ax, [bp+10] ; add x position
			shl ax, 1 ; turn into byte offset
			mov di,ax ; point di to required location
			
			
			cld ; auto increment mode

			mov ax, [bp+4] ; load number in ax
			mov bx, 10 ; use base 10 for division
			mov cx, 0 ; initialize count of digits
			
			nextdigit: 	mov dx, 0 ; zero upper half of dividend
						div bx ; divide by 10
						add dl, 0x30 ; convert digit into ascii value
						push dx ; save ascii value on stack
						inc cx ; increment count of values
						cmp ax, 0 ; is the quotient zero
						jnz nextdigit ; if no divide it again
						
			
			nextpos: 	pop dx ; remove a digit from the stack
						mov dh,[bp+6] ; load attribute in dh
						mov [es:di], dx ; print char on screen
						add di, 2 ; move to next screen location
						loop nextpos ; repeat for all digits on stack

			exitprintN:	pop dx
						pop bx
						pop di
						pop si
						pop cx
						pop ax
						pop es
						pop bp
						ret 8
;===========================================================================
;prints borders of main screen
borders:	push bp
			mov bp, sp
			push es
			push ax
			push di
			push si
			mov ax, 0xb800
			mov es,ax

			mov ax, 0
			push ax ; push x position
			mov ax, 0
			push ax ; push y position
			mov ax, 01110001b ; black text on light gray background
			push ax ; push attribute
			mov ax, msg5 ; print time
			push ax ; push offset of string
			call printstr ; print the string

			mov ax, 68
			push ax ; push x position
			mov ax, 0
			push ax ; push y position
			mov ax, 01110001b ; black text on light gray background
			push ax ; push attribute
			mov ax, msg6 ; print score
			push ax ; push offset of string
			call printstr ; print the string

			mov si,360
			mov ah,00010011b
			;mov ah,6
			mov al,20h
			always:
			mov word[es:si],ax
			add si,80
			mov word[es:si],ax
			add si,80
			cmp si,3500
			jbe always
			pop si
			pop di
			pop ax
			pop es
			pop bp
			ret
;===========================================================================
;subroutine to get cursor position, DL=x, DH=y
get_cursor:	push ax
			push bx
			mov bh,0 	
			mov ah,3 	
			int 10h
			pop bx
			pop ax 	
			ret
;===========================================================================
;subroutine to set cursor position, DL=x, DH=y
set_cursor:	mov  ah, 2                  ;◄■■ SERVICE TO SET CURSOR POSITION.
     		mov  bh, 0                  ;◄■■ VIDEO PAGE.
      		int  10h                    ;◄■■ BIOS SERVICES.
      		ret
;===========================================================================
rand1:	push ax
		push bx
		push cx

 	    mov  ax, [cs:tickcount]
 	    xor  dx, dx
	    mov  cx, 4    
	    div  cx  ; here dx contains the remainder of the division - from 0 to 3
	    pop cx
	    pop bx
	    pop ax
	    ret
;===========================================================================
rand2:	push ax
		push bx
		push cx
		
 	    mov  ax, [cs:tickcount]
 	    mov dl,3
 	    mul dl
 	    xor  dx, dx
	    mov  cx, 36   
	    div  cx       ; here dx contains the remainder of the division - from 0 to 35
	    add dx,23
	    pop cx
	    pop bx
	    pop ax
	    ret
;===========================================================================
;subroutine to scroll part of screen within borders
scrolldown:
           push bp
			mov bp, sp
			push es
			push ax
			push di
			push si
			push dx
			push cx
			push ds

			mov ax, 0xb800
			mov es,ax
			
			mov ds,ax
			mov si,3798
			mov di,3958

			loop12:
					mov cx,38
					std
					rep movsw
					sub si,84
					sub di,84
					cmp di,118
					jne loop12

					mov cx,38
					mov ah,01110000b
					mov al,20h

					rep stosw 
					pop ds
					pop cx
					pop dx
					pop si
					pop di
					pop ax
					pop es
					pop bp
					ret
;===========================================================================
bucketpredifned:
		push ax
		push bx
		push dx
		               call get_cursor
						xor bx,bx	
						mov bl, BYTE[bucketcolour]	;push colour
						push bx
						mov bl,dl 		;push x position
						push bx		
						mov bl,dh 		;push y position
						push bx
						call bucket
						pop dx
						pop bx
						pop ax
						ret
;===========================================================================
clear3:
		push ax
		push cx
		push es
		push di
        mov ax,0xb800
		mov es,ax
        mov cx,38
		mov ah,01110000b
		mov al,20h
		mov di,3402
		
		cld

		lc1:
					rep stosw 
					sub di,236
					cmp di,2922
					mov cx,38
					jne lc1

					pop di
					pop es
					pop cx
					pop ax
					ret
exitf:
	jmp far [cs:exitMain]
times12:
	call timesecond
	jmp rets
;===========================================================================
MainScreen:	push dx
			push bx
			push cx
			push ax
			push es
			push ds
			push di

			mov ah, 0x10 ; service 10 – vga attributes
			mov al, 03 ; subservice 3 – toggle blinking
			mov bl, 01 ; enable blinking bit
			int 0x10 ; call BIOS video service
			
			mov dh, 22
			mov dl,37
			call set_cursor
			call setbckgrnd
			call borders
			call get_cursor
            mov bl, byte[bucketcolour]	;push colour
			push bx
			mov bl,dl 		;push x position
			push bx		
			mov bl,dh 		;push y position
			push bx
			call bucket

			mainLoop:	cmp word [cs:seconds],120
						ja exitMain
						cmp word[cs:seconds],100
						je times12
			rets:
						mov ax,6
						push ax
						xor ax,ax
						push ax
						mov al, 01110001b ; black text on light gray background
						push ax ; push attribute
						mov ax, [cs:seconds]
			 			push ax ; push number to print
			 			call printnum ; print seconds

			 			call get_cursor
			 			mov ax, 0xb800
						mov es, ax ; point es to video base
						mov al, 80 ; load al with columns per row
						dec dh
						mul byte dh ; multiply with y position
						xor dh,dh
						add ax, dx ; add x position
						shl ax, 1 ; turn into byte offset
						mov di,ax ; point di to required location
						
						mov ax,0x7020 ; space with grey attribute

						mov cx,5

				chLoop:	cmp [es:di], ax ; 
						jne objType
						
						add di,2
						loop chLoop
						jmp exitCatch

				objType:cmp word [es:di],0x2020
						je pointG
						cmp word [es:di],0x1020
						je pointB
						cmp word [es:di],0x5020
						je pointP
						cmp word [es:di],0x4020
						je exitMain
						jmp exitCatch
				

				pointG:
						call clear3
						add word [cs:score], 5
						inc byte [cs:gCount]
						jmp exitCatch

				pointB:
						call clear3
						add word [cs:score], 10
						inc byte [cs:bCount]
						jmp exitCatch

				pointP:
						call clear3
						add word [cs:score], 15
						inc byte [cs:pCount]
						jmp exitCatch

				exitCatch:
			 			mov ax,75
						push ax
						xor ax,ax
						push ax
						mov al, 01110001b ; black text on light gray background
						push ax ; push attribute
						mov ax, [cs:score]
			 			push ax ; push number to print
			 			call printnum ; print seconds

						mov bl,[cs:loopvalue1]
			            sub bl,1
						mov byte[cs:loopvalue1],bl
						cmp bl,0
						jbe obj1
						mov bl,[cs:loopvalue2]
			            sub bl,1
						mov byte[cs:loopvalue2],bl
						cmp bl,0
						jbe obj2

						mov bl,[cs:loopvalue3]
			            sub bl,1
						mov byte[cs:loopvalue3],bl
						cmp bl,0
						jbe obj3

						jmp contmain

				obj1:	mov byte[cs:loopvalue1],0x1F
						cmp byte[cs:loopvalue2],3
						jbe contmain
						cmp byte[cs:loopvalue3],3
						jbe contmain
												
						call rand1
						push dx ; 
						call rand2
						push dx ; set x position for plus sign
						mov ax, 0 ; set y position for plus sign
						push ax
						call FallObj
						jmp contmain

				obj2:	mov byte[cs:loopvalue2],0x17
						cmp byte[cs:loopvalue1],3
						jbe contmain
						cmp byte[cs:loopvalue3],3
						jbe contmain

						call rand1
						push dx ; 
						call rand2
						push dx ; set x position for plus sign
						mov ax, 0 ; set y position for plus sign
						push ax
						call FallObj
						jmp contmain

				obj3:	mov byte[cs:loopvalue3],0x11
						cmp byte[cs:loopvalue1],3
						jbe contmain
						cmp byte[cs:loopvalue2],3
						jbe contmain
						
						call rand1
						push dx ; 
						call rand2
						push dx ; set x position for plus sign
						mov ax, 0 ; set y position for plus sign
						push ax
						call FallObj

			contmain:	call get_cursor
						xor bx,bx	
						mov bx, word[bucketcolour]	;push colour
						push bx
						mov bl,dl 		;push x position
						push bx		
						mov bl,dh 		;push y position
						push bx
						call bucket
						in al,0x60
						cmp al, 0x4b
						je moveLeft
						cmp al, 0x4d
						je moveRight
						cmp al, 01
						je exitm
						call _delay
						call scrolldown
						call bucketpredifned
						mov al, 0x20
						out 0x20,al

						jmp mainLoop

			moveRight:	call get_cursor
						call _delay
						cmp dl,56
						je endright
						xor bx,bx
						push 01110000b;push colour
						mov bl,dl 	;push x position
						push bx		;push y position
						mov bl,dh
						push bx
						inc dl	;increment column
						call set_cursor
						call bucket

						

			endright:		
						call scrolldown
						call bucketpredifned
						mov al, 0x20
						out 0x20,al
						jmp mainLoop
			exitm:
			jmp exitMain

			moveLeft:	call get_cursor
						call _delay
						cmp dl,20
						je endleft
						xor bx,bx
						push 01110000b; push colour
						mov bl,dl 	;push x position
						push bx		;push y position
						mov bl,dh
						push bx
						dec dl	;decrement column
						call set_cursor
						call bucket

						call get_cursor
						xor bx,bx	
						mov bl, byte[bucketcolour]	;push colour
						push bx
						mov bl,dl 		;push x position
						push bx		
						mov bl,dh 		;push y position
						push bx
						call bucket

			endleft:	
						call scrolldown
						call bucketpredifned
						mov al, 0x20
						out 0x20,al
						jmp mainLoop

						

			exitMain:	
			          
			            pop di
						pop ds
						pop es
						pop ax
						pop cx
						pop bx
						pop dx
						ret
;===========================================================================
_delay:			push dx
				mov dx, [delayvalue]	
	l1:			dec dx
				jnz l1
				pop dx
			ret
;===========================================================================
clearCatch:		mov ah, 01110000b
				mov word [es:di],ax
				sub di,160
				mov word [es:di],ax
				sub di,2
				mov word [es:di],ax
				add di,4
				mov word [es:di],ax
				sub di,162
				mov word [es:di],ax
				ret
;=====================================================================
rectan:
			push dx
			push bx
			push cx
			push ax
			push es
			push ds
			push di

			mov ax,0xb800
			mov es,ax
			mov si,678
			mov ah,00000000b
			mov al,20h

			recl1:
			mov word[es:si],ax
			add si,2
			cmp si,764
			jl recl1

			mov si,838
			mov di,920


			bord:
			mov word[es:si],ax
			mov word[es:si+2],ax
			add si,84
			mov word[es:si],ax
			mov word[es:si-2],ax
			add si,76
			cmp si,3130
			jl bord

			mov si,3238
			recl2:
			mov word[es:si],ax
			add si,2
			cmp si,3324
			jne recl2

			pop di
			pop ds
			pop es
			pop ax
			pop cx
			pop bx
			pop dx
			ret
;===========================================================================	
timesecond:
			push es
			push ax
			mov ax,0xb800
			mov es,ax
			mov ah,01110001b
			mov al,'s'
			mov word[es:20],ax
			pop ax
			pop es
			ret
;==============================================================================
selectdifi:

			
			push ax
			
			call setbckgrnd 
			mov ax, 30
			push ax ; push x position
			mov ax, 7
			push ax ; push y position
			mov ax, 01110000b ; red text on light gray background
			push ax ; push attribute
			mov ax, msg17
			push ax ; push offset of string
			call printstr ; print the string
			push ds ; push string segment
			push ax ; push offset of string
			call strlen	; get string length

			mov ax, 30
			push ax ; push x position
			mov ax, 10
			push ax ; push y position
			mov ax, 01110000b ; red text on light gray background
			push ax ; push attribute
			mov ax, msg18
			push ax ; push offset of string
			call printstr ; print the string
			push ds ; push string segment
			push ax ; push offset of string
			call strlen	; get string length


			;0x7fff 100 d
			;0xafff 110 n
			;0xffff 101 e
			l_until:
						mov ah,0
						int 16h

						cmp al,101
						je easy
						cmp al,110
						je normal
						cmp al,100
						je difficult

						jne l_until

			easy:
			            mov word[delayvalue],0xffff
						pop ax		
						ret
			difficult:
						mov word[delayvalue],0x7fff
			            pop ax		
						ret

			normal:
					mov word[delayvalue],0xafff
			        pop ax		
					ret
;===========================================================================
endScreen:	push dx
			push bx
			push cx
			push ax
			push es
			push ds
			push di

			call setbckgrnd ;
			

			mov ax, 10
			push ax ; push x position
			mov ax, 10
			push ax ; push y position
			mov ax, 01110100b ; red text on light gray background
			push ax ; push attribute
			mov ax, OVER1
			push ax ; push offset of string
			call printstr ; print the string


			mov ax, 10
			push ax ; push x position
			mov ax, 11
			push ax ; push y position
			mov ax, 01110100b ; red text on light gray background
			push ax ; push attribute
			mov ax, OVER2
			push ax ; push offset of string
			call printstr ; print the string


			mov ax, 10
			push ax ; push x position
			mov ax, 12
			push ax ; push y position
			mov ax, 01110100b ; red text on light gray background
			push ax ; push attribute
			mov ax, OVER3
			push ax ; push offset of string
			call printstr ; print the string


			mov ax, 10
			push ax ; push x position
			mov ax, 13
			push ax ; push y position
			mov ax, 01110100b ; red text on light gray background
			push ax ; push attribute
			mov ax, OVER4
			push ax ; push offset of string
			call printstr ; print the string



			mov ax, 10
			push ax ; push x position
			mov ax, 14
			push ax ; push y position
			mov ax, 01110100b ; red text on light gray background
			push ax ; push attribute
			mov ax, OVER5
			push ax ; push offset of string
			call printstr ; print the string


			mov ax, 10
			push ax ; push x position
			mov ax, 15
			push ax ; push y position
			mov ax, 01110100b ; red text on light gray background
			push ax ; push attribute
			mov ax, OVER6
			push ax ; push offset of string
			call printstr ; print the string
			call _delay
			call _delay
			call _delay
			call _delay
			call _delay
			call _delay
			call _delay
			call _delay
			call _delay
			call _delay
			call _delay
			call _delay
			call _delay
			call _delay
			call _delay
			call _delay
			call _delay
			call _delay
			call _delay
			call _delay
			call _delay
			call _delay
			call _delay
			call _delay
			call _delay
			call _delay
			call _delay
			call _delay
			call _delay
			call _delay
			;//////////////////////////////////////////////////////////////////////////////////////////////////////////
			mov ah, 0x10 ; service 10 – vga attributes
			mov al, 03 ; subservice 3 – toggle blinking
			mov bl, 01 ; enable blinking bit
			int 0x10 ; call BIOS video service
			call setbckgrnd ; set the background colour

			mov ax, 30
			push ax ; push x position
			mov ax, 7
			push ax ; push y position
			mov ax, 01110000b ; red text on light gray background
			push ax ; push attribute
			mov ax, msg7
			push ax ; push offset of string
			call printstr ; print the string
			push ds ; push string segment
			push ax ; push offset of string
			call strlen	; get string length

			mov ax, 30
			push ax ; push x position
			mov ax, 9
			push ax ; push y position
			mov ax, 01110100b ; red text on light gray background
			push ax ; push attribute
			mov ax, msg8
			push ax ; push offset of string
			call printstr ; print the string
			push ds ; push string segment
			push ax ; push offset of string
			call strlen	; get string length
			add ax,30 ; set x position for plus sign
			push ax
			mov ax, 9 ; set y position for plus sign
			push ax
			xor ax,ax
			mov al, 01110000b ; black text on light gray background
			push ax ; push attribute
			mov al, [cs:gCount]
 			push ax ; push number to print
 			call printnum ; print seconds

 			mov ax, 30
			push ax ; push x position
			mov ax, 10
			push ax ; push y position
			mov ax, 01110100b ; red text on light gray background
			push ax ; push attribute
			mov ax, msg9
			push ax ; push offset of string
			call printstr ; print the string

         

			push ds ; push string segment
			push ax ; push offset of string
			call strlen	; get string length
			add ax,30 ; set x position for plus sign
			push ax
			mov ax, 10 ; set y position for plus sign
			push ax
			xor ax,ax
			mov al, 01110000b ; black text on light gray background
			push ax ; push attribute
			mov al, [cs:bCount]
 			push ax ; push number to print
 			call printnum ; print seconds

 			mov ax, 30
			push ax ; push x position
			mov ax, 11
			push ax ; push y position
			mov ax, 01110100b ; red text on light gray background
			push ax ; push attribute
			mov ax, msg10
			push ax ; push offset of string
			call printstr ; print the string
			push ds ; push string segment
			push ax ; push offset of string
			call strlen	; get string length
			add ax,30 ; set x position for plus sign
			push ax
			mov ax, 11 ; set y position for plus sign
			push ax
			xor ax,ax
			mov al, 01110000b ; black text on light gray background
			push ax ; push attribute
			mov al, [cs:pCount]
 			push ax ; push number to print
 			call printnum ; print seconds

 			mov ax, 30
			push ax ; push x position
			mov ax, 13
			push ax ; push y position
			mov ax, 01110100b ; red text on light gray background
			push ax ; push attribute
			mov ax, msg11
			push ax ; push offset of string
			call printstr ; print the string
			push ds ; push string segment
			push ax ; push offset of string
			call strlen	; get string length
			add ax,30 ; set x position for plus sign
			push ax
			mov ax, 13 ; set y position for plus sign
			push ax
			xor ax,ax
			mov al, 01110000b ; black text on light gray background
			push ax ; push attribute
			mov ax, [cs:score]
 			push ax ; push number to print
 			call printnum ; print seconds

			 

			 mov ax, 25
			push ax ; push x position
			mov ax, 18
			push ax ; push y position
			mov ax, 11110000b ; red text on light gray background
			push ax ; push attribute
			mov ax, msg13
			push ax ; push offset of string
			call printstr ; print the string
			call rectan




		
 			pop di
			pop ds
			pop es
			pop ax
			pop cx
			pop bx
			pop dx
			ret
;==========================================================================
selectionofbucket:
            push ax
            call setbckgrnd
            mov ax, 28
			push ax ; push x position
			mov ax, 4
			push ax ; push y position
			mov ax, 01110000b ; red text on light gray background
			push ax ; push attribute
			mov ax, msg14
			push ax ; push offset of string
			call printstr ; print the string

			
			push 01010000b
			push    4
	        push	10
			call bucket

			push word[bucketcolour]
			push 14
			push 10
			call bucket

			push 01100000b 
			push 25
			push 10
			call bucket

			push 01000000b
			push 36
	        push	10
			call bucket

		    push 00110000b
			push 47
	        push	10
			call bucket

			push 00010011b
			push    58
	        push	10
			call bucket

			push 00100011b
			push    69
	        push	10
			call bucket

			mov ax, 1
			push ax ; push x position
			mov ax, 15
			push ax ; push y position
			mov ax, 01110000b ; red text on light gray background
			push ax ; push attribute
			mov ax, msg16
			push ax ; push offset of string
			call printstr ; print the string
			
			mov ah,0
			int 16h

			cmp al,112
			je setpink
			cmp al,111
			je setorange
			cmp al,114
			je setred
			cmp al,99
			je setcyan
			cmp al,98
			je setblue
			cmp al,103
			je setgreen

			pop ax
			ret

			setpink:
			MOV WORD[bucketcolour],01010000b
			pop ax
			ret
			setorange:
			MOV WORD[bucketcolour],01100000b
			pop ax
			ret
			setred:
			MOV WORD[bucketcolour],01000000b 
			pop ax
			ret
			setcyan:
			MOV WORD[bucketcolour],00110000b
			pop ax
			ret
			setblue:
			MOV WORD[bucketcolour],00010011b
			pop ax
			ret
			setgreen:
			MOV WORD[bucketcolour],00100011b
			pop ax
			ret
;==========================================================================
restart:
		mov word[tickcount],0
		mov word[score],0
		mov word[seconds],0
		mov byte[bCount],0
		mov byte[gCount],0
		mov byte[pCount],0
		mov byte[bucketcolour] , 00000000b
;==========================================================================
start: 	

		call startscreen
		call selectdifi
		call selectionofbucket
		xor ax, ax
		mov es, ax ; point es to IVT base
		mov ax, [es:8*4]
		mov [oldisr], ax ; save offset of old routine
		mov ax, [es:8*4+2]
		mov [oldisr+2], ax ; save segment of old routine
		cli ; disable interrupts
		mov word [es:8*4], timer; store offset at n*4
		mov [es:8*4+2], cs ; store segment at n*4+2
		sti ; enable interrupts 
		
		call MainScreen
	
		mov ax, [oldisr] ; read old offset in ax
		mov bx, [oldisr+2] ; read old segment in bx
		cli ; disable interrupts
		mov [es:8*4], ax ; restore old offset from ax
		mov [es:8*4+2], bx ; restore old segment from bx
		sti 

		
			
						

		call endScreen
		call _delay
		call _delay
		
		mov ah,0Ch
		mov al,01h
		int 21h
		
		cmp al,114;check if r
		je restart
		call setbckgrnd
		;show standard cursor
		mov ch, 6
 		mov cl, 7
 		mov ah, 1
 		int 10h 
		
		

		mov ax, 0x4c00 ; terminate program
		int 0x21