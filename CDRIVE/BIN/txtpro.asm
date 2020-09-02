assume cs:cseg,ds:cseg
cseg segment
org 100h
.386
JUMPS

start:	
		jmp begin
	
	;Messages
;-----------------------------------------------------------	
	startmsg db '                       Welcome to Text Editor Pro',0
	controlmsg db 'Controls: 1) Arrow keys move around. SPACE, Del, Enter, Backcpace apply '
			   db '        2)Ctrl-o: open file '
			   db '3)Ctrl-e: new page 4)Ctrl-b: box mode 5)Ctrl-q: quit/save '  ,0
	errormsg db 'Enter a valid keystroke:',0
	errorfilemsg db 'Error: Invalid file operation', 0
	againmsg db 'Hit Ctrl-n to start a new page or hit Ctrl-q to quit. File SAVED ',0
	leavemsg db 'Thank you for using Text Editor Pro!',0
	openmsg db 'choose an option for opening: 0=read; 1=write; 2=both: ',0
	boxmodemsg db 'Use arrow keys to create lines. Hit Ctrl-b to exit box mode',0
	
	
	; Variables
;-----------------------------------------------------------	
	currline dw ?
	inh dw ?
	outh dw ?
	outfile db 'output.txt',0
	infile db 'thanks.txt',0
	txtbuffer db 4096 dup(?),0
	linebuffer dw 79 dup(?)
	bufferindex dw 0
	prevpos dw ?
	prevposval dw ?
	
	boardtop dw ?
	boardbottom dw ?
	numrows db ?
	numcolms db ?
	
	;Procedures
;-----------------------------------------------------------
	errorfile:
		mov di, 640
		call lineclr
		mov si, offset errorfilemsg
		mov ah, 17h
		call ptrstr
		
		ret
		
;-----------------------------------------------------------
	close_file:
		
		mov ah, 3eh
		mov bx, inh
		int 21h
		jc errorfile
		
		mov ah,3eh
		mov bx, outh
		int 21h
		jc errorfile
		
		ret
		
