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
bufferAdress	equ 0a0000h
windowWidth		equ 320  ; the window width in pixels
windowHeight	equ 200 ; the window height in pixels 
vidBuffSize		equ windowHeight * windowWidth ; the length of the videobuffer

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

;---------------------------------------

; Author: http://stackoverflow.com/questions/4244624/print-integer-to-console-in-x86-assembly
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

		mov eax, [ebp+8]
			

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
; Function: Index
; Parameters: 
	; x: 
		; Type: intiger
		; Use: x-coordinate of the cell. 
		; Constraint: larger or equal to 0 and smaller than gridWidth.
	; y:
		; Type: intiger 
		; Use: y-coordinate of the cell. 
		; Constraint: larger or equal to 0 and smaller than gridHeight.
	; Adres Array: 
		; Type: Macro 
		; Use: The length of the used array. 
		; Constraint: N/a 
; Returns: An index in an array.
; Use: Converts the coordinate of an pixel or an cell into an index of the used array (formula: index =  width*y+x.

		PROC Index

		push ebp 
		mov ebp, esp 
		; eax containts the x-coordinate
		; ebx containts the adres array 
		; ecx containts the y-coordinate
		; We use eax to pass the return value of this function
	 
		push ebx 
		push ecx  
		push edx 

		mov eax, [ebp+8]
		mov ebx, [ebp+12]
		mov ecx, [ebp+16]

		; write if test here to check if the value is out of bounds 

		; apply the formula width*y+x
		; y times the width will give the height in the grid 
		; we dec y, we start counting from 0, otherwise we put the element 
		; one location to low on the grid. 

		push eax 

		push ecx 
		call SetWidth
		add esp, 4

		mov ecx, eax 

		pop eax 	; restore the x-coordinate

		imul ebx, ecx 

		add eax, ebx 	

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

		mov esp, ebp
		pop ebp 

		ret
		ENDP GetCoordinates


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

		mov eax, [ebp+8]

		cmp eax, bufferAdress
		je @@bufferAdress

		cmp al, [_gridArray]
		je @@gridArray

		cmp al, [_gridArray2]
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

		mov eax, [ebp+8]

		cmp eax, bufferAdress 
		je @@bufferAdress

		cmp al, [_gridArray]
		je @@gridArray

		cmp al, [_gridArray2]
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

		mov eax, [ebp+8]

		cmp eax, bufferAdress 
		je @@bufferAdress

		cmp al, [_gridArray]
		je @@gridArray

		cmp al, [_gridArray2]
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
; Function: InBounds 
; Parameters: 
	; Index: 
		; Type: intiger 
		; Use: The index of an element in an array. 
		; Constraint: N/a 
	; Array_size: 
		; Type: intiger 
		; Use: The size of the used array.
		; Constraint: N/a 
; Returns: 0 or 1, 0 if the element is out of bounds of the array. 1 if the element is in bounds of the array. 
; Use: Print an message if the element is to large or the small. Used as a boolean to check if an index is in bounds of an array. 

		PROC InBounds

		push ebp
		mov ebp, esp

		push ebx

		mov eax, [ebp+8]
		mov ebx, [ebp+12]


		cmp eax, ebx    ; Make sure that the Index is in bounds of the array. 
		jge @@toLarge	; index is from 0 - length-1 if it is equal to the length or larger -> out of bounds

		cmp eax, 0		
		jl @@toSmall

		jmp @@inBounds 	; If you reach here, your index is in bounds of the array 

		@@toLarge:
		mov ah, 09h                     ; AH=09h - Print DOS Message
        mov edx, offset _msgL            ; DS:EDX -> $ Terminated String
        int 21h                         ; DOS INT 21h

        mov eax, 0

		jmp @@stop						; make sure we don't print the other message, jump to the end of the code 

		@@toSmall:						; The element is to large if you jump to this label
		mov ah, 09h                     
        mov edx, offset _msgS           
        int 21h  

        mov eax, 0
        jmp @@stop

        @@inBounds:						; if you jump to here, the element is in bounds 

        mov eax, 1

        @@stop:

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
 
 		; to set the array adres before the call use 
 		; lea esi, <array>
		push ebp 
		mov ebp, esp 
			
		push edx ; edx containts the index of the element 
		push esi ; contains the memory adres

		mov edx, [ebp+8]	; index 
		mov esi, [ebp+12]	; memory adres 
	
		push esi 
		call SetArraySize		; set the size of the array to check the bounds 
		add esp, 4

		push eax		; contains the array size 
		push edx 		; contains the index 
		call InBounds
		add esp, 8

		cmp eax, 0		; check if the index is in bounds of the array 
		je @@stop		; if the returnvalue of the boolean is false, jump to the end

		mov ah, 0
		mov al, [byte ptr esi+edx]

		@@stop:

		pop esi 
		pop edx 

				; eax is used to return the value of the element. 

		mov esp, ebp 
		pop ebp

		ret
		ENDP GetValue



; Author: Asma Oualmakran
; Function: SetValue 
; Parameters: 
	; Index: 
		; Type: intiger
		; Use: The index of an element in the array 
		; Constraint: Larger or equal to 0 and smaller than the length of the array 
	; Array adres: 
		; Type: adres
		; Use: The adres of the array 
		; Constraint: Must be an adres of a byte array. 
	; value: 
		; Type: Intiger
		; User: The value to be set in the array.
		; Constraint: N/a 
; Returns: N/a
; Use: Set an value in the array.

		PROC SetValue 
 
 		; make sure that the value to be set is placed in al 
 		; otherwise it is to large to be set in the byte array
		push ebp 
		mov ebp, esp 
		push eax ; containts the value to be set.
		push ecx ; containts the size -> to be set by SetArraySize.
		push edx ; containts the index. 
		push edi ; containts the adres of the array 

		mov eax, [ebp+8]	
		mov edx, [ebp+12]
		mov edi, [ebp+16]

		
		push eax ; store eax to not overwrite is by the called functions
				 ; you store it before edi, so it's on top of the stack and not used by the fuction SetArraySize

		push edi
		call SetArraySize
		add esp, 4 		; eax now containts the array size

		mov ecx, eax 	; mov the array size from eax into ecx 
		
		push ecx 
		push edx 
		call InBounds 	; check if the index is in bounds of the array 
		add esp, 8 

		cmp eax, 0		; if it is out of bounds, you stop. 
		je @@stop

		pop eax 		; retore the value of eax 		

		mov [byte ptr edi+edx], al

		@@stop:
																		
		pop esi 
		pop edx
		pop ecx 
		pop ebx 
		pop eax 

		mov esp, ebp 
		pop ebp

		ret
		ENDP SetValue


; Author: Asma Oualmakran
; Function: InitVideo 
; Parameters: 
; Returns: N/a 
; Use: Initialize the video mode 

		PROC InitVideo

		push ebp
		mov ebp, esp 

		push ax 
		
		mov ax , 13h ; specify AH=0 (set video mode) , AL=13h (320x200 )
		int 10h 	 ; call VGA BIOS

		pop ax 

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

		push ax 

		mov ax , 03h ; specify AH=0 (set text mode) , AL=3h (text)
		int 10h 	 ; call VGA BIOS

		pop ax 

		mov esp, ebp 
		pop ebp 

		ret
		ENDP ExitVideo


; Author: Asma Oualmakran
; Function: InitWindow
; Parameters: N/a 
; Returns: N/a 
; Use: Initialize the window, make the background one colour 

		PROC InitWindow 

		push ebp 
		mov ebp, esp 
		push eax 
		push ecx
		push edi 

		call InitVideo	; open the video mode 
		
	;	mov ah, 0
	;	mov al, white		; place the color in al 
		mov eax, black 
		mov ecx, vidBuffSize  ; works as a counter
		mov edi, bufferAdress ; the index where stosb needs to start 
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
; Retruns: N/a 
; Use: Initialize the grid array's, fill them with 0. Tis is the initial state of the grid 

		PROC InitArray

		push ebp 
		mov ebp, esp 
		push eax 
		push ecx 
		push edi 

		mov eax, 0
		mov ecx, gridSize
		lea edi, [_gridArray]
		rep stosb 

		lea edi, [_gridArray2]
		rep stosb

		pop edi 
		pop ecx 
		pop eax 

		mov esp, ebp 
		pop ebp 

		ret 
		ENDP InitArray

; Author: Asma Oualmakran
; Function: Reset 
; Parameters: N/a 
; Returns: N/a 
; Use: Re-initialise the grid-array's, the videobuffer, (generation counter if implemented)

		PROC Reset

		push ebp
		mov ebp, esp
		; no need to push the registers, this function won't adjust them 
		; and the functions called will save and restore them 

		call InitWindow
		call InitArray

		mov esp, ebp 
		pop ebp 

		ret 
		ENDP Reset 

; Author: Asma Oualmakran
; Function: DrawLine 
; Parameters: 
	; Index: 
		; Type: Initiger 
		; Use: The index of the element in the gridArray.
		; Constraint: N/a 
	; Array: 
		; Type: Adres
		; Use: The array that needs to be adjusted.
		; Constraint: N/a
	; Color:
		; Type: Intiger
		; Use: The color of the pixel. 
		; Constraint: larger or equal to 0 and smaller or equal to 15.
	; Size: 
		; Type: Intiger
		; Use: The length of the line 
		; Constraint: Larger than 0 an smaller or equal to the width of the screen. 
; Use: Set the elements of the video buffer, and draw a horizintal line 
; Returns: N/a 

		PROC DrawLine

		push ebp 
		mov ebp, esp 

		push eax 
		push ebx 
		push ecx 
		push edi 

		mov eax, [ebp+8]	; color 
		mov ebx, [ebp+12]	; index 
		mov ecx, [ebp+16]	; width 
		mov edi, [ebp+20]	; adress 

	;	mov ecx, blockWidth
		add edi, ebx

		rep stosb 

		pop edi 
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
	; Array: 
		; Type: Adres 
		; Use: The array that needs to be adjusted. 
		; Constraint: N/a
	; Color:
		; Type: Intiger
		; Use: The color of the pixel. 
		; Constraint: larger or equal to 0 and smaller or equal to 15.
; Use: Set the elements of the video buffer, and form a square 
; Returns: N/a 

		PROC DrawSquare

		push ebp 
		mov ebp, esp 

		push eax 	; color
		push ebx 	; index
		push ecx 	
		push edx 	; widht of the grid --> set by function
		push edi	; adres of array where we write to 

		; the width of the grid --> calculate in the calling fuction

		mov eax, [ebp+8]
		mov ebx, [ebp+12]
		mov edi, [ebp+16]

		; for mapping gridArray on the display 
		; you need to extract the x and y coordinate form the grid index
		; and recalculate the index for the vidbuffer 

		; set ecx to the height
		mov ecx, blockHeight

		; loop 
		@@loop:

		cmp ecx, 0 		; if the counter < 0 the square is drawn 
		jl @@stop		; jou jump to the end of the function --> @@stop

		push ecx ; save the main counter

		push eax ; save the color -> eax will be alterd by the next function
	

		; extract the coordinates
		push edi 					; no need to set the gridWidth, it will be done by the function self
		push ebx 
		call GetCoordinates
		add esp, 8 

		; x -> edx 
		; y -> ebx 

		mov ebx, eax 	; ebx containts the y coordinate

		cmp ecx, blockHeight   ; solution for the exception if it is the first time 
		je @@ecxNOTalterd	   ; the loop is started, the y coordinate in edx doesn't need te be alterd 

		; calculate the index in the vidbuffer
		inc ebx 				; in al other cases, the y coordinate is incremented 

		@@ecxNOTalterd: 		; if ecx isn't alterd you have jumped to this label 

		push edi 	; adres 
		push ebx 	; y-coordinate
		push edx 	; x-coordinate
		call Index
		add esp, 12

		mov ebx, eax ; the index is places in ebx 
					 ; the old x coordinate that was placed in ebx is no longer needed 
					 ; it will be recalculated in the next loop 
		
		; restore eax 
		pop eax 	; eax contains the color again 

		; give the length of the line 
		mov ecx, blockWidth

		; call DrawLine
		push edi 	; the adres 
		push ecx 	; the line length
		push ebx 	; the index 
		push eax 	; the color
		call DrawLine
		add esp, 16

		; restore ecx (the main counter)
		pop ecx  	; dec the counter and start the loop angain 

	
		dec ecx 
		
		jmp @@loop

		@@stop:

		pop edi
		pop edx 
		pop ecx  
		pop ebx 
		pop eax 
		
		mov esp, ebp 
		pop ebp

		ret 
		ENDP DrawSquare






	main:

        sti                             ; Set The Interrupt Flag
        cld                             ; Clear The Direction Flag

        push ds 						; Put value of DS register on the stack
        pop es 							; And write this value to ES




    call InitVideo
      call InitWindow


		mov eax, red
		mov ebx, 330
		mov ecx, blockWidth
		mov edi, bufferAdress

		push edi 
	;	push ecx
		push ebx 
		push eax 

		call DrawSquare
		add esp, 12

		mov ah,00h 						; these two lines make the code stop here 
        int 16h							; you stay in video and can go to exit by pressing a key

        call Reset 


	;	mov edx, 0
	;	mov ebx, 320 
	;	mov eax, 400
	;	div ebx 


	;	push ebx 
	;	push eax 
;
;		call GetCoordinates
;		add esp, 8 
;
	;	push eax 
	;	call PrintDigit
	;	add esp, 4 

	;	push edx 
	;	call PrintDigit
	;	add esp,  4
		; drawline werkt 
		; je hebt een illigal write -> je zit ergens op het verkeerde adres 

      ; push edi 
      ; push edx 
      ; push eax 
      ; call DrawSquare
      ; add esp, 12

 ;    push edi 
  ;   push edx 
   ;  push eax 
    ; call DrawLine
     ;add esp, 12
   		


   	;	push ebx 
   ;		push eax 
   	;	call GetCoordinates
   ;		add esp, 4

   ;     push edx 
    ;    push eax 
     ;   call GetCoordinates
      ;  add esp, 8

      ;	lea ebx, [gridArray]
   ;   	mov ebx, bufferAdress

  ;     xor eax, eax 
 ;      mov ah, 0
 ;      mov al, 50
  ;     mov edx, 5
   ;    lea edi, [gridArray]
;
 ;      push edi 
  ;     push edx 
   ;    push eax 
;
 ;      call SetValue
  ;     add esp, 12
   ;  
  	;	lea esi, [gridArray]
  	;	mov eax, 5

  ;		mov bh, 0 
  ;		mov bl, [gridArray]
  ;		mov eax, 6
;
 ; 		push ebx 
  ;		push eax 
  ;		call GetCoordinates
  ;		add esp, 8

    
  ;    push esi 
   ;   push eax 
    ;  call GetValue
     ; sub esp, 8
     ;	mov bh, 0
 	;	mov bl, offset gridArray
 ;		lea esi, [gridArray]
 ;	mov edi, 5
 ;		mov ah, 0 
 	;	mov al, [gridArray]
 		

 ;		mov al, [byte ptr esi+edi]



    	;Pause 
        mov ah,00h 						; these two lines make the code stop here 
        int 16h							; you stay in video and can go to exit by pressing a key

    
 

		call ExitVideo					; you alwas need to call exit video afther you call init 

        mov eax, 4c00h                  ; AH = 4Ch - Exit To DOS
        int 21h                         ; DOS INT 21h


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
; DATA
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
DATASEG

	; Your data comes here
	_gridArray db gridSize dup (20)	; dd -> 32-bit
									; db -> 8-bit, byte string
	_gridArray2 db gridSize dup (0)	; second array to be able ;to compare the old data
	_generation dd 0 				; het tellen van generaties dd -> een intiger of floating point getal 
;	_colorArray dd 000 				; hier moeten er nog de kleuren in komen  

	; errors and information strings
	_msg1 db 'equal 1', 10, 13, '$'
	_msg0 db 'equal 0', 10, 13, '$'
	_msgS db 'Index is to small', 10, 13, '$'
	_msgL db 'Index is to large', 10, 13, '$'

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
; STACK
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
STACK 1000h

END main