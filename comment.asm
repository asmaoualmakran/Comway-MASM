IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

include DATA.asm
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
; CODE
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
_CODESEG

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
		;Use: Converts the coordinates of the cell into an index in the gridArray.

		;PROC Index
		
		;ENDP Index




; je kan een data segment gebruiken om error codes te definieren 

_CODESEG ENDS

_DATASEG

_DATASEG ENDS


STACK 1000h

