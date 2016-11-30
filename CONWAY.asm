IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

; mul val 
; gaat eax vermenigvuldigen met val (gaat altijd eax vermenigvuldigen met een ander register)
; en gaat dan als je eax vermenigvuldigd met een getal 
; de higher bits in eax opslaan en de lower bits in edx dus 32bit * 32bit geeft een 64bit getal
; als je weet dat je geen 32bit getallen gaat gebruiken, neem dan een kleiner register
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
; CODE
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
CODESEG
; argumenten popen op het einde 
; alles naar 32bit 
; evenveel pushen als poppen 
;behalve in het geval van een Function call sub esp 8 (gelijk aan 2 keer pop)
;---------------Variables--------------- variables in this way work 
gridWidth	equ 10
gridHeight	equ 10
gridSize 	equ gridWidth * gridHeight
;---------------------------------------

		; Author: Asma Oualmakran
		;Function: Index
		;Parameters: 
			;x: 
				; Type: intiger
				; Use: x-coordinate of the cell. 
				; Constraint: larger or equal to 0 and smaller than gridWidth.
			;y:
				; Type: intiger 
				; Use: y-coordinate of the cell. 
				;Constraint: larger or equal to 0 and smaller than gridHeight.
		;Returns: An index in the grid_array
		;Use: Converts the coordinates of the cell into an index in the gridArray (formula: index = (x-1)*row-width+y.

	

		PROC Index
		push ebp 			; save base pointer (EBP) value on the s tack
		mov ebp, esp 		; set current stack pointer ( in ESP) as the new base pointer ( in EBP)
		push eax
		push ebx 			; save EBX value
		push ecx
		push edx

		mov eax , [ebp+8] 	; take the value of LAST pushed argument
		mov ebx , [ebp+12] 	; take the value of FIRST pushed argument
							; index = (x-1)*gridWidth+y
							; al contains x-coordinate, bl contains y-coordinate

		; here test if values in range
		
	;	cmp ax, gridWidth
	;	jg
	;	cmp bx, gridHeight
	;	jg
	;	cmp ax, 0
	;	jl
	;	cmp bx, 0
	;	jl

		dec eax              ; x-1
		imul edx, eax, gridWidth	 ; multiply (x-1) with gridWidth
		mov eax, edx
		add eax, ebx 			; add the result of the multiplication with the y-coordinate
							; the result is stored in eax
		
		;print the result 


	;	push edx 
	;	call PrintDigit
	;	sub esp, 4
	;	push edx 
	;	call PrintDigit
	;	sub esp, 4

        pop edx
        pop ecx
		pop ebx 			; restore the or iginal EBX value
	;	pop eax				; don't pop eax to keep the result, otherwise it will be overwritten
		mov esp, ebp 		; restore the or iginal s tack pointer
		pop ebp 			; retrieve the or iginal base pointer
		ret 				; return to next instruction after the call
		
		ENDP Index

		; Asma: Asma Oualmakran 
		; Function: PrintDigit
		; Parameters: 
			; number
				; Type: intiger
				; Use: The intiger that has to be printed.
				; Constraint: It has to be an intiger. 
		; Returns: N/a 
		; Use: Print the value of the intiger on the screen. 

		PROC PrintDigit
		push ebp
		mov ebp, esp 
		push eax 

		mov cx, 0
    	mov bx, 10
		@@loop:
    	mov dx, 0
    	div bx                          ;divide by ten

    ; now ax <-- ax/10
    ;     dx <-- ax % 10

    ; print dx
    ; this is one digit, which we have to convert to ASCII
    ; the print routine uses dx and ax, so let's push ax
    ; onto the stack. we clear dx at the beginning of the
    ; loop anyway, so we don't care if we much around with it

    	push ax
    	add dl, '0'                     ;convert dl to ascii otherwise it wont print the value

    	pop ax                          ;restore ax
    	push dx                         ;digits are in reversed order, must use stack
    	inc cx                          ;remember how many digits we pushed to stack
    	cmp ax, 0                       ;if ax is zero, we can quit
		jnz @@loop

   		 ;cx is already set
 	   mov ah, 02h                       ;2 is the function number of output char in the DOS Services.
		@@popStack:
    	pop dx                          ;restore digits from last to first
    	int 21h                         ;calls DOS Services
    	loop @@popStack

		pop eax 
		mov esp, ebp 
		pop ebp
		ret
		ENDP PrintDigit

		; Author: Asma Oualmakran
		; Function: KillCell
		; Parameters: 
			; x 
				; Type: intiger
				; Use: The x-coordinate of the cell who needs to be killed. 
				; Constraint: larger or equal to 0 and smaller than the gridWidth
			; y
				; Type: intiger
				; Use: The y-coordinate of the cell who needs to be killed. 
				; Constraint: larger or equal to 0 and smaller than the gridHeight
		; Returns: N/a 
		; Use: Set the state of a living cell to dead.

		PROC KillCell
		push ebp
		mov ebp, esp 
		push eax 
		push ebx 
		push edx 
		push edi 
		mov eax, [ebp+8]	; value of the last argument pushed (pm1) y
		mov ebx, [ebp+12]	; value of the first argument pushed (pm2)

		push ebx  			; call the function to calculate the array index 
		push eax 
		call Index 			; edx contains the result afther the call
		sub esp, 8			; ather a call pop the arguments form the stack 	
							; sub esp, 8 equals 2 pops
	

		mov edi, eax			; move the result of the procedure in the right register
		mov [gridArray+edi], 0			; put the value in the array on the right array location
		 

		pop edi
		pop edx   
		pop ebx
		pop eax
		mov esp, ebp
		pop ebp
		ret 

		ENDP KillCell

		; Author: Asma Oualmakran
		; Function: AwakeCell
		; Parameters:
			; grid 
				;
			; x 
				; Type: intiger
				; Use: The x-coordinate of the cell who needs to be awakend. 
				; Constraint: larger or equal to 0 and smaller than the gridWidth
			; y
				; Type: intiger
				; Use: The y-coordinate of the cell who needs to be awakend. 
				; Constraint: larger or equal to 0 and smaller than the gridHeight
		; Returns: N/a 
		; Use: Set the state of a dead cell to alive.

		PROC AwakeCell
		push ebp
		mov ebp, esp 
		push eax 
		push ebx 
		push edx 
		push edi 
		mov eax, [ebp+8]	; value of the last argument pushed (pm1) y
		mov ebx, [ebp+12]	; value of the first argument pushed (pm2)

		push ebx  			; call the function to calculate the array index 
		push eax 			; ebx and eax contain the arguments of the function call (passed by the top function)
		call Index 			; edx contains the result afther the call
		sub esp, 8			; ather a call pop the arguments form the stack 	
		
							; sub esp, 8 equals 2 pops
		;debug code
		push eax 
		call PrintDigit
		sub esp, 4
		;end debug

		mov edi, eax			; move the result of the procedure in the right register
		mov [gridArray+edi], 1			; put the value in the array on the right array location

		
		;debug code 
	;	mov eax, [gridArray+edi]

	;	cmp eax, 1
	;	je @@print 
	;	cmp eax, 0
	;	je @@print0
	;	jp @@continue
	;	@@print: 
	;	  mov ah, 09h                     ; AH=09h - Print DOS Message
    ;    mov edx, offset _msg1           ; DS:EDX -> $ Terminated String
    ;    int 21h                         ; DOS INT 21h

    ;    mov eax, 0h
    ;    int 16h
    ;    jp @@continue

    ;    @@print0: 
	;	  mov ah, 09h                     ; AH=09h - Print DOS Message
    ;    mov edx, offset _msg0          ; DS:EDX -> $ Terminated String
    ;    int 21h                         ; DOS INT 21h

    ;    mov eax, 0h
    ;    int 16h
    ;    jp @@continue
    ;     @@continue:
        ; end debug 
		 
       

		pop edi
		pop edx   
		pop ebx
		pop eax
		mov esp, ebp
		pop ebp
		ret 
		ENDP AwakeCell

		; Author: Asma Oualmakran
		; Function: StateCell
		; Parameters:
			; grid 
				;
			; x 
				; Type: intiger
				; Use: The x-coordinate of the cell. 
				; Constraint: larger or equal to 0 and smaller than the gridWidth
			; y
				; Type: intiger
				; Use: The y-coordinate of the cell. 
				; Constraint: larger or equal to 0 and smaller than the gridHeight
		; Returns: State of the cell. 
		; Use: Get the state of a cell from the grid. 

		PROC StateCell
		; first get the coordinates
		; calculate the index 
		; mov the index to the right register
		; test on 0 
		; if zero, return value 0
		; else return value 1
		push ebp 
		mov ebp, esp 
		push eax 
		push ebx 
		push edx 
		push esi 
		mov eax, [ebp+8]	
		mov ebx, [ebp+12]

		push ebx 		; pass the parameters form the function StateCell
		push eax 
		call Index 		; fetch the index of the needed cell
		sub esp, 8		; pop the arguments form the stack 
		
		
		mov esi, eax 	; mov the returned value to the source index 
		mov eax, [gridArray+esi] ; mov the value from the array to the register to return the value 
						; the value of the cell is put in edx to return as result from the function call

	;	mov eax, 0

		;debug code 
	;	cmp eax, 1
	;	je @@print 
	;	cmp eax, 0
	;	je @@print0
	;	jp @@continue
	;	@@print: 
	;	  mov ah, 09h                     ; AH=09h - Print DOS Message
    ;    mov edx, offset _msg1           ; DS:EDX -> $ Terminated String
    ;    int 21h                         ; DOS INT 21h

    ;    mov eax, 0h
    ;    int 16h
    ;    jp @@continue

    ;    @@print0: 
	;	  mov ah, 09h                     ; AH=09h - Print DOS Message
    ;    mov edx, offset _msg0          ; DS:EDX -> $ Terminated String
    ;    int 21h                         ; DOS INT 21h

    ;    mov eax, 0h
    ;    int 16h
    ;    jp @@continue
    ;     @@continue:
        ; end debug 

      
		pop esi 
		pop edx 
		pop ebx 
		pop eax
		mov esp, ebp 
		pop ebp 
		ret
		ENDP StateCell

		; Author: Asma Oualmakran
		; Function: CheckField
		; Parameters: 
			; grid 
				; Type: 2 dimensional array
			 	; Use: The grid where the states of the cells are defined.
			 	; Constraint: N/a
		; Returns: 
		; Use: Check the states of the cells in the grid.

		PROC CheckField

		@@loop:


		ENDP CheckField

		

		

		; Author: Asma Oualmakran
		; Function: StateCell
		; Parameters:
			; grid 
				;
			; x 
				; Type: intiger
				; Use: The x-coordinate of the cell. 
				; Constraint: larger or equal to 0 and smaller than the gridWidth
			; y
				; Type: intiger
				; Use: The y-coordinate of the cell. 
				; Constraint: larger or equal to 0 and smaller than the gridHeight
		; Returns: State of the cell. 
		; Use: Get the state of a cell from the grid. 

		;PROC StateCell

		;ENDP StateCell

		; Author: Asma Oualmakran
		; Function: IncGeneration
		; Parameters: N/a 
		; Returns: N/a 
		; Use: Increment the generation counter. 

		;PROC IncGeneration

		;ENDP IncGeneration

		; Author: Asma Oualmakran
		; Function: ResetGeneration
		; Parameters: N/a 
		; Returns: N/a 
		; Use: Set the generation counter to zero.

		;PROC ResetGeneration

		;ENDP ResetGeneration

		; Author: Asma Oualmakran
		; Function: InitGeneration
		; Parameters: N/a 
		; Returns: N/a 
		; Use: Initiate the generation counter before the game starts. 

		;PROC InitGeneration


		;ENDP InitGeneration

		

;------------------------------------------------------------------------------
start:

        sti                             ; Set The Interrupt Flag
        cld                             ; Clear The Direction Flag

        push ds 						; Put value of DS register on the stack
        pop es 							; And write this value to ES
        mov ah, 10
        mov al, 0


        @@gameloop:
        mov  eax, 08h
        push eax
        push eax
        call AwakeCell
       ; sub esp, 8 ; pop the arguments form the stack 
        add esp, 8	; put the stackpointer to it's original location

        push eax 
        push eax 
        call StateCell
        add esp, 8
		; Your code comes here
	;	@@coordianteSmall:
	;	mov ah, 09h                     ; AH=09h - Print DOS Message
  ;      mov edx, _msgS           	 	; DS:EDX -> $ Terminated String
    ;    int 21h    
	;	jp gameloop:

	;	@@coordinateLarg:
	;	mov ah, 09h                     ; AH=09h - Print DOS Message
 ;       mov edx, _msgL           		; DS:EDX -> $ Terminated String
    ;    int 21h    
	;	jp gameloop:

        mov eax, 4c00h                  ; AH = 4Ch - Exit To DOS
        int 21h                         ; DOS INT 21h

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
; DATA
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
DATASEG

	; Your data comes here
	gridArray dd gridSize dup (0)	; dd 
	generation dd 0 				; het tellen van generaties dd -> een intiger of floating point getal 

	; errors and information strings
	_msg1 db 'equal 1', 10, 13, '$'
	_msg0 db 'equal 0', 10, 13, '$'
	_msgS db 'One of your coordinates are too small', 10, 13, '$'
	_msgL db 'One of your coordinates are too large', 10, 13, '$'
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
; STACK
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
STACK 1000h

END start
