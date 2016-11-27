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

;---------------Variables--------------- variables in this way work 
gridWidth	equ 80
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
		mov ah, 0
		mov al , [ebp+8] 	; take the value of LAST pushed argument
		mov bh, 0
		mov bl , [ebp+12] 	; take the value of FIRST pushed argument
							; index = (x-1)*gridWidth+y
							; al contains x-coordinate, bl contains y-coordinate

		; here test if values in range

		dec al              ; x-1
		mov dh, 0			; place gridWidth in register dl
		mov dl, gridWidth
		mul dl 				; multiply (x-1) with gridWidth
		add ax, bx 			; add the result of the multiplication with the y-coordinate
							; the result is stored in ax
		mov cx, 48
		add ax, cx
		;print the result 
		mov cx, ax
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
		push ebx 
		mov eax, [ebp+8]	; value of the last argument pushed (pm1) y
		mov ebx, [ebp+12]	; value of the first argument pushed (pm2)

		push ebx
		push eax 
		call Index 			; ebx contains the result afther the call
		
		mov di, ax			; move the result of the procedure in the right register
		mov [gridArray+si], 0			; put the value in the array on the right array location

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

		PROC AwakeCell
		push ebp
		mov ebp, esp 
		push ebx 
		mov eax, [ebp+8]	; value of the last argument pushed (pm1) y
		mov ebx, [ebp+12]	; value of the first argument pushed (pm2)

		push ebx
		push eax 
		call Index 			; ebx contains the result afther the call
		
		mov di, ax			; move the result of the procedure in the right register
		mov [gridArray+si], 1			; put the value in the array on the right array location

		pop ebx
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

		PROC StateCell

		ENDP StateCell

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
        push 10
        push 10
        call KillCell
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
	generation dd 0 				; het tellen van generaties dd -> een intiger of floating point getal 
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
; STACK
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
STACK 1000h

END start