;-----------------------------------------------------------		
	box_mode:
		push ax
		mov si, offset boxmodemsg
		mov ah, 17h
		mov di, 640
		call ptrstr
		pop ax
							;UPDATE: show current box under blick
		mov cx, es:[bx]
		sub ch,ch
		mov prevpos,cx
		mov prevposval, bx	
	boxagain:
		mov cx, es:[bx]
		cmp cl,32
		jg boxflash
		mov byte ptr es:[bx], 219
		mov byte ptr es:[bx+1],0F1h
		jmp boxnext
	boxflash:
		mov es:[bx], cl
		mov byte ptr es:[bx+1],0F1h
	boxnext:
		mov ah,00h
		int 16h
		mov es:[bx], cx ;removes the blinker from previous space
		cmp al,2 ;ctrl-b
		jne boxup
		jmp boxend
		
	boxup:
		cmp ah,72
		jne boxdown
		push bx
		sub bx, 160
		cmp bx, boardtop
		pop bx
		jl boxagain
		
		cmp prevpos,192
		jne bu1
		mov byte ptr es:[bx], 179
		mov byte ptr es:[bx+1],17h
		jmp bunext
	bu1:
		cmp prevpos,217
		jne bu2
		mov byte ptr es:[bx], 179
		mov byte ptr es:[bx+1],17h
		jmp bunext
	bu2:
		cmp prevpos,179
		jne corner192
		mov byte ptr es:[bx], 179
		mov byte ptr es:[bx+1],17h
		jmp bunext
	corner192:	
		cmp bx,prevposval
		jg corner217
		mov byte ptr es:[bx], 192
		mov byte ptr es:[bx+1],17h
		jmp bunext
	corner217:
		mov byte ptr es:[bx], 217
		mov byte ptr es:[bx+1],17h 
	bunext:	
		mov cx, es:[bx]
		sub ch,ch
		mov prevpos,cx
		mov prevposval,bx
		sub bx,160
		sub currline, 160
		jmp boxagain
		
	boxdown:
		cmp ah, 80
		jne boxright
		push bx
		add bx, 160
		cmp bx, boardbottom
		pop bx
		jg boxagain
		
		cmp prevpos,191
		jne bd1
		mov byte ptr es:[bx], 179
		mov byte ptr es:[bx+1],17h
		jmp bdnext
	bd1:
		cmp prevpos,218
		jne bd2
		mov byte ptr es:[bx], 179
		mov byte ptr es:[bx+1],17h
		jmp bdnext
	bd2:
		cmp prevpos,179
		jne corner191
		mov byte ptr es:[bx], 179
		mov byte ptr es:[bx+1],17h
		jmp bdnext
	corner191:	
		cmp bx,prevposval
		jl corner218
		mov byte ptr es:[bx], 191
		mov byte ptr es:[bx+1],17h
		jmp bdnext
	corner218:
		mov byte ptr es:[bx], 218
		mov byte ptr es:[bx+1],17h 
	bdnext:	
		mov cx, es:[bx]
		sub ch,ch
		mov prevpos,cx
		mov prevposval,bx
		add bx,160
		add currline,160
		jmp boxagain
		
	boxright:
		cmp ah,77
		jne boxleft
		push bx
		push currline
		add bx, 2
		add currline,154
		cmp bx, currline
		pop currline
		pop bx
		jg boxagain
		
		cmp prevposval,bx
		jng br1
		mov byte ptr es:[bx], 218
		mov byte ptr es:[bx+1],17h
		jmp brnext
	br1:	
		cmp prevpos,196
		jne br2
		mov byte ptr es:[bx], 196
		mov byte ptr es:[bx+1],17h	
		jmp brnext
	br2:
		cmp prevpos,218
		jne br3
		mov byte ptr es:[bx], 196
		mov byte ptr es:[bx+1],17h	
		jmp brnext
	br3:	
		cmp prevpos,192
		je br4
		mov byte ptr es:[bx], 192
		mov byte ptr es:[bx+1],17h
		jmp brnext
	br4:
		mov byte ptr es:[bx], 196
		mov byte ptr es:[bx+1],17h		
	brnext:	
		mov cx, es:[bx]
		sub ch,ch
		mov prevpos,cx
		mov prevposval,bx
		add bx,2
		jmp boxagain
		
	boxleft:
		cmp ah,75
		jne boxdelete
		push bx
		sub bx,2
		cmp bx, currline
		pop bx
		jl boxagain
		
		cmp prevposval,bx
		jg bl1
		mov byte ptr es:[bx], 217
		mov byte ptr es:[bx+1],17h
		jmp blnext
	bl1:
		cmp prevpos, 196
		jne bl2
		mov byte ptr es:[bx], 196
		mov byte ptr es:[bx+1],17h
		jmp blnext
	bl2:
		cmp prevpos, 217
		jne bl3
		mov byte ptr es:[bx], 196
		mov byte ptr es:[bx+1],17h
		jmp blnext
	bl3:
		cmp prevpos, 191
		je bl4
		mov byte ptr es:[bx], 191
		mov byte ptr es:[bx+1],17h
		jmp blnext
	bl4:
		mov byte ptr es:[bx], 196
		mov byte ptr es:[bx+1],17h
	blnext:	
		mov cx, es:[bx]
		sub ch,ch
		mov prevpos,cx
		mov prevposval,bx
		sub bx,2
		jmp boxagain
		
	boxdelete:
		cmp ah, 83 ;delete key
		jne boxagain
		mov byte ptr es:[bx],219
		mov byte ptr es:[bx+1],11h
		mov cx, es:[bx]
		sub ch,ch
		mov prevpos,cx
		mov prevposval,bx
		jmp boxagain
		
	boxend:	
		mov di, 640
		call lineclr
		ret
	
;-----------------------------------------------------------
	clear_buffer:
	
		push es
		push ds
		push cx
		
		mov cx,78
		mov ax,ds
		push ax
		mov ax,es
		mov ds,ax
		pop ax
		mov es,ax
		mov si,1720h
		mov di,offset linebuffer
		cld
		rep movsw
		rcl cx,1
		rep movsb

		pop cx
		pop ds
		pop es
		ret
