assume cs:cseg,ds:cseg
cseg segment
org 100h
.386
JUMPS

start:	
		jmp begin
	
	;Messages
;-----------------------------------------------------------	
	startmsg db 'Welcome to Minesweeper! To win cover all mines with flags!',0
	boardmsg db 'Choose your board/diffuculty level: 1-beginner 2-Intermediate 3-Expert',0
	controlmsg db 'Controls: 1) Use arrow keys to move around'
			   db ' 2) SPACE = flip square                         '
			   db '3) f = set flag 4) X are mines 5) q = quit game'  ,0
	errormsg db 'Enter a valid keystroke:',0
	againmsg db 'Press "A" to play again or "Q" to quit',0
	leavemsg db 'Thank you for playing!',0
	winmsg db 'YOU WON! GOOD GAME!',0
	losemsg db 'YOU LOST! Better luck next time.',0
	flagmsg db "Hit SPACE to revel flag OR hit 'f' to remove flag",0

	; Variables
;-----------------------------------------------------------	
	currline dw ?
	minesize dw ?
	flagmine dw ?
	inccflag db 0 
	boardtop dw ?
	boardbottom dw ?
	numrows db ?
	numcolms db ?
	mines dw 100 dup(?)
	mineseasy dw 4,16,20,32,332,344,356
	
	;Procedures
;-----------------------------------------------------------	
	showmines:
		pusha
		
		mov cx, minesize
		sub bx,bx
		sub di,di
		sub ax,ax
		mov ah,14h
		mov al, 'X'
	outputmine:
		mov bx,mines[di]
		mov es:[bx],ax
		add di, 2
		loop outputmine
		
		popa
		ret
		
;-----------------------------------------------------------		
	gameover:
		mov si, offset losemsg
		mov ah, 7
		mov di, boardbottom
		add di, 320
		call ptrstr
		call showmines
		jmp again
		
;-----------------------------------------------------------		
	winner:
		mov si, offset winmsg
		mov ah, 7
		mov di, boardbottom
		add di, 320
		call ptrstr
		call showmines
		jmp again
		
;-----------------------------------------------------------
	color:
		cmp ax, 48
		jne brown
		mov byte ptr es:[bx+1], 7
		jmp endcolor
	brown:
		cmp ax, 49
		jne magenta
		mov byte ptr es:[bx+1],6
		jmp endcolor
	magenta:
		cmp ax, 50
		jne red
		mov byte ptr es:[bx+1], 5
		jmp endcolor
	red:
		cmp ax, 51
		jne cyan
		mov byte ptr es:[bx+1], 4
		jmp endcolor
	cyan:
		cmp ax,52
		jne green
		mov byte ptr es:[bx+1], 3
		jmp endcolor
	green:
		cmp ax, 53
		jne yellow
		mov byte ptr es:[bx+1], 2
		jmp endcolor
	yellow:
		cmp ax, 54
		jne white
		mov byte ptr es:[bx+1], 14
		jmp endcolor
	white:
		cmp ax, 55
		jne lightred
		mov byte ptr es:[bx+1], 15
		jmp endcolor
	lightred:
		mov byte ptr es:[bx+1], 12
	endcolor:
		ret
	
;-----------------------------------------------------------	
	adjmines:	; calculates the adjacent mines
				; set the current box to a number
		push cx
		push bx
		sub cx,cx
		mov cx,2
		sub ax,ax
		mov al, 48;;
		cmp byte ptr es:[bx+4], 'X'
		jne p1
		inc al;;
	p1:
		cmp byte ptr es:[bx-4], 'X'
		jne p2
		inc al;;
	p2:		
		sub bx, 328
	p3:
		push cx
		mov cx,3
	p4:
		cmp cx, 0
		jng p5
		dec cx
		add bx,4
		cmp byte ptr es:[bx], 'X'
		jne p4
		inc al;;			
		jmp	p4	
	p5:
		add bx, 628
		pop cx
		loop p3	
						;check if there is any flags adj
		pop bx
		push bx
		sub cx,cx
		mov cx,2
		cmp byte ptr es:[bx+4], 'f'
		jne p11
		push bx
		add bx ,4
		call searchmines
		pop bx
		cmp ah, 1
		jne p11
		inc al;;
	p11:
		cmp byte ptr es:[bx-4], 'f'
		jne p22
		push bx
		sub bx ,4
		call searchmines
		pop bx
		cmp ah, 1
		jne p22
		inc al;;
	p22:		
		sub bx, 328
	p33:
		push cx
		mov cx,3
	p44:
		cmp cx, 0
		jng p55
		dec cx
		add bx,4
		cmp byte ptr es:[bx], 'f'
		jne p44
		call searchmines
		cmp ah, 1
		jne p44
		inc al;;			
		jmp	p44	
	p55:
		add bx, 628
		pop cx
		loop p33	
		
		pop bx
		mov es:[bx],al
		call color
		pop cx
		ret
	
