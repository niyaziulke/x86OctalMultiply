;Deniz Arda Budak 2017400177
;Niyazi Ülke 2017400114

code segment
;for security refresh registers	
 xor CX,CX 
 xor AX,AX
 xor BX,BX
 xor DX,DX
 xor BP,BP

begloop1: ;loop to read numbers	
 mov AH,01h
 int 21h
 cmp AL,'*'
 je numberadded
 cmp AL,0D 
 je endloop1
 sub AL,'0' ; AL transformed to an integer from char.   
 mov BL,AL   ; store AL in BL. 
 mov AX,8d ; to multiply with 8
 mul CX; store the higher 16 bits in CX.
 mov CX,AX 
 mov AX,8d  
 mul BP
 add CX,DX   
 add AX,BX
 mov BP,AX ; store the lower 16 bits in BP
 jmp begloop1

numberadded: ;a number has been read.
  mov [5678h],BP ; assign the lower part of the first number to [5678h] 
  mov [3598h],CX ; assign the higher part of the first number to [3598h] 
  
;refreshing registers  
 xor CX,CX 
 xor AX,AX
 xor BX,BX
 xor DX,DX
 xor BP,BP
 jmp begloop1

endloop1:   
 mov [1234h],BP ;assign the lower part of the second number to [1234h] 
 mov [9999h],CX ;assign the higher part of the second number to [9999h]  
 
;multiply lower parts of the numbers with each other and push the higher bits to stack and store the lower bits in CX.
 mov AX,[5678h]
 mov BX,[1234h]
 mul BX;
 mov CX,AX
 push DX;

;multiply lower part of the first number with the higher part of the second number, push the lower bits to stack and store the higher bits in [1234h].
 mov AX,[3598h]
 mul BX
 push Ax
 mov [1234h],DX

;multiply lower part of the second number with the higher part of the first number, push the lower bits to stack and store the higher bits in [5678h].
 mov AX,[5678h]
 mov BX,[9999h]
 mul BX
 push AX
 mov [5678h],DX

;multiply higher parts of the numbers with each other and store the higher bits in [3598h] and the lower bits in [9999h].
 mov AX,[3598h]
 mul BX
 mov [3598h],DX
 mov [9999h],AX
  
;sum the 16bit values which corresponds to the third (from left) 16-bit block of the result of the multiplication. 
;check if overflow occurs and execute the necessary operations (increment the adjacent 16 bit block). 
 pop AX
 pop BX
 pop DX
 add AX,BX
 jnc pass1

;execute if there is overflow in the first summation.
firstoverflow:
 inc w[1234h]

pass1:
 add AX,DX
 jnc pass2

;execute if there is overflow in the second summation.
secondoverflow:                                                
 inc w[5678h]

;sum the 16bit values which corresponds to the second(from left) 16-bit block of the result of the multiplication.
pass2:
 mov BP,AX ;store the  third(from left) 16-bit block in BP
 mov AX,[1234h]
 mov BX,[5678h]
 mov DX,[9999h]
 add AX,BX
 jnc pass3          

;execute if there is overflow in the third summmation.
thirdoverflow:
 inc w[3598h]

pass3:
 add AX,DX
 jnc pass4
;execute if there is overflow in the fourth summation.
fourthoverflow:
 inc w[3598h]

pass4:
; re-assign registers to store the blocks from left to right in AX,BX,CX,DX correspondingly. 
  mov BX,AX
  mov Dx,cx
  mov AX,[3598h]
  mov cX,BP

;by masking push the value of each three bits in DX from right to left.
 mov SI,5                                           
dxloop:
 mov BP,7
 and BP,DX
 push BP 
 shr Dx,3
 dec SI                                     
 jnz dxloop
;the leftmost 1 bit of DX and rightmost 2 bits of CX corresponds to an octal digit.
;hence,mask them outside the loop.
 mov BP,1
 and BP,DX
 mov DX,BP
 mov BP,3
 and BP,CX
 shl BP,1
 add BP,DX
 push BP
 shr cx,2

;by masking push the value of each three bits in CX from right to left.
 mov SI,4                                           
cxloop:
 mov BP,7
 and BP,CX
 push BP 
 shr CX,3
 dec SI                                           
 jnz cxloop

;the leftmost 2 bits of CX and rightmost 1 bit of BX corresponds to an octal digit.
;hence,mask them outside the loop.
 mov BP,1
 and BP,BX
 shl BP,2
 add BP,CX
 push BP
 shr BX,1

;by masking push the value of each three bits in BX from right to left.
 mov SI,5                                          
bxloop:
 mov BP,7
 and BP,BX
 push BP 
 shr Bx,3
 dec SI                                         
 jnz bxloop

;by masking push the value of each three bits in AX from right to left.
 mov SI,5
axloop:
 mov BP,7
 and BP,AX
 push BP 
 shr Ax,3
 dec SI                                          
 jnz axloop 
 push AX ;push leftmost 1 bit of Ax.

;printing new line.
 mov AH,02h
 mov DL,0Dh ;new
 int 21h
 mov DL,0Ah
 int 21h

;the program does not print  0's until encountering with a non zero number
dontprintloop:
 cmp SP,0FFFEh 
 je endflag2 ;if the stack is full of 0's.
 pop DX
 cmp DX,0
 je dontprintloop
 
 mov AH,02h
 add DX,'0'; convert the int to corresponding ASCII character in order to print it.
 int 21h;
printloop:
 cmp SP,0FFFEh ;if the stack is empty end the program.
 je endflag
 pop DX
 add DX,'0' ; convert the int to corresponding ASCII character in order to print it.
 mov AH,02h
 int 21h;
 jmp printloop

endflag2:
 mov AH,02h
 mov DX,'0'
 int 21h

endflag:
 int 20h
code ends