;-----------------------------------------------------------

;	page_shift:
;	
;		cmp direction,0
;		jne psdown
;		cmp pagenum,1
;		jne pscont
;		jmp moveagain
;	psdown:
;		cmp pagenum,5
;		je	moveagain 
;	
;
;	pscont:	
;	;save current page
;		push es
;		push ds
;
;		mov ax,ds
;		push ax
;		mov ax,es
;		mov ds,ax
;		pop ax
;		mov es,ax
;		
;	
;		mov di,offset pagebuffer
;		mov cx, pagenum
;		sub cx,1
;		cmp cx,0
;		je psnext
;	looppage:	
;		add di,1600
;		loop looppage
;	
;	psnext:
;		mov cx,1600
;		mov si,800 
;		cld
;		rep movsw
;		rcl cx,1
;		rep movsb
;
;		pop ds
;		pop es
;		
;	;clear current page	
;		mov di,800
;		mov ax,1720h
;		mov cx,1600
;		cld
;		rep stosw
;	
;	;load page
;		cmp direction,0
;		jne nextpage
;		sub pagenum,1
;		
;		mov si,offset pagebuffer
;		mov cx, pagenum
;		sub cx,1
;		cmp cx,0
;		je psnext2
;	looppage2:	
;		add si,1600
;		loop looppage2
;	psnext2:	
;		mov cx,1600
;		mov di, 800
;		cld
;		rep movsw
;		rcl cx,1
;		rep movsb
;		mov bx,3682
;		mov currline,bx
;		sub pagenum,1
;		jmp spdone
;		
;	nextpage:
;		add pagenum,1
;		
;		mov si,offset pagebuffer
;		mov cx, pagenum
;		sub cx,1
;	looppage3:	
;		add si,1600
;		loop looppage3
;		
;		mov cx,1600
;		mov di, 800
;		cld
;		rep movsw
;		rcl cx,1
;		rep movsb	
;		add pagenum,1
;		mov bx,962
;		mov currline,bx
;	
;	spdone:	
;		jmp moveagain
;		
;-----------------------------------------------------------		
	shift_left:
		
		cmp bx,currline
		je sldone
		mov cx, currline
		add cx,78
		sub bx,78
		sub cx, bx
		add bx,78
		shr cx,1
		push es
		push ds
		push cx
		
	;saving the line	
		mov ax,ds
		push ax
		mov ax,es
		mov ds,ax
		pop ax
		mov es,ax
		mov si,bx
		mov di,offset linebuffer
		cld
		rep movsw
		rcl cx,1
		rep movsb
	

	;restoring the line	
		pop cx
		pop ds
		pop es		
					; removing the last character from screen
		push cx
		push bx
		shl cx,1
		add bx,cx
		sub bx,2
		mov ax, 1720h
		mov es:[bx],ax
		pop bx
		pop cx
		
		mov di, bx
		sub di,2
		mov si,offset linebuffer
		cld
		rep movsw
		rcl cx,1
		rep movsb
		
		sub bx,2
	sldone:
		ret
		
;-----------------------------------------------------------		
	shift_right:
		
		mov ax, currline
		add ax,154
		cmp bx,ax
		je srdone
		mov cx, currline
		add cx,77
		sub bx,77
		sub cx, bx
		add bx,77
		shr cx,1
		push es
		push ds
		push cx
		
	;saving the line	
		mov ax,ds
		push ax
		mov ax,es
		mov ds,ax
		pop ax
		mov es,ax
		mov si,bx
		mov di,offset linebuffer
		cld
		rep movsw
		rcl cx,1
		rep movsb
		
	;restoring the line	
		pop cx
		pop ds
		pop es
		mov di, bx
		add di,2
		mov si,offset linebuffer
		cld
		rep movsw
		rcl cx,1
		rep movsb
		
		mov ax,1720h	;clears the space
		mov es:[bx],ax
		add bx,2
	srdone:
		ret