;-----------------------------------------------------------	
	searchmines:
		push cx
		sub cx,cx
		sub ah,ah
		sub dx,dx
		mov cx, minesize
		sub di,di
	nextmine:
		mov dx,mines[di]		
		cmp dx, bx
		jne nextmine1
		mov ah,1
		pop cx
		ret
	nextmine1:
		add di,2
		loop nextmine		
		pop cx
		ret
		
;-----------------------------------------------------------		
	setmines_easy:				; sets the mines on the board
						; # of mines is based on board size
		push di
		mov ah, 11h
		mov al, 'X'
		sub di,di
		sub bx,bx
		sub dx,dx
		mov di,boardtop
		
		mov es:[di+4],ax
		mov dx, di
		add dx,4
		mov mines[bx],dx
		add bx,2
		mov es:[di+16],ax
		mov dx, di
		add dx,16
		mov mines[bx],dx
		add bx,2
		mov es:[di+20],ax
		mov dx, di
		add dx,20
		mov mines[bx],dx
		add bx,2
		mov es:[di+32],ax
		mov dx, di
		add dx,32
		mov mines[bx],dx
		add bx,2
		mov es:[di+332],ax
		mov dx, di
		add dx,332
		mov mines[bx],dx
;push bx
 
		add bx,2
		mov es:[di+344],ax
		mov dx, di
		add dx,344
		mov mines[bx],dx
		add bx,2
		mov es:[di+356],ax
		mov dx, di
		add dx,356
		mov mines[bx],dx
;pop bx
;mov di, mines[bx]
;mov byte ptr es:[di],'E'
		
		add bx,2
		mov es:[di+644],ax
		mov dx, di
		add dx,644
		mov mines[bx],dx
		add bx,2
		mov es:[di+652],ax
		mov dx, di
		add dx,652
		mov mines[bx],dx
		add bx,2
		mov es:[di+656],ax
		mov dx, di
		add dx,656
		mov mines[bx],dx
		add bx,2
		mov es:[di+672],ax
		mov dx, di
		add dx,672
		mov mines[bx],dx
		add bx,2
		mov es:[di+960],ax
		mov dx, di
		add dx,960
		mov mines[bx],dx
		add bx,2
		mov es:[di+976],ax
		mov dx, di
		add dx,976
		mov mines[bx],dx
		add bx,2
		mov es:[di+984],ax
		mov dx, di
		add dx,984
		mov mines[bx],dx
		add bx,2
		mov es:[di+1320],ax
		mov dx, di
		add dx,1320
		mov mines[bx],dx
		add bx,2
		pop di
		ret
		
;-----------------------------------------------------------		
	setboard_easy:	; sets the board size based on users input
				;first set the vertical lines
		mov flagmine, 15
		mov minesize, 15
		mov numrows, 5
		mov numcolms, 12
		mov boardtop, 642;482
		mov boardbottom, 1920;1760
		
		push cx
		mov cx, 12
		mov bx,640;480
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
		mov bx, 482;322
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
		mov bx ,800;640
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
		mov bx,480;320
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
		mov bx, 2080;1920
		mov al, 200
		mov ah, 202
		pop cx
		loop top		
		
		pop cx
		ret
		
;-----------------------------------------------------------	
	ptrstr:	
	l:	
		mov al,[si]
		or al,al
		jz done
		mov es:[di], ax
		add si, 1
		add di , 2
		jmp l
	done:
		ret
		
;-----------------------------------------------------------		
	lineclr:	;clears the entire screen
		push ax
		push di
		mov ax, 1720h
		mov cx, 80
		;mov di, boardbottom
		;add di, 320
	l3:	mov es:[di],ax
		add di,2
		loop l3
		
		pop di
		pop ax
		ret
	
;-----------------------------------------------------------		
	clrscr:					;clears the entire screen
		mov ax, 1720h
		mov cx, 2000
		sub bx,bx
	l2:	mov es:[bx],ax
		add bx,2
		loop l2

		ret
	
