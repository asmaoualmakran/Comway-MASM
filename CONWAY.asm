;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
; 32-bit Assembly Example
;
; Empty asm example.
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
; CODE
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
CODESEG

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°?
; Entry To ASM Code
; In:
;   CS - Code Selector    Base: 00000000h - Limit: 4G
;   DS - Data Selector    Base: 00000000h - Limit: 4G
;   ES - PSP Selector     Base: PSP Seg   - Limit: 100h
;   FS - ?
;   GS - ?
;   SS - Data Selector    Base: 00000000h - Limit: 4G
;   ESP -> STACK segment
;   Direction Flag - ?
;   Interrupt Flag - ?
;
;   All Other Registers Are Undefined!
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°?

; argumenten popen op het einde 
; alles naar 32bit 
; evenveel pushen als poppen 
;behalve in het geval van een Function call sub esp 8 (gelijk aan 2 keer pop)


; Call gaat een unconditional jump doen naar een subprogramma en gaat het adres van de volgende instructie op de stack pushen
; RET gaat de adres poppen en naar dat adres jumen 
; Na return zijt je aan de volgende instructie na de call, je gaat daar verder doorgaan 
;dit is een test
;---------------Variables--------------- variables in this way work 
gridWidth	equ 10
gridHeight	equ 10
gridSize 	equ gridWidth * gridHeight
blockWidth 	equ 10
blockHeight equ 10
blockColor 	equ 000

;---------------------------------------

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
		push ebx 
		push ecx
		push edx 
	

		mov ecx, 0
    	mov ebx, 10
		@@loop:
    	mov edx, 0
    	div ebx                          ;divide by ten

    	

    ; now ax <-- ax/10
    ;     dx <-- ax % 10

    ; print dx
    ; this is one digit, which we have to convert to ASCII
    ; the print routine uses dx and ax, so let's push ax
    ; onto the stack. we clear dx at the beginning of the
    ; loop anyway, so we don't care if we much around with it

    	push eax
    	add dl, '0'                     ;convert dl to ascii otherwise it wont print the value

    	pop eax                          ;restore ax
    	push edx                         ;digits are in reversed order, must use stack
    	inc ecx                          ;remember how many digits we pushed to stack
    	cmp eax, 0                       ;if ax is zero, we can quit
		jnz @@loop

   		 ;cx is already set
 	   mov ah, 02h                       ;2 is the function number of output char in the DOS Services.
		@@popStack:
    	pop edx                          ;restore digits from last to first
    	int 21h                         ;calls DOS Services
    	loop @@popStack

    	pop edx
    	pop ecx 
    	pop ebx 
		pop eax 
		mov esp, ebp 
		pop ebp
		ret
		ENDP PrintDigit



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

		push ebp 
		mov ebp, esp
	;	push eax 
		push ebx 
		push edx 


		mov eax , [ebp+8] 	; take the value of LAST pushed argument
		mov ebx , [ebp+12] 	; take the value of FIRST pushed argument
							; index = (x-1)*gridWidth+y
							; eax contains x-coordinate, ebx contains y-coordinate

							; ebx contains the x-value, eax contains the y-value
		dec eax 
	;	mov edx, eax 		; mov the value of eax to not lose it's value
		imul eax, eax, gridWidth	; multiply the x-value with the gridWidth and place the result back in ebx  
		add eax, ebx		; the addition of the formula
	;	mov eax, ebx 		; mov to the register eax to return the value  
		  

	;	push esi 
	;	call PrintDigit
	;	add esp, 4

	;;	pop esi 
		pop edx
		pop ebx 
	;	pop eax 
		mov esp, ebp 		; restore the or iginal s tack pointer
		pop ebp 			; retrieve the or iginal base pointer
		ret 				; return to next instruction after the call

		ENDP Index 

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


		mov eax, [ebp+8]     ; contains the x value
		mov ebx, [ebp+12]	 ; contains the y value 

		push ebx 			 ; push argument in opposit order 
		push eax 
		call Index 			 ; calculate the location of the element in the array 
		add esp, 8			 ; the result of it is located in eax

		mov ebx, [gridArray]	; place the element on the location in ebx 
		;--------------
		;debug 
		push ebx
		call PrintDigit
		add esp,4
		;-------------

		pop eax 
		pop ebx 
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


;		PROC AwakeCell
;
;;		push ebp 
;		mov ebp, esp
;		push eax 
;		push ebx 
;		push edi 
;		push esi
;
;
;		mov eax, [ebp+8]
;		mov ebx, [ebp+12]
;
;		push eax 
;		push ebx 
;		call Index
;		add esp, 8
;
;		mov edi, gridArray
;
;		add edi, esi 
;		mov edi, 1
;
;		ret
;
;		ENDP AwakeCell

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

;		PROC StateCell
;
;		push ebp
;		mov ebp, esp
;		push eax 
;		push ebx
;		push edx 
;		push edi 
;		push esi
;
;		mov eax, [ebp+8]
;		mov ebx, [ebp+12]
;
;		push eax 
;		push ebx 
;		call Index
;		add esp, 8
;
;		mov eax, esi ;place the calculated index in the right register
;		mov edi, gridArray
;
;		add edi, esi 
;		mov edx, [edi]		; acces the content on the adress to be able to return it 
;
;							; don't pop edx, to be abel to retrun the result, by popping it you're restoring it to the stack value
;		push edx 
;		call PrintDigit
;		add esp, 4
;
;		pop esi 
;		pop edi 
;		pop ebx 
;		pop eax 
;
;		ret
; convention values are returned in eax, chars int, pointer values 
;		ENDP StateCell



start:

        sti                             ; Set The Interrupt Flag
        cld                             ; Clear The Direction Flag

        push ds 						; Put value of DS register on the stack
        pop es 							; And write this value to ES


		mov eax, 3
		mov ebx, 5
		push ebx ; push the secon argument
		push eax ; push the first argument
		call Index
		add esp, 8

		push eax
		push ebx 
		call KillCell
		add esp, 8
	;	mov eax, 4
	;	mov ebx, 5
	;	push eax 
	;	push ebx 
	;	call StateCell
	;	add esp, 8
	;	push eax 
	;	call PrintDigit
	;	add esp, 4

	;	push eax 
	;	push eax 
	;	call KillCell
	;	sub esp, 4

        mov eax, 4c00h                  ; AH = 4Ch - Exit To DOS
        int 21h                         ; DOS INT 21h

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
; DATA
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
DATASEG

	; Your data comes here
	gridArray dd gridSize dup (0)	; dd 
	generation dd 0 				; het tellen van generaties dd -> een intiger of floating point getal 
	colorArray dd 000 				; hier moeten er nog de kleuren in komen  

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
