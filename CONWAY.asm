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

gridWidth	equ 10
gridHeight	equ 10
gridSize 	equ gridWidth * gridHeight ; the number of elements in the grid = the length of the gridArray
blockWidth 	equ 10
blockHeight equ 10

;video Macro's
bufferAdress equ 0a0000h
vidBuffSize equ windowHeight * windowWidth ; the length of the videobuffer
windowWidth equ 320  ; the window width in pixels
windowHeight equ 200 ; the window height in pixels 

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

		; Author: 
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

		push ebx 
		push edx 


		mov eax , [ebp+8] 	; take the value of LAST pushed argument
		mov ebx , [ebp+12] 	; take the value of FIRST pushed argument
							; index = (x-1)*gridWidth+y
							; eax contains x-coordinate, ebx contains y-coordinate

							; ebx contains the x-value, eax contains the y-value
		dec eax 
		imul eax, eax, gridWidth	; multiply the x-value with the gridWidth and place the result back in ebx  
		add eax, ebx		; the addition of the formula
	
		pop edx
		pop ebx 			; we don't pop eax to be able to pass the value outside the function

		mov esp, ebp 		; restore the or iginal s tack pointer
		pop ebp 			; retrieve the or iginal base pointer

		ret 				; return to next instruction after the call
		ENDP Index 

		; Author: Asma Oualmakran
		; Function: SetCell
		; Parameters: 
			; x 
				; Type: intiger
				; Use: The x-coordinate of the cell who needs to be killed. 
				; Constraint: larger or equal to 0 and smaller than the gridWidth
			; y
				; Type: intiger
				; Use: The y-coordinate of the cell who needs to be killed. 
				; Constraint: larger or equal to 0 and smaller than the gridHeight.
			; cellVal
					; Type: 
					; Use: The value that needs to be given a certain element of the grid.
					; Constraint: 
		; Returns: N/a 
		; Use: Set the state of a living cell to dead.

		PROC SetCell

		push ebp 
		mov ebp, esp
		push eax 
		push ebx
		push edx  
		push edi

		mov eax, [ebp+8]     ; contains the x value
		mov ebx, [ebp+12]	 ; contains the y value 
		mov edx, [ebp+16]

		push ebx 			 ; push argument in opposit order 
		push eax 
		call Index 			 ; calculate the location of the element in the array 
		add esp, 8			 ; the result of it is located in eax

		mov edi, eax
		mov [gridArray + edi*4], edx 	; place the adres of the element in edi
										; the first element is on edi, second on edi+4, third on edi+8 ect...
										; the multiplication with the index is needed to acces the rigt element
										; base + offset * size (size in bytes)
		pop edi 
		pop edx 
		pop ebx 
		pop eax

		mov esp, ebp
		pop ebp

		ret
		ENDP SetCell


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

		push ebp 
		mov ebp, esp
		push ebx 
		push esi
		
		mov eax, [ebp+8]     ; contains the x value
		mov ebx, [ebp+12]	 ; contains the y value 
	
		push ebx 			 ; push argument in opposit order 
		push eax 
		call Index 			 ; calculate the location of the element in the array 
		add esp, 8			 ; the result of it is located in eax

		mov esi, eax 		 ; place the index of the element in edi
		mov eax, [gridArray + esi*4] 	    ; the first element is on edi, second on edi+4, third on edi+8 ect...
										; the multiplication with the index is needed to acces the rigt element
										; base + offset * size (size in bytes)
		pop esi 
		pop ebx 

		mov esp, ebp
		pop ebp

		ret 
		ENDP StateCell


		; Author: Asma Oualmakran 
		; Function: VidIndex 
		; Parameters: 
			; x: 
				; Type: intiger 
				; Use: x-coordinate of a pixel
				; Constraint; larger or equal to 0 and smaller or equal to 320 
			; y:
				; Type: intiger
				; Use:  y-coordinate of a pixel 
				; Constraint; larger or equal to 0 and smaller or equal to 200
		; Returns: The index of the pixel in the video buffer 
		
		PROC VidIndex

		push ebp 
		mov ebp, esp 
		push ebx
		push edx 

		mov eax, [ebp+8]
		mov ebx, [ebp+12]

		imul eax, eax, windowWidth	; use eax so the result is put in one register
		add eax, ebx 				; place the final result in eax 
									; the result is returned in eax 
		pop edx 
		pop ebx 
		mov esp, ebp 
		pop ebp 

		ret 
		ENDP VidIndex

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



		PROC Draw 
		push ebp 
		mov ebp, esp 

		push eax 
		push edi 

		mov edi, bufferAdress

		pop edi
		pop eax 
		mov esp, ebp 
		pop ebp

		ret 
		ENDP Draw

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
		

		mov al, white		; place the color in al 
		mov ecx, vidBuffSize
		mov edi, bufferAdress ; the index where stosb needs to start 
		rep stosb	; loops over the video buffer to set every pixel to a value 

		pop edi 
		pop ecx 
		pop eax 
		mov esp, ebp 
		pop ebp 

		ret 
		ENDP InitWindow

	


	main:

        sti                             ; Set The Interrupt Flag
        cld                             ; Clear The Direction Flag

        push ds 						; Put value of DS register on the stack
        pop es 							; And write this value to ES

        call InitWindow
        
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
	gridArray dd gridSize dup (0)	; dd -> 32-bit
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

END main