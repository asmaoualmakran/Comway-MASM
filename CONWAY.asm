IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
; CODE
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
CODESEG

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
		push ebx 			; save EBX value
		mov eax , [ebp+8] 	; take the value of LAST pushed argument
		mov ebx , [ebp+12] 	; take the value of FIRST pushed argument

		mov ecx, ebx 		; mov ebx so you can multiply and the result put in ebx (result of multiplication is in ebx) the y-coordinate is in ebx, so it needs to be moved
		mov ebx, gridWidth	; use if formula index = (x-1)*row-width+y
		dec eax 			; decrement the x-coordinate (start counting from 0 in the grid)
		mul eax 			; multiply the decremented x value with the row-width
		add ebx, ecx		; add the y-coordinate you moved before to the ecx register 
							; result is in ebx (add puts the result in the first operand, so no mov needed to return the value)
		;mov ah, 09h			; print result taken from example hello
		;mov edx, ebx

		mov edx, gridWidth  ; the edx contains the charakter that needs to be printed 
		mov ah, 02h
		int 21h

		mov eax, 0h	
		int 16h

		pop ebx 			; restore the or iginal EBX value
		mov esp, ebp 		; restore the or iginal s tack pointer
		pop ebp 			; retrieve the or iginal base pointer
		ret 				; return to next instruction after the call
		
		ENDP Index

		; Author: Asma Oualmakran
		; Function: CheckField
		; Parameters: 
			; grid 
				; Type: 2 dimensional array
			 	; Use: The grid where the states of the cells are defined.
			 	; Constraint: N/a
		; Returns: 
		; Use: Check the states of the cells in the grid.

		;PROC CheckField

		;ENDP CheckField

		; Author: Asma Oualmakran
		; Function: KillCell
		; Parameters: 
			; grid 
				;
			; x 
				; Type: intiger
				; Use: The x-coordinate of the cell who needs to be killed. 
				; Constraint: larger or equal to 0 and smaller than the gridWidth
			; y
				; Type: intiger
				; Use: The y-coordinate of the cell who needs to be killed. 
				; Constraint: larger or equal to 0 and smaller than the gridHeight
		; Returns:
		; Use: Set the state of a living cell to dead.

	;	PROC KillCell
		

	;	ENDP KillCell

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

		;PROC AwakeCell

		;ENDP AwakeCell

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

        @@gameloop: 
        push 5
        push 6
        call Index
        add esp, 8
		; Your code comes here


        mov eax, 4c00h                  ; AH = 4Ch - Exit To DOS
        int 21h                         ; DOS INT 21h

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
; DATA
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
DATASEG

	; Your data comes here
	gridArray db gridSize dup (0)
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
; STACK
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
STACK 1000h

END start