;-----------------------------------------------------------		
	save_file:
		
		push bx
		mov cx,18
		mov bx, boardtop
		
	sfnext:
		push cx
		mov cx,78
		push es
		push ds
		
		;saving the line	
		mov ax,ds
		push ax
		mov ax,es
		mov ds,ax
		pop ax
		mov es,ax
		mov si,bx
		mov di,offset linebuffer
		cld
		rep movsw
		pop ds
		pop es
		
		mov linebuffer[156],13
		push bx
		mov si,79
		mov di, offset linebuffer
	sfout:
		mov ah, 40h
		mov bx,outh
		mov cx,1
		mov dx,di
		int 21h
		jc errorfile
		add di,2
		dec si
		cmp si,0
		jg sfout
					
	
		pop bx
		add bx, 160
		pop cx
		loop sfnext
		
		pop bx
		ret
		
;------------------------------------------------------------	
	new_file:
				; UPDATE: let user enter file name 
		mov dx, offset outfile
		mov ah, 3ch
		mov cx,0	;file attribute 
		int 21h
		jc errorfile
		mov outh, ax
		
		ret
		
;-----------------------------------------------------------		
	print_buffer:
		
		mov di,boardtop
		mov currline,di
	pb1:	
		mov al,[si]
		cmp al, 0 
		je pbdone
		mov bx,di
		sub bx,currline
		cmp bx,154
		jng pb2
		add di,4
		mov currline,di
	pb2:
		cmp al, 13
		jne pb3
		add currline,160
		mov di, currline
		inc si
		inc si
		jmp pb1
	pb3:
		cmp al, 9
		jne pb4
		add di,8
		inc si
		jmp pb1
	pb4:	
		mov es:[di],al
		mov byte ptr es:[di+1], 17h 
		add di,2
		inc si
		jmp pb1
	pbdone:	
		ret
;-----------------------------------------------------------		
	open_file:
				; UPDATE: let user enter file name 
		mov si, offset openmsg
		mov ah, 17h
		mov di, 640
		call ptrstr
		
		mov ah, 00h
		int 16h
		cmp al,48
		jne in1
		mov al,0
		jmp in3
	in1:
		cmp al,49
		jne in2
		mov al,1
		jmp in3
	in2:
		cmp al,50
		jne in3
		mov al,2
	in3:
		mov di, 640
		call lineclr
		mov dx,offset infile
		mov al,0
		mov ah,3dh
		int 21h
		jc errorfile
		mov inh, ax

		
		mov di, offset txtbuffer
	lo1: 
		mov ah,3fh
		mov bx, inh
		mov cx,1
		mov dx,di
		int 21h
		jc errorfile
		or ax,ax
		jz lo2
		inc di
		jmp lo1
	lo2: 
		mov si,offset txtbuffer
		call print_buffer
		ret
		
;-----------------------------------------------------------		
	setboarder:	; sets the board
				;first set the vertical lines
		mov numrows, 5
		mov numcolms, 12
		mov boardtop, 962
		mov boardbottom, 3840
		
		push cx
		mov cx, 2
		mov bx,960
	lside:
		push cx
		mov cx, 18
	rside:	
		mov byte ptr es:[bx],186
		mov byte ptr es:[bx+1],17h
		add bx,160
		loop rside
		sub bx,2880
		add bx, 158
		pop cx
		loop lside
					;setting the horizontal lines.
		mov cx, 2
		mov bx, 802
	lside2:
		push cx
		mov cx, 78
	rside2:	
		mov byte ptr es:[bx],205
		mov byte ptr es:[bx+1],17h
		add bx,2
		loop rside2
		sub bx,156
		add bx,3040
		pop cx
		loop lside2

				; setting the corners
		mov cx,2
		mov bx,800
		mov al,201
		mov ah, 200
	bottom:
		mov byte ptr es:[bx],al 	;first corner on row
		mov byte ptr es:[bx+1],17h
		add bx,3040
		mov byte ptr es:[bx],ah
		mov byte ptr es:[bx+1],17h
		mov al, 187
		mov ah, 188
		sub bx, 2882
		loop bottom		
		
		pop cx
		ret
		