;-----------------------------------------------------------		
	begin:
		mov ax, 0b800h
		mov es, ax
		call clrscr
						;print starting mesage
		mov si, offset startmsg
		mov ah, 7
		mov di, 0
		call ptrstr
		mov si, offset controlmsg
		mov ah, 7
		mov di, 160
		call ptrstr	
		call setboard_easy
		call setmines_easy
							;set controls
		mov bx,boardtop
		mov currline,bx
	moveagain:
		mov cx, es:[bx]
		cmp cl,32
		jg blinkcheck
		mov byte ptr es:[bx], 219
		mov byte ptr es:[bx+1],0F1h
		jmp nextinput
	blinkcheck:
		cmp cl,'X'
		jne blink
		mov byte ptr es:[bx], 219
		mov byte ptr es:[bx+1],0F1h
		jmp nextinput
	blink:
		mov es:[bx], cx
		mov byte ptr es:[bx+1],0F1h
	nextinput:
		mov ah, 00h
		int 16h
		mov es:[bx], cx
		cmp al,'q'
		jne putflag
		jmp again
	putflag:
		cmp al, 'f'
		jne up
		cmp cl, 'X'
		jne paste
		mov byte ptr es:[bx], 'f'
		mov byte ptr es:[bx+1], 12
		dec flagmine
		cmp flagmine,0
		jne up
	;cmp inccflag, 48
	;jne up
		call winner		
	paste:
	;inc inccflag
		mov byte ptr es:[bx], 'f'
		mov byte ptr es:[bx+1], 12
		jmp moveagain
	up:	
		cmp ah,72
		jne down
		push bx
		sub bx, 160
		cmp bx, boardtop
		pop bx
		jl moveagain
		sub bx,320
		sub currline, 320
		jmp moveagain
	down:
		cmp ah, 80
		jne right
		push bx
		add bx, 160
		cmp bx, boardbottom
		pop bx
		jg moveagain
		add bx,320
		add currline,320
		jmp moveagain
	right:
		cmp ah,77
		jne left
		push bx
		push currline
		add bx, 4
		add currline,40
		cmp bx, currline
		pop currline
		pop bx
		jg moveagain
		add bx,4
		jmp moveagain
	left:
		cmp ah,75
		jne space
		push bx
		sub bx,4
		cmp bx, currline
		pop bx
		jl moveagain
		sub bx,4
		jmp moveagain
	space:	
		cmp al,32
		jne moveagain
		cmp cl, 'X'
		jne checkflag
		call gameover
	checkflag:					;check to see if space was already flipped
		cmp cl, 'f'
		jne checkspace
		mov si, offset flagmsg
		mov ah, 7
		mov di, boardbottom
		add di, 320
		call ptrstr
		mov ah, 00h
		int 16h
		mov di, boardbottom
		add di, 320
		call lineclr			;remove message
		call searchmines		;search to see if bx held a mine	
		cmp al, 32
		jne removeflag
		cmp ah,1
		jne pass
		call gameover
	removeflag:	
		cmp ah, 1
		jne unpaste
		mov byte ptr es:[bx], 'X'
		mov byte ptr es:[bx+1], 11h
		inc flagmine
		jmp moveagain
	unpaste:
	;dec inccflag
	;cmp inccflag,48
		mov byte ptr es:[bx], 219
		mov byte ptr es:[bx+1], 11h
	;je winner
		jmp moveagain
	checkspace:	
		cmp cl,48	
		jl pass
		cmp cl,57
		jg pass
		jmp moveagain
	pass:
	;dec inccflag
		cmp flagmine, 0
		jne adj		; jump if its greater than or equal adj
	;cmp inccflag, 48
	;jne adj	
		call winner
	adj:
		call adjmines
		jmp moveagain
		
	again:
		mov si, offset againmsg
		mov ah, 7
		mov di, boardbottom
		add di, 480
		call ptrstr
		mov ah, 00h
		int 16h
		cmp al, 'a'
		jne next
		jmp begin
	next:
		cmp al, 'q'
		jne quit
		mov si, offset leavemsg
		mov ah, 7
		mov di, boardbottom
		add di, 960
		call ptrstr
		int 20h
	quit:
		mov si, offset errormsg
		mov ah, 7
		mov di, boardbottom
		add di, 640
		call ptrstr
		jmp again
		
		
		
cseg ends
end start