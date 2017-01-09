IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
; CODE
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
CODESEG


; argumenten popen op het einde 
; alles naar 32bit 
; evenveel pushen als poppen 
;behalve in het geval van een Function call sub esp 8 (gelijk aan 2 keer pop)


; Call gaat een unconditional jump doen naar een subprogramma en gaat het adres van de volgende instructie op de stack pushen
; RET gaat de adres poppen en naar dat adres jumen 
; Na return zijt je aan de volgende instructie na de call, je gaat daar verder doorgaan 
;dit is een test
;---------------Macro's--------------- 

; Grid macro's 
gridWidth	equ 10
gridHeight	equ 10
gridSize 	equ gridWidth * gridHeight ; the number of elements in the grid = the length of the gridArray
blockWidth 	equ 15
blockHeight equ 12			; the height is less than the width 
							; due to the thickness of the lines, if you take the same height as width, it will form a rectangle

;video Macro's
vidBufferAdress	equ 0a0000h
windowWidth		equ 320  ; the window width in pixels
windowHeight	equ 200 ; the window height in pixels 
vidBuffSize		equ windowHeight * windowWidth ; the length of the videobuffer
bufferArray 	equ [_bufferArray]	; the adres of the bufferarray for dual buffering 

; Macro's for the adresses of the grids
gridAdres 		equ [_gridArray]
gridAdres2		equ [_gridArray2]
endSymbol 		equ '='

;Color Macro's 
;colour pallet starts from 0 to 15
black		equ 0
darkBlue 	equ 1
green 		equ 2
lightBlue 	equ 3
red 		equ 4
purple 		equ 5
orange 		equ 6
lightGray 	equ 7
darkGray	equ 8
bluePurple 	equ 9
grenBright	equ 10
blueBright 	equ 11
ligtRed		equ 12
lila 		equ 13
yellow 		equ 14 
white 		equ 15


background  equ lightGray	; the color of the background
alive 		equ red 		; color of a living cell 
dead		equ black		; color of a dead cell 
resurrect 	equ 3			; the number of living neighbouring cells needed to resurrect a cell 
keepAlive	equ 2			; number of living neighbouring cells to keep a cell alive 
;---------------------------------------

; Author: Asma Oualmakran
; Function: Index
; Parameters: 
	; y:
		; Type: intiger 
		; Use: y-coordinate of the cell. 
		; Constraint: larger or equal to 0 and smaller than gridHeight.
	; x: 
		; Type: intiger
		; Use: x-coordinate of the cell. 
		; Constraint: larger or equal to 0 and smaller than gridWidth.
	; Adres Array: 
		; Type: Macro 
		; Use: The length of the used array. 
		; Constraint: N/a 