;-----------------------------------------------------------	
	ptrstr:	
		push ax
	l:	
		mov al,[si]
		or al,al
		jz done
		mov es:[di], ax
		add si, 1
		add di , 2
		jmp l
	done:
		pop ax
		ret
		
;-----------------------------------------------------------		
	lineclr:	;clears the current line on screen
				; using % on bx gets the line its on and then reset bx
		push ax
		push di
		mov ax, 1720h
		mov cx, 80
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
		mov ah, 17h
		mov di, 0
		call ptrstr
		mov si, offset controlmsg
		mov ah, 17h
		mov di, 160
		call ptrstr	
		call setboarder
		
		call open_file
		call new_file
							;set controls
		mov bx,boardtop
		mov currline,bx
	moveagain:
		mov cx, es:[bx]
		cmp cl,32
		jg flash
		mov byte ptr es:[bx], 219
		mov byte ptr es:[bx+1],0F1h
		jmp next
	flash:
		mov es:[bx], cl
		mov byte ptr es:[bx+1],0F1h
	next:
		mov ah, 00h
		int 16h
		mov es:[bx], cx	;removes the blinker from previous space
		cmp al,17 ;ctrl-q
		jne open
		jmp again
	open:
		cmp al, 15 ; ctrl-o
		jne create
		jmp begin
	create:
		cmp al, 5 ; ctrl-e 
		jne box
		call new_file
		mov di,800
		mov ax,1720h
		mov cx,1600
		cld
		rep stosw
		call setboarder
		jmp moveagain
	box:
		cmp al,2 ;ctrl-b
		jne up
		call box_mode
		jmp moveagain
	up:	
		cmp ah,72
		jne down
		push bx
		sub bx, 160
		cmp bx, boardtop
		pop bx
		jl moveagain
		sub bx,160
		sub currline, 160
		jmp moveagain
	down:
		cmp ah, 80
		jne right
		push bx
		add bx, 160
		cmp bx, boardbottom
		pop bx
		jg moveagain
		add bx,160
		add currline,160
		jmp moveagain
	right:
		cmp ah,77
		jne left
		push bx
		push currline
		add bx, 2
		add currline,154
		cmp bx, currline
		pop currline
		pop bx
		jg moveagain
		add bx,2
		jmp moveagain
	left:
		cmp ah,75
		jne space
		push bx
		sub bx,2
		cmp bx, currline
		pop bx
		jl moveagain
		sub bx,2
		jmp moveagain
	space:	
		cmp al,32
		jne backspace
		call shift_right
		jmp moveagain
	backspace:
		cmp al,8 ;backspace key
		jne delete
		call shift_left
		jmp moveagain
	delete:
		cmp ah, 83 ;delete key
		jne enterkey
		mov ax,1720h
		mov es:[bx],ax
		jmp moveagain
	enterkey:
		cmp al,13
		jne paste
		push bx
		add bx, 160
		cmp bx, boardbottom
		pop bx
		jg moveagain
		add bx,160
		add currline,160
		jmp moveagain
	paste:
		mov es:[bx],ax
		mov byte ptr es:[bx+1],17h
		push bx
		push currline
		add bx, 2
		add currline,154
		cmp bx, currline
		pop currline
		pop bx
		jg moveagain
		add bx,2
		jmp moveagain
		
	
		
	again:
		mov di, 640
		call lineclr
		mov si, offset againmsg
		mov ah, 17h
		call ptrstr
		mov ah, 00h
		int 16h
		cmp al, 14 ;ctrl-n
		jne quit
		call save_file
		call close_file
		jmp begin 
	quit:
		cmp al, 17 ;ctrl-q
		jne badinput
		call save_file
		call close_file
		mov si, offset leavemsg
		mov ah, 17h
		mov di, boardbottom
		add di, 160
		call ptrstr
		int 20h
	badinput:
		mov si, offset errormsg
		mov ah, 17h
		mov di, boardbottom
		add di, 640
		call ptrstr
		jmp again
		
		
		
cseg ends
end start