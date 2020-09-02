assume cs:cseg,ds:cseg
cseg segment
org 100h
.386
JUMPS

start:	
		jmp begin
	
	;errormsg db 'Enter a valid keystroke:',0
	;againmsg db 'Press "A" to play again or "Q" to quit',0
	
	ptrstr_error:
	
		ret
		
	ptrstr_again:
	
		ret
	
	gameover:
		call clrscr
		
		ret
		
	winner:
	
		ret
	
	showmines:
	
		ret
		
	adjmines:	; calculates the adjacent mines
				; set the current box to a number
		push cx
		push ax
		mov ax, 156
		sub cx,cx
		mov ch,2
		cmp byte  ptr es:[bx+2], 'X'
		jne p1
		inc cl
	p1:
		cmp byte  ptr es:[bx-2], 'X'
		jne p2
		inc cl
	p2:
		cmp ah,162
		jng p3
		jmp p4
	p3:	
		add ah,2
		push bx
		sub bx,ax
		cmp byte  ptr es:[bx], 'X'
		pop bx
		jne p2
		inc cx
		jmp	p2	
	p4:
		mov ah, 156
		loop p2
	
	p5:	
		mov es:[bx],cx
		mov byte ptr es:[bx+1],7
		pop ax
		pop cx
		ret
		
		
	setboard_easy:	; sets the board size based on users input
				;first set the vertical lines
		push bx
		mov cx, 46
		push cx
		mov cx, 12
		mov bx,480
	lside:
		push cx
		mov cx, 5
	rside:	
		mov byte ptr es:[bx],186
		mov byte ptr es:[bx+1],17h
		add bx,320
		loop rside
		sub bx,1600
		add bx, 4
		pop cx
		loop lside
		
					;setting the horizontal lines.
		mov cx, 11
		mov bx,322
	lside2:
		push cx
		mov cx, 6
	rside2:	
		mov byte ptr es:[bx],205
		mov byte ptr es:[bx+1],17h
		add bx,320
		loop rside2
		sub bx,1920
		add bx, 4
		pop cx
		loop lside2
		
				;setting the the 2 side borders and the middles
		mov cx, 12
		mov bx , 640
		mov al, 204
	sborder1:
		push cx
		mov cx, 4
	sborder2:	
		mov  es:[bx],al
		mov byte ptr es:[bx+1],17h
		add bx, 320
		loop sborder2
		sub bx, 1280
		add bx, 4
		mov al, 206
		pop cx
		cmp cx,2
		jne same
		mov al, 185
	same:	
		loop sborder1
		
				; setting the top and bottom of board
		mov cx,2
		mov bx,320
		mov al,201
		mov ah, 203
	top:
		push cx
		mov byte ptr es:[bx],al 	;first corner on row
		mov byte ptr es:[bx+1],17h
		mov al, 187
		cmp cx,1
		jne skip
		mov al,188
	skip:
		mov cx, 10
	bottom:
		add bx, 4
		mov byte ptr es:[bx],ah 	;top and bottom peices 
		mov byte ptr es:[bx+1],17h
		loop bottom
		add bx,4
		mov byte ptr es:[bx],al		;top and bottom peices 
		mov byte ptr es:[bx+1],17h
		mov bx, 1920
		mov al, 200
		mov ah, 202
		pop cx
		loop top		
		
		pop cx
		pop bx
		ret
		
		
	setmines:				; sets the mines on the board
						; # of mines is based on board size
		 
		
		;ret
		
	clrscr:					;clears the entire screen
		mov ax, 1720h
		mov cx, 2000
		sub bx,bx
	l:	mov es:[bx],ax
		add bx,2
		loop l

		ret
		
	testprint: 
		mov BYTE PTR es:[bx],'l'
		mov ax, 11h
		mov es:[bx+1], ax
		inc bx
		inc bx 
		mov byte ptr es:[bx],'e'
		inc bx
		mov byte ptr es:[bx],6
		ret
		

	begin:
		mov ax, 0b800h
		mov es, ax
		call clrscr
		;call setboard_easy
		
		mov ah, 00h
		int 16h
		mov es:[830], ah 
		mov byte ptr es:[831], 7 
		mov es:[834], al 
		mov byte ptr es:[835], 7 
		int 20h
		
		
		
		
		
cseg ends
end start