; Returns: An index in an array.
; Use: Converts the coordinate of an pixel or an cell into an index of the used array (formula: index =  width*y+x.

		PROC Index

		push ebp 
		mov ebp, esp 
		
		; eax contains the y coordinate
		; ebx contains the x coordinate
		; ecx contains the widht of the grid -> set by SetWidth
		; esi contains the array where the location is needed 

		push ebx 
		push ecx 
		push edx 
		push esi 

		mov eax, [ebp+8]	; y coordinate
		mov ebx, [ebp+12]	; x coordinate
		mov esi, [ebp+16]	; array 

		push eax 	; save the y coordinate

		push esi 	; get the width of the grid 
		call SetWidth
		add esp, 4 

		mov ecx, eax ; mov the width into ecx 

		pop eax 	 ; restore the old value of eax (x coordinate)

		imul ecx 

		add eax, ebx

		pop esi 
		pop edx 
		pop ecx 
		pop ebx 

		mov esp, ebp 
		pop ebp

		ret
		ENDP Index


; Author: Asma Oualmakran 
; Function: GetCoordinates 
; Parameters: 
	; Index: 
		; Type: Intiger
		; Use: The index of the element who's coordinates are needed.
		; Constraint: N/a 
	; Array: 
		; Type: Adres 
		; Used: The adres of the array who containts the element.
		; Constraint: N/a 
; Returns: The x-coordinate and the y-coordinate of the selected element 
; Use: Calculate the coordinates of an element based on the index of the element and the array that contains that element. 

; In the result of the function 
; eax contains the y-coordinate -> divide by the gridWidth
; edx contains the x-coordinate -> remainder --> mod 

		PROC GetCoordinates

		push ebp 
		mov ebp, esp 

		push ebx 
		push ecx 

		mov eax, [ebp+8]	; contains the index of the element
		mov ebx, [ebp+12]	; contains the adres of the array 

		push eax 			; save the index

		push ebx 
		call SetWidth
		add esp, 4

		mov ebx, eax 	; set ebx to the width of the grid

		pop eax 		; restore the index
	
		cmp eax, ebx 
		jl @@widthL 	; if the index is smaller than the width of the grid
						; you know that the y-coordinate = 0 and x-coordinate = index 
						; if you don't test it, the code will crash when you try to divide/ modulo 

		mov edx, 0 		; need to set edx to 0 -> otherwise div will crash
		div ebx			; this wil store the y-value in eax -> quotient 
						; and store the x-value in edx -> remainder which is the same as mod 

		jmp @@stop		; skip the rest of the code 

		@@widthL:
		mov edx, eax		; we know that the x-coordinate equals to the index 
		mov eax, 0	
		; eax -> y coordinate
		; edx -> x coordinate

		@@stop:

						; the result is returned in eax, edx (eax contains the quotient -> y coordinate, edx contains the remainder
						; -> restult of mod) it's returned that way by div, no need to change it.
		
		pop ecx 
		pop ebx 

		; we don't pop eax and edx, they are needed to pass the coordinates

		mov esp, ebp
		pop ebp 

		ret
		ENDP GetCoordinates

; Author: Asma Oualmakran
; Function: CalcDispl 
; Parameters: 
	; Index: 
		; Type: Intiger
		; Use: The index of the element in the gridArray
		; Constraint: N/a 
	; Source Array: 
		; Type: Adres 
		; Use: The array that represents the grid.
		; Constraint: N/a 
	; BufferArray: 
		; Type: Adres
		; Use: The adres of the buffer 
		; Constraint: N/a 
; Use: Calculate the index with the coordinate displacement.
; Returns: The displaced index. 
		
		PROC CalcDispl

		push ebp 
		mov ebp, esp 

		push ebx
		push edx 
		push esi 
		push edi 

		mov eax, [ebp+8]
		mov esi, [ebp+12]
		mov edi, [ebp+16]

		push esi 
		push eax 
		call GetCoordinates
		add esp, 8

		push edx 			; need to save edx before multiplocation, otherwise it's value will be lost

		mov ebx, blockHeight

		imul ebx 			; calculate the displaced y-coordinate

		pop edx 			; restore the x-coordinate

		push eax 			; save the displaced y-coordinate, pop and push needs to be done in this order 	

		mov eax, edx 		; mov the x coordinate tot eax, to be able to multiply it 
		mov ebx, blockWidth
		imul ebx 

		mov edx, eax 		; place the displaced x-coordinate back into edx 

		pop eax 			; restore the displaced y-coordinate

		push edi 
		push edx 
		push eax 
		call Index
		add esp, 12 

		pop edi 
		pop esi 
		pop edx 
		pop ebx 
		; value is returned in eax 
		mov esp, ebp
		pop ebp 

		ret
		ENDP CalcDispl


; Author: Asma Oualmakran
; Function: SetArraySize
; Parameters: 
	; ArrayAdres
		; Type: Adres 
		; Use: The adres of the used array 
		; containts: N/a 
; Returns: The size of the used array 
; Use: Select the right array size 

; This function enables automatic size selection 
; we could adjust the function and make it calculate the 
; length of the array by ending the array with an end symbol 
; by looping over the array until you reach that symbol and count every entry 
; end result is the length of the array (end -> at array-length +1)
; we can't use this method for the buffer arrays, this is why we 
; chose for this solution

		PROC SetArraySize

		push ebp
		mov ebp, esp

		; no need to push and pop eax, eax is used to return the size of the array 

		mov eax, [ebp+8]

		cmp eax, vidBufferAdress
		je @@bufferAdress

		cmp eax, offset _gridArray
		je @@gridArray

		cmp eax, offset _gridArray2
		je @@gridArray

		@@bufferAdress: 
		mov eax, vidBuffSize
		jmp @@stop

		@@gridArray:
		mov eax, gridSize
		jmp @@stop 

		@@stop: 

		mov esp, ebp
		pop ebp

		ret 
		ENDP SetArraySize 


; Author: Asma Oualmakran
; Function: SetWidth
; Parameters: 
	; ArrayAdres: 
		; Type: Adres 
		; Use: The adres of the array where we need the width of (not the length)
		; Constraint: The array must be used as a grid, two dimenstional array 
; Returns: The width of the grid
; Use: Get the width of a grid 

		PROC SetWidth 

		push ebp
		mov ebp, esp 

		; no need to push and pop eax, it is used to return the width of the grid 

		mov eax, [ebp+8]

		cmp eax, vidBufferAdress 
		je @@bufferAdress

		cmp eax, offset _gridArray
		je @@gridArray

		cmp eax, offset _gridArray2
		je @@gridArray

		@@bufferAdress:
		mov eax, windowWidth
		jmp @@stop 

		@@gridArray: 
		mov eax, gridWidth
		jmp @@stop

		@@stop:

		mov esp, ebp
		pop ebp

		ret 
		ENDP SetWidth


; Author: Asma Oualmakran
; Function: SetHeight
; Parameters: 
	; ArrayAdres:
		; Type: Adres 
		; Use: The adres of the array where we need the height of (not the length)
		; Constraint: The array must be used as a grid, two dimenstional array 
; Returns: The height of the grid
; Use: Get the height of a grid

		PROC SetHeight 

		push ebp
		mov ebp, esp

		; no need to push and pop eax, it is used to return the height of the grid 

		mov eax, [ebp+8]

		cmp eax, vidBufferAdress 
		je @@bufferAdress

		cmp eax, offset _gridArray
		je @@gridArray

		cmp eax, offset _gridArray2
		je @@gridArray

		@@bufferAdress:
		mov eax, windowHeight
		jmp @@stop 

		@@gridArray: 
		mov eax, gridHeight
		jmp @@stop

		@@stop:

		mov esp, ebp
		pop ebp

		ret 
		ENDP SetHeight

; Author: Asma Oualmakran
; Function: InGrid 
; Parameters: 
	; y-coordinate: 
		; Type: Intiger
		; Use: The y-coordinate of the cell
		; Constraint: N/a 
	; x-coordinate
		; Type: Intiger
		; Use: The x-coordinate of the cell 
		; Constraint: N/a
	; Array 
		; Type: Adress 
		; Use: The adres of the array used to represent the grid. 
		; Constraint: N/a 
; Returns: 0 if the cell is out of bounds, 1 if it is in bounds

		PROC InGrid 

		push ebp 
		mov ebp, esp 

		push ebx 
		push esi

		mov eax, [ebp+8]		; y-coordinate
		mov ebx, [ebp+12]		; x-coordinate
		mov esi, [ebp+16]		; array

		push esi 
		push ebx 
		push eax 
		call Index 			; calculate the index with the coordinates
		add esp, 12 		; the index of the element is eax


		push esi 			; check if eax is in bounds of the array 
		push eax 
		call InBounds
		add esp, 8		 

		pop esi 
		pop ebx 

		mov esp, ebp 
		pop ebp

		ret 
		ENDP InGrid


; Author: Asma Oualmakran 
; Function: InBounds 
; Parameters: 
	; Index: 
		; Type: intiger 
		; Use: The index of an element in an array. 
		; Constraint: N/a 
	; Array adres: 
		; Type: Adres 
		; Use: The used array where the bounds must be checked.
		; Constraint: N/a 
; Returns: 0 or 1, 0 if the element is out of bounds of the array. 1 if the element is in bounds of the array. 
; Use: Print an message if the element is to large or the small. Used as a boolean to check if an index is in bounds of an array. 

		PROC InBounds

		push ebp
		mov ebp, esp

		push ebx
		push esi 

		mov eax, [ebp+8]		; the index 
		mov esi, [ebp+12]		; the array where the length of it is needed 

		push eax 	; save the given index 

		push esi 	; set the length of the array 
		call SetArraySize
		add esp, 4 

		mov ebx, eax 	; ebx contains the array size 
		pop eax 		; restore the saved value of eax 

		cmp eax, ebx    ; Make sure that the Index is in bounds of the array. 
		jge @@outBounds	; index is from 0 - length-1 if it is equal to the length or larger -> out of bounds

		cmp eax, 0		
		jl @@outBounds	; if the index is smaller than 0, you are out of bounds on the left side of the array 

		jmp @@inBounds 	; If you reach here, your index is in bounds of the array 

		@@inBounds:		; if you jump to here, the element is in bounds 

		mov eax, 1
		jmp @@stop

		@@outBounds:
		mov eax, 0	

		@@stop:

		pop esi 
		pop ebx 

		mov esp, ebp
		pop ebp

		ret
		ENDP InBounds

; Author: Asma Oualmakran
; Function: GetValue 
; Parameters: 
	; Index: 
		; Type: intiger
		; Use: The index of an element in the array 
		; Constraint: Larger or equal to 0 and smaller than the length of the array. 
	; Array adres: 
		; Type: adres
		; Use: The adres of the array 
		; Constraint: Must be an adres of a byte array. 
	
; Returns: The value on a location in a array.
; Use: Get the value of an element from an array.

		PROC GetValue

		push ebp 
		mov ebp, esp

		push edx 
		push esi 

		mov edx, [ebp+8]		; the index 
		mov esi, [ebp+12]		; the array where the element is needed of 

		push esi
		push edx 
		call InBounds 		; call this predicate to check if the element is in bounds 
		add esp, 8

		cmp eax, 0			; if it out of bounds eax wil return 0 and jump to the end 
		je @@stop 
		
		add esi, edx
		lodsb

		@@stop:

		pop esi 
		pop edx 

		mov esp, ebp
		pop ebp

		ret 
		ENDP GetValue

; Author: Asma Oualmakran
; Function: SetValue 
; Parameters: 
	; value: 
		; Type: Intiger
		; User: The value to be set in the array.
		; Constraint: N/a 
	; Index: 
		; Type: intiger
		; Use: The index of an element in the array 
		; Constraint: Larger or equal to 0 and smaller than the length of the array  
	; Array adres: 
		; Type: adres
		; Use: The adres of the array 
		; Constraint: Must be an adres of a byte array.
; Returns: N/a
; Use: Set an value in the array.

		PROC SetValue 
 
 		; make sure that the value to be set is placed in al 
 		; otherwise it is to large to be set in the byte array
		push ebp 
		mov ebp, esp 

		push eax 
		push edx 
		push edi 

		; in this case the value to be set is contained by eax 
		; due to stosb will read the value of eax to place it in the array 
		; by useing the register this way, there are no extra moves needed to place the 
		; value to be set in the right register 

		mov eax, [ebp+8]	; containts the value to be set.
		mov edx, [ebp+12]	; containts the index. 
		mov edi, [ebp+16]	; containts the adres of the array 


		push edx
;		call PrintDigit
		add esp, 4

		push eax 	; save eax, it will be altered by InBounds

		push edi 
		push edx 
		call InBounds 	; call the predicate to check if the index is in bounds of the array 
		add esp, 8 

		cmp eax, 0 
		je @@stop 		; if the condition is met, the element is out of array bounds 

		pop eax 		; restore the value of eax 

		add edi, edx 	; add the index to the adres to have the correct offset 
		stosb			; save the value of eax, at the location contained by edi

		@@stop:
																		
		pop edi 
		pop edx
		pop eax 

		mov esp, ebp 
		pop ebp

		ret
		ENDP SetValue

; Author: Asma Oualmakran
; Function: GenerationExtinct
; Parameters: 
	; Array: 
		; Type: ArrayAdres
		; Constraint: N/a 
		; Use: The array who's next generation needs to be calculated.
; Returns: 0 or 1, if there is no cell alive, it will return 1.
; Use: Boolean to check if there is at least one cell alive.
		
		PROC GenerationExtinct

		push ebp 
		mov ebp, esp 

		push edx 
		push esi 

		mov esi, [ebp+8]

		mov edx, 0 	; the index 

		@@Loop: 

		push esi 
		push edx
		call InBounds
		add esp, 8

		cmp eax, 0		; when you are out of bounds, you went through the entire array
		je @@Extinct 		; and didn't find a living cell

		push esi 		; get the value located on the index in the array 
		push edx 
		call GetValue
		add esp, 8

		cmp eax, dead 	; check if the cell is dead 
		jne @@NotExtinct		; if it's not you set eax to 0

		jmp @@Loop 		; if it is, you loop 
		inc edx 		; increment the index 

		@@NotExtinct:		; you found ONE living cell 
		mov eax, 0
		jmp @@Stop

		@@Extinct:				; you looped the whole array and avent found one linving cell 
		mov eax, 1

		@@Stop:

		pop esi 
		pop edx

		mov esp, ebp
		pop ebp

		ret
		ENDP GenerationExtinct

; Author: Asma Oualmakran
; Function: IsAlive
; Parameters: 
	; y-coordinate: 
		; Type: Intiger 
		; Use: The y-coordinate of the cell who's state is needed. 
		; Constraint: N/a 
	; x-coordinate: 
		; Type: Intiger
		; Use: The x-coordinate of the cell who's state is needen. 
		; Constraint: N/a 
	; gridArray: 
		; Type: ArrayAdres
		; Use: The array that represents the grid. 
		; Constraint: N/a 
; Returns: It returns 0 when the cell is dead, and 1 when the cell is alive 
; Use: Determine the state of a cell, based on coordinates. 

		PROC IsAlive 

		push ebp 
		mov ebp, esp 

		push ebx 
		push edx 
		push esi 

		mov eax, [ebp+8]		; y-coordinate
		mov edx, [ebp+12]		; x-coordinate
		mov esi, [ebp+16]		; the gridAdres

		cmp eax, 0 
		jl @@Dead 

		push eax 				; save the y coordinate, we need to compare it 
								; with the height of the array
		push esi 
		call SetHeight
		add esp, 4 

		mov ebx, eax 			; mov the height to ebx to be able to compare 

		pop eax 				; restore the y coordinate

		cmp eax, ebx			 
		jg @@Dead 				; if the value of the y coordinate  is greater than the 
								; height, you are out of bounds of the grid. 
		cmp edx, 0 				
		jl @@Dead 				; if the value of the x coordinate is smaller than 0 
								; you are out of bounds of the grid 
		push eax 				; save the y coordinate

		push esi 
		call SetWidth			; get the width of the grid 
		add esp, 4 

		cmp edx, eax 
		jg @@Dead 				; if the value of the x coordinate is greater than 
								; the width of the grid, then you are out of bounds 
		pop eax 				; restore the y coordinate

		push esi 
		push edx 
		push eax 
		call Index 				; calculate the index of the cell in the array 
		add esp, 12 			; eax will contain the index 

		push esi 
		push eax 
		call GetValue			; get the value located at the index in the array 
		add esp, 8 

		cmp eax, 0 			; compare the retreived value to the value of dead  
		je @@Dead 				; if they are ecual -> jump to dead 

		@@Alive: 				; if the cell is alive you retrun 1 

		mov eax, 1
		jmp @@Stop 

		@@Dead: 

		mov eax, 0 				; the cell is dead or out of bounds, you retrun 0

		@@Stop: 

		pop esi 
		pop edx 
		pop ebx 

		mov esp, ebp 
		pop ebp

		ret 
		ENDP IsAlive

; Author: Asma Oualmakran
; Function: CalcNextState
; Parameters: 
	; Number of living cells: 
		; Type: Intiger 
		; Constraint: N/a 
		; Use: The number of living neighbouring cells 
	; Index current cell: 
		; Type: Intiger
		; Constraint: In bounds of the used array 
		; Use: The location of the current cell in it's array 
	; Array:
		; Type: Adres 
		; Constraint: N/a 
		; Use: The current grid that is used 

		PROC CalcNextState 

		push ebp 
		mov ebp, esp 
		
		mov ebx, [ebp+8]   ; number of counted living cells 
		mov edx, [ebp+12]  ; the index of the current cell 
		mov esi, [ebp+16]  ; the array where the current cell is located

		push esi 
		push edx 
		call GetCoordinates	; extraxt the coordinates of the current cell 
		add esp, 8 
		
		
		push esi 
		push edx
		push eax 		 
		call IsAlive 		 ; get the state of the current cell 
		add esp, 12 
		
		cmp eax, 0 
		je @@Dead
		
		; in this case the cell is alive 
		dec ebx 		 	; if the current cell is alive, we need to correct the value 
							; the cell itself is counted for as a living neighbouring cell 
		cmp ebx, keepAlive 
		je @@Resurrect ; if the number of living neighbouring cells equals to one of these 
							; two numbers, the cell lives in the next generation 
		
		cmp ebx, resurrect 
		je @@Resurrect 
		
		jmp @@Kill 			; if it isn't equal, the cell dies in the next generation
		
		@@Dead: 			; if the cell is dead, no correction is needed 
		
		cmp ebx, resurrect 	; if the number of living neighbouring cells equals resurrect
		je @@Resurrect 		; it lives in the next generation
		
		@@Kill: 			; if the cell dies in the next generation
		
		mov eax, dead		; we return the value of dead 
		jmp @@Stop 
		
		@@Resurrect: 		; if the cell lives in the next generation
		
		mov eax, alive 		; we return alive 
		
		@@Stop: 
		
		pop esi 
		pop edx 
		pop ebx 
		
		mov esp, ebp 
		pop ebp 
		
		ret 
		ENDP CalcNextState


; Author: Asma Oualmakran
; Function: NextGeneration
; Parameters: 
	; Source Array: 
		; Type:
		; Constraints: 
		; Use: 
	; Destination Array: 
		; Type: 
		; Constraints: 
		; Use: 
; Returns: Transformed array 
; Use: Calculate the next generation/ new situation in the grid.
	
		PROC NextGeneration

		push ebp 
		mov ebp, esp 

		push eax 
		push ebx 
		push ecx 
		push edx 
		push esi 

		mov esi, [ebp+8]		; contains the original grid 
		mov edi, [ebp+12] 		; will contain the transformed grid 


		push esi 
		call SetArraySize 		; get the size of the array to use is as a stop 
		add esp, 4 				; condition 

		mov ebx, eax 			; move the length into ebx 

		mov ecx, 0 				; Initialize ecx to use as index in the array 

		@@MainLoop: 

		push ebx 				; save the lenght of the array 
		push ecx 				; save the index of the array 

		cmp ecx, ebx 			; when ecx = lenght of the array you  
		je FAR @@StopHere			; are at the end 

		push esi 
		push ecx 
		call GetCoordinates ; edx = x eax =y
		add esp, 8

		push ebx				; stop condition main loop 
		push edx 				; x coordinate current cell 
		push eax 				; y coordinate current cell


		;--------------------------------------------------	
		; initialise the loop over the y coordinates 		
		;--------------------------------------------------	

		mov ecx, 0				; Initialize ecx to count the linving cells

		cmp eax, 0 				; the cell is at the upperbound of the grid and has 
								; no cells above it 
		je @@UpperBound 

		cmp eax, [gridHeight-1] ; the cell is at the lowerbound of the grid and has no 
								; cells below it 
		je @@LowerBound
								; or the cell is not at the bounds  and has neighbouring cells 
								; at all sides 
		inc eax 				; the lowest point we need to check 
		mov ebx, eax 			; move y+1 into ebx to use it as stopcondition
		pop eax 				; restore the y coordinate of the current cell
		push ebx 
		dec eax 				; we start at y-1 

		jmp @@OuterLoop 		; all values are set, start loop 

		@@UpperBound: 

		inc eax 				; this is the lowest point we need to check 
		mov ebx, eax 			; move y+1 into ebx to use it as a stopcondition
		pop eax 				; restore the current y coordinate, due to the upperbound
		push ebx
								; position of the cell, we start at y 
		jmp @@OuterLoop 		; afther setting the values, start the loop 

		@@LowerBound: 

		mov ebx, eax 			; due to the lowerbound position of the cell we stop at y  
		pop eax 				; we need to pop eax, to keep the stack inorder 
		push ebx
		dec eax  				; we start the loop at y-1

		;---------------------------------------------------
		; Loop over the y coordinates
		;---------------------------------------------------
		@@OuterLoop: 
		
		pop ebx					; restore stop condition y coordinate
		pop edx 				; restore the x coordinate 

		cmp eax, ebx  			; when eax is greater than the stopcondition, we check the state of the cell
		jg @@CalcNext			; in the next generation

		push ebx 				; save the stopcondition for the y coordinate
		push edx 				; save the x coordinate of the current cell  

		;---------------------------------------------------
		; Initialize loop over the x coordinates
		;---------------------------------------------------

		cmp edx, 0 				; the cell is at the left boundry of the grid 
		je @@LeftBound 			; and has no cells on the left of it 

		cmp edx, [gridWidth-1] ; the cell is at the right boundry of the grid 
		je @@RightBound 		; and has no cells on the right of it 

		inc edx 				; x+1 is most right point where we need to check
		mov ebx, edx 			; move x+1 to ebx, to use it as a stopcondition
		
		pop edx 				; restore the current x coordinate 
		push edx 				; save the x coordinate of the current cell 
		dec edx 				; we start the loop at x-1 

		jmp @@InnerLoop 		; afther setting the values, start the loop 

		@@LeftBound: 

		inc edx 				; most right point we need to check 
		mov ebx, edx 			; move x+1 into ebx, to use it as stopcondition
		pop edx 				; we start at x 
		push edx 				; save the x coordinate of the current cell  

		jmp @@InnerLoop 		; we start the loop 

		@@RightBound:
 
		mov ebx, edx 			; due to the position of the cell, it has no right neighbouring cell 
								; we stop at x 
		pop edx 				; edx is still on the stack, we need to restore it 
		push edx 				; save the x coordinate of the current cell 
		dec edx 				; we start looping at x-1 (left neighbouring cell)

		;---------------------------------------------------
		; Inner loop, loop over the x coordinates
		;---------------------------------------------------

		@@InnerLoop: 

		push ebx 				; save the stopcondition for the InnerLoop

		cmp edx, ebx 			; when edx > ebx we checked all cells on that height inside the bounds
		jg @@NextY

		push eax 				; save the y coordinate of a neighbouring cell 
								; this register will be altered by the next proc 

		push esi 				; the register where we need the trasformation of 
		push edx 				; the x coordinate of a neighbouring cell 
		push eax 				; the y coordinate of a neighbouring cell 
		call IsAlive			; we check the state of it -> alive or dead 
		add esp, 12 

		add ecx, eax 			; is the cell is alive

		pop eax 

		inc edx 				; go to the next x coordinate 
		pop ebx  				; restore the stopcondition of the InnerLoop

		jmp @@InnerLoop 
		;---------------------------------------------------

		@@NextY: 

		inc eax 				; increment y coordinate 
		pop ebx 				; pop the stop for the x coordinate from the stack 
		
		pop edx 				; restore original x coordinate
		pop ebx 				; restore stopcondition y coordinate

		push edx 											; save the x coordinate of the current cell
		push ebx 				; save the stopcondition for the y coordinate
		jmp @@OuterLoop

		;--------------------------------------------------

		@@CalcNext: 		; calculate the state of the current cell in the next generation

		pop ebx 			; pop the stopcondition for the outerloop, it's no longer needed

		mov ebx, ecx 		; mov the number of living cells into ebx 

		pop ecx 			; restore the index of the current cell, we need this to know the state
							; of the current cell 

		push esi 			; original array 
		push ecx 			; index current cell 
		push ebx 			; number of livging neighbouring cells 
		call CalcNextState 	; calculate the next state of the cell, it's state is 
		add esp, 12 		; returned in eax 

		push edi 			; the array that contains the transformed grid 
		push ecx 			; index of the current cell 
		push eax  			; the value of the cell calculated by CalcNextState
		call SetValue 		; we place the value in the array
		add esp, 12

		@@NextIteration: 

		pop ebx 				; restore the length of the array
		inc ecx 				; increment the index of the array 

		jmp @@MainLoop

		@@StopHere: 

		pop esi 
		pop edx 
		pop ecx 
		pop ebx 
		pop eax 

		mov esp, ebp 
		pop ebp 

		ret 
		ENDP NextGeneration



; Author: Asma Oualmakran
; Function: InitVideo 
; Parameters: N/a 
; Returns: N/a 
; Use: Initialize the video mode 

		PROC InitVideo

		push ebp
		mov ebp, esp 
		
		mov ax , 13h ; specify AH=0 (set video mode) , AL=13h (320x200 )
		int 10h 	 ; call VGA BIOS

		mov esp, ebp 
		pop ebp

		ret 
		ENDP InitVideo

; Author: Asma Oualmakran
; Function: ExitVideo
; Parameters: N/a
; Returns: N/a 
; Use: Return to text mode 

		PROC ExitVideo 

		push ebp 
		mov ebp, esp 

		mov ax , 03h ; specify AH=0 (set text mode) , AL=3h (text)
		int 10h 	 ; call VGA BIOS

		mov esp, ebp 
		pop ebp 

		ret
		ENDP ExitVideo

; Author: Asma Oualmakran
; Procedure: VidoeUpade 
; Parameters: 
	; buffer: 
		; Type: Array adres 
		; Use: The array that is used as buffer 
		; Constraint: N/a 
	; videobuffer: 
		; Type: Array adres 
		; Use: The video buffer 
		; Constraint: N/a 
; Returns: N/a 
; Use: Update the window.

	proc VideoUpdate

		push ebp 
		mov ebp, esp

		push esi
		push edi
		push ecx

		mov esi, [ebp+8]
		mov edi, [ebp+12]

		cld 
 		mov ecx, vidBuffSize
 		rep movsb

 		pop ecx
 		pop edi
 		pop esi

		mov esp, ebp 
		pop ebp
		ret
		ENDP VideoUpdate

; Author: Asma Oualmakran
; Function: InitWindow
; Parameters: N/a 
; Returns: N/a 
; Use: Initialize the window, make the background one colour. 

		PROC InitWindow 

		push ebp 
		mov ebp, esp 

		push eax 
		push ecx
		push edi 

		
		mov eax, background		
		mov ecx, vidBuffSize  ; works as a counter
		mov edi, vidBufferAdress ; the index where stosb needs to start 
		rep stosb	; loops over the video buffer to set every pixel to a value 

		pop edi 
		pop ecx 
		pop eax 

		mov esp, ebp 
		pop ebp 

		ret 
		ENDP InitWindow

; Author: Asma Oualmakran
; Function: InitArray 
; Parameters: N/a 
; Retruns: initialized array (array filled with 0's)
; Use: Initialize the grid array's, fill them with 0. Tis is the initial state of the grid. 

		PROC InitArray

		push ebp 
		mov ebp, esp 

		push eax 
		push ecx 

		push edi 
		call SetArraySize	; determine the size of the array 
		add esp, 4 			; we don't need to check the bounds of the array 
							; stosb doesn't go out of bounds
		mov ecx, eax 
		mov eax, 0

	;	lea edi, gridAdres	; we only need to set ecx once 
		mov edi, offset _gridArray
		rep stosb 				; _gridArray and _gridArray2 have the same size 

	;	lea edi, gridAdres2 	; we use the macro's to get the adresses
		mov edi, offset _gridArray2
		rep stosb

		pop ecx 
		pop eax 

		mov esp, ebp 
		pop ebp 

		ret 
		ENDP InitArray

; Author: Asma Oualmakran
; Function: InitExtinct 
; Parameters: N/a 
; Returns: N/a 
; Use: Initialize the _extinct variable 

		PROC InitExtinct

		push ebp 
		mov ebp, esp

		push eax 

		mov eax, 0
		mov [_extinct], eax 

		pop eax 

		mov esp, ebp
		pop ebp

		ret 
		ENDP InitExtinct

; Author: Asma Oualmakran
; Function: IncGeneration 
; Parameters: N/a 
; Returns: N/a 
; Use: Increment the generation counter 

		PROC IncGeneration 

		push ebp 
		mov ebp, esp 

		push eax 

		mov eax, [_generation]
		inc eax 
		mov [_generation], eax 

		pop eax 

		mov esp, ebp 
		pop ebp 

		ret 
		ENDP IncGeneration

; Author: Asma Oualmakran
; Function: IncGeneration 
; Parameters: N/a 
; Returns: N/a 
; Use: Initialize the generation counter 

		PROC InitGeneration 

		push ebp 
		mov ebp, esp 

		mov [_generation], 0


		mov esp, ebp 
		pop ebp 

		ret 
		ENDP InitGeneration

; Author: Asma Oualmakran
; Function: Reset 
; Parameters: N/a 
; Returns: N/a 
; Use: Re-initialise the grid-array's, the videobuffer, the variable for extinct, (generation counter if implemented)

		PROC Reset

		push ebp
		mov ebp, esp
		; no need to push the registers, this function won't adjust them 
		; and the functions called will save and restore them 

		call InitWindow
		call InitArray
		call InitExtinct	
	
		mov esp, ebp 
		pop ebp 

		ret 
		ENDP Reset 

; Author: Asma Oualmakran
; Function: SetStartState 
; Parameters: 
	; Input Array: 
		; Type: Array adres 
		; Use: An array containing indexes of the living cells. 
		; Constraint: The length of the array must be smaller or equal to the used grid array. 
	; Grid Array: 
		; Type: Array adres 
		; Use: The array representing the grid. 
		; Constraint: N/a 
; Returns: N/a 
; Use: Set the cells on the indexes containded in the input array on "alive". 

		PROC SetStartState

		push ebp 
		mov ebp, esp 

		push eax 
		push ecx 
		push edx 

		mov esi, [ebp+8]	; the array containing the indexes for the living cells 
		mov edi, [ebp+12]	; the array containing the living cells 

		mov ecx, 0 			; ecx will act as a counter/ index of the input array 
							; we use it to loop over the array 
		@@Loop: 

		push esi 
		push ecx 
		call GetValue		; get the value of the element on index ecx from the input array 
		add esp, 8 			; eax will contain the value of the element 

		cmp eax, endSymbol	; check if the element equals the endSymbol to determine if we reached the end
							; of the array 
		je @@Stop

		push eax 			; save the index that was contained by the input array 

		push edi 
		push eax 
		call InBounds 		; check if eax (index retreived from input array)
		add esp, 8 			; is in bounds of the array 

		cmp eax, 0 
		je @@Next 			; If that index is out of bounds, you go to the next element
							; of the array
		pop eax 			; if it is in bounds, you restore the value of eax -> the index 

		mov edx, alive 		; place the value alive, it needs to be set in the array 

		push edi 			; the array that represents the grid 
		push eax 			; the index where the element needs to be set 
		push edx 			; the value that needs to be put in the array -> alive 
		call SetValue
		add esp, 12 

		@@Next: 

		inc ecx 

		jmp @@Loop 

		@@Stop: 

		pop edx 
		pop ecx 
		pop eax 

		mov esp, ebp 
		pop ebp 

		ret 
		ENDP SetStartState


; Author: Asma Oualmakran
; Function: DrawLine 
; Parameters: 
	; Color:
		; Type: Intiger
		; Use: The color of the pixel. 
		; Constraint: larger or equal to 0 and smaller or equal to 15.
	; Index: 
		; Type: Initiger 
		; Use: The index of the element in the gridArray.
		; Constraint: N/a 
	; Size: 
		; Type: Intiger
		; Use: The length of the line 
		; Constraint: Larger than 0 an smaller or equal to the width of the screen.
	; Array: 
		; Type: Adres
		; Use: The array that needs to be adjusted.
		; Constraint: N/a 
; Use: Set the elements of the video buffer, and draw a horizintal line 
; Returns: N/a 

		PROC DrawLine

		push ebp 
		mov ebp, esp 

		push eax 
		push ebx 
		push ecx 
		push edx 
		push edi 

		mov eax, [ebp+8]	; color 
		mov ebx, [ebp+12]	; index 
		mov ecx, [ebp+16]	; width 
		mov edi, [ebp+20]	; adress 

		add edi, ebx

		rep stosb

		pop edi 
		pop edx 
		pop ecx 
		pop ebx 
		pop eax 
		
		mov esp, ebp
		pop ebp  

		ret 
		ENDP DrawLine  



; Author: Asma Oualmakran
; Function: DrawSquare 
; Parameters: 
	; Index: 
		; Type: Intiger
		; Use: The index of the element in the gridArray
		; Constraint: N/a
	; source Array: 
		; Type: Adres
		; Use: The array that represents the grid 
		; Constraint: N/a  
	; BufferArray: 
		; Type: Adres 
		; Use: The array that needs to be adjusted. 
		; Constraint: N/a	
; Use: Set the elements of the video buffer, and form a square 
; Returns: N/a 

		PROC DrawSquare

		push ebp 
		mov ebp, esp 

		push eax 
		push ebx 
		push ecx 
		push edx 
		push esi 
 
		mov eax, [ebp+8]	; the index 
		mov esi, [ebp+12]	; the source array 
		mov edi, [ebp+16]	; the bufferarray

		push eax 			; save the original index  

		push esi 
		push eax 
		call GetValue		 
		add esp, 8

		mov edx, eax 		; store the value from the array (color)

		pop eax 			; restore the original index  

		push edi 
		push esi 
		push eax 
		call CalcDispl		; eax contains the displaced coordinate
		add esp, 12 		; in the bufferarray
							; we need this index to be able to draw the block on the right location in the window

		mov ebx, blockHeight 	; place the height of the block in ebx 

		mov ecx, 0			; ECX current row counter, 0 -> block height  

		@@Loop:

		push ecx 			; current row counter
		push edx 			; need to save the color, otherwise it will be altered by
							; GetCoordinates
		cmp ecx, ebx 		; current row =? blockheight
		je @@Stop 			; je not jl it starts from 0 to blockheight - 1 
							; if jl is used, it will execute one iteration to much  
		cmp ecx, 0 
		je @@ecxNotAltered

		push edi 			; the displaced array is calculated on bufferarray
		push eax 
		call GetCoordinates
		add esp, 8 

		inc eax 			; inc the y-coordinate

		push edi 
		push edx 
		push eax 
		call Index 			; calculate the index of y+1 
		add esp, 12 
		; we don't need to calculate the displacement index again 
		; that's why we use the normal indexation 

		@@ecxNotAltered:

		pop edx 			; restore the color
		mov ecx, blockWidth ; this is needed to determine the length of the lines 

		push edi 		 	; buffer 
		push ecx 			; line length
		push eax 			; displaced index 
		push edx 			; color
		call DrawLine
		add esp, 16 

		pop ecx 			; restore the iteration counter 
		inc ecx 			; increment the iteration counter, (makes the loop stop on time)

		jmp @@Loop

		@@Stop:

		pop esi 
		pop edx 
		pop ecx 
		pop ebx 
		pop eax 
		
		mov esp, ebp 
		pop ebp

		ret 
		ENDP DrawSquare 


; Author: Asma Oualmakran
; Function: DrawGrid 
; Parameters: 
	; array: 
		; Type: Array adres
		; Use: The array that represents the grid.  
		; Constraint: N/a 
	; bufferArray: 
		; Type: Array adres 
		; Use: The buffer array. 
		; Constraint: N/a
; Use: Draw the grid. 
; Returns: N/a 

		PROC DrawGrid

		push ebp
		mov ebp, esp 

		push eax 
		push ebx
		push ecx 
		push edx
		push esi 

		mov esi, [ebp+8]		; the array containing the grid that needs drawing
		mov edi, [ebp+12]		; the bufferArray

		mov ecx, 0

		@@Loop: 

		push esi 
		push ecx 
		call InBounds
		add esp, 8 

		cmp eax, 0 				; if the returned value is 0, you are out of bounds of the array 
		je @@Stop 				; --> end of your array 

		push edi 
		push esi 
		push ecx 
		call DrawSquare
		pop ecx 
		pop esi 
		pop edi 
 

		inc ecx
		jmp @@Loop 

		@@Stop:

		pop esi
		pop edx  
		pop ecx 
		pop ebx 
		pop eax 

		mov esp, ebp
		pop ebp

		ret 
		ENDP DrawGrid

; Author: Asma Oualmakran
; Function: IsEven
; Parameters: 
	; Number: 
		; Type: Initger 
		; Constraint: N/a 
		; Use: The number that needs to be determined to be even 
; Returns: returns in eax 1 if the number is even. otherwise it returns 0 
; Use: Determine if a number is even 

		PROC IsEven

		push ebp
		mov ebp, esp 

		push ebx 
		push edx 

		mov eax, [ebp+8]

		mov ebx, 2 
		mov edx, 0 		; edx needs to be set to 0 otherwise it wil crash 
		div ebx

		cmp edx, 0 
		je @@True

		mov eax, 0 
		jmp @@Stop 

		@@True: 		; edx = 0 that means the number is even 

		mov eax, 1 

		@@Stop: 

		pop edx 
		pop ebx 

		mov esp, ebp 
		pop ebp 

		ret 
		ENDP IsEven

; Author: Asma Oualmakran
; Function: Switch 
; Parameters: N/a 
; Returns: A source array and a destination array 
; Use: Switch between 2 arrays, rotate 2 arrays 

		PROC Switch

		push ebp 
		mov ebp, esp 

		push eax 

		mov eax, [_generation]

		push eax 
		call IsEven
		add esp, 4 

		; when the generation counter is even, we use, _gridArray as source and _gridArray2 as destination
		; when odd we do the reverse 

		cmp eax, 1 
		je @@True 

		; in this case the generation counter is odd 

		mov esi, offset _gridArray2

		mov edi, offset _gridArray

		jmp @@Stop 

		@@True: 

		mov esi, offset _gridArray

		mov edi, offset _gridArray2 
		

		@@Stop: 

		pop eax 

		mov esp, ebp
		pop ebp 

		ret
		ENDP Switch

	main:

        sti                             ; Set The Interrupt Flag
        cld                             ; Clear The Direction Flag

        push ds 						; Put value of DS register on the stack
        pop es 							; And write this value to ES

        ; initialise the field 

        call InitVideo					; set to video mode 
        call InitWindow					; Initialize the window with the background color 

        mov esi, offset _start 			; place the user input into the source array 
        mov edi, offset _gridArray 		; this will always be _gridArray, _generation = 0 and is always
        								; even at this point 

        push edi 						; place the start state in the source array 
        push esi 
        call SetStartState
        add esp, 8 

        mov esi, offset _gridArray
        mov edi, offset _bufferArray

       jmp @@First 

      @@GameLoop: 


       mov esi, edi 					; result of the call in the right array 
       mov edi, offset _bufferArray 

       @@First: 

       push esi 						; array that needs to be drawn 
       call GenerationExtinct

       mov eax, [_extinct] 				; if there is no cell alive we stop 
       cmp eax, 1
       je @@Stop 

        push edi 
        push esi 
        call DrawGrid
        add esp, 8

        mov esi, offset _bufferArray
        mov edi, vidBufferAdress

        push edi 
        push esi 
        call VideoUpdate
        add esp, 8

        call Switch

        push edi 
        push esi 
        call NextGeneration
        pop esi 
        pop edi 

        mov ah, 00h
		int 16h 

        jmp @@GameLoop 
     
     	@@Stop: 

        call ExitVideo

        mov eax, 4c00h                  ; AH = 4Ch - Exit To DOS
        int 21h                         ; DOS INT 21h


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
; DATA
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
DATASEG

	; Your data comes here
	_gridArray db gridSize dup (dead)	; dd -> 32-bit
										; db -> 8-bit, byte string
	_gridArray2 db gridSize dup (dead)	; second array to be able ;to compare the old data

	_generation dd 0 					; het tellen van generaties dd -> een intiger of floating point getal 
	_extinct 	dd 0					; when the grid is extinct, this variable wil be 1

	_bufferArray db vidBuffSize dup (background) ; the buffer for the videobuffer
									; we need to fill it with the backgroundcolor otherwise the background
									; becomes black 
	_start db 0, 1, 10, 11, 20, 5, 19, 66, 80, 99, 200, endSymbol ; the indexes that need to contain linving cells 
												; '=' is the end symbol this is needed because we 
												; don't know the size of the array 


	

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
; STACK
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
STACK 1000h

END main 