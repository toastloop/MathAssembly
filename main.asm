;-------------------------------------------------------------------------------
; Title: Math Library
; Author: Matthew Knowlton
; Date: 12 Oct 2023
; License: MIT License
;
;-------------------------------------------------------------------------------

            .cdecls 	C,LIST,"msp430.h"
            .def    	RESET
            .text
            .retain
            .retainrefs
			.align		2

;-------------------------------------------------------------------------------
; Start
;-------------------------------------------------------------------------------

RESET       mov.w   	#__STACK_END,SP
StopWDT     mov.w   	#WDTPW|WDTHOLD,&WDTCTL

;-------------------------------------------------------------------------------
; Main Function
;-------------------------------------------------------------------------------

main		push		#0
test1		mov.w		#4,			R12
			call 		#pow2					; 2^4
			cmp			#16,		R12
			jne			test2
			inc			0(SP)
test2		mov.w		#4,			R12
			call 		#pow2opt				; 2^4
			cmp			#16,		R12
			jne			test3
			inc			0(SP)
test3		mov.w 		#4,			R13
			mov.w		#1,			R12
			call 		#LeftShift				; 2^4
			cmp			#16,		R12
			jne			test4
			inc			0(SP)
test4		mov.w 		#2,			R13
			mov.w		#0x08,		R12
			call 		#RightShift				; 2^(3-2)
			cmp			#2,			R12
			jne			test5
			inc			0(SP)
test5		mov.w		#3,			R13
			mov.w		#3,			R12
			call		#mult					; 3*3
			cmp			#9,			R12
			jne			test6
			inc			0(SP)
test6		mov.w		#0,			R13
			mov.w		#3,			R12
			call		#mult					; 3*0
			cmp			#0,			R12
			jne			test7
			inc			0(SP)
test7		mov.w		#3,			R13
			mov.w		#10,			R12
			call		#div					; 10/3
			cmp			#3,			R12
			jne			test8
			cmp			#1,			R13
			jne			test8
			inc			0(SP)
test8		mov.w		#5,			R13
			mov.w		#3,			R12
			call		#div					; 3/5
			cmp			#0,			R12
			jne			test9
			cmp			#5,			R13
			jne			test9
			inc			0(SP)
test9		mov.w		#3,			R13
			mov.w		#3,			R12
			call		#div					; 3/3
			cmp			#1,			R12
			jne			test10
			cmp			#0,			R13
			jne			test10
			inc			0(SP)
test10		mov.w		#3,			R12
			call		#twos					; 0x0003 -> 0xFFFD
			cmp			#0xFFFD,	R12
			jne			test11
			inc			0(SP)
test11		mov.w		#3,			R13
			mov.w		#3,			R12
			call		#ipow					; 3^3
			cmp			#27,		R12
			jne			done
			inc			0(SP)
			pop			R12
done		ret

;-------------------------------------------------------------------------------
; Original-ish Pow2
;-------------------------------------------------------------------------------

pow2		push.w		R12						; int x = 3;
			cmp.w		#0,			0(SP)		; if(x > 0)
			jnz			recurse					; 	goto recurse;
			push.w		#1						; int y = 1;
			jmp			return					; goto return;
recurse		dec			0(SP)					; recurse: x -= 1;
			mov			0(SP),		R12			;
			call		#pow2					; y = pow(x);
			push.w		R12						;
			mov			2(SP),		R12			;
			call		#pow2					;
			add			R12,		0(SP)		; y += pow(x);
return		pop.w 		R12						; R12 = y; free(y);
			incd.w		SP						; free(x);
			ret									; return R12;

;-------------------------------------------------------------------------------
; Improved Pow2
;-------------------------------------------------------------------------------

pow2opt		push.w		#1						; int i = 0x0001;
loop		tst.w		R12						; loop: if(R12 == 0)
			jeq			pow2ret					; 	goto pow2ret;
			rla.w		0(SP)					; i = i << 1;
			dec			R12						; R12--;
			jmp			loop					; goto loop;
pow2ret		pop.w		R12						; R12 = i;
			ret									; return R12;

;-------------------------------------------------------------------------------
; More Improved Pow2
;-------------------------------------------------------------------------------

LeftShift   and			#15,		r13			; Limit Shift
			xor			#15,		r13			; Invert Shift
			add			r13,		r13			; Scale Shift (R13 * 2)
			add.w		r13,		pc			; Branch to the correct line
LS15		rla			r12
LS14		rla			r12
LS13		rla			r12
LS12		rla			r12
LS11		rla			r12
LS10		rla			r12
LS9			rla			r12
LS8			rla			r12
LS7			rla			r12
LS6			rla			r12
LS5			rla			r12
LS4			rla			r12
LS3			rla			r12
LS2			rla			r12
LS1			rla			r12
            ret

RightShift  and			#15,		r13			; Limit Shift
			xor			#15,		r13			; Invert Shift
			add			r13,		r13			; Scale Shift (R13 * 2)
			add.w		r13,		pc			; Branch to the correct line
RS15		rra			r12
RS14		rra			r12
RS13		rra			r12
RS12		rra			r12
RS11		rra			r12
RS10		rra			r12
RS9			rra			r12
RS8			rra			r12
RS7			rra			r12
RS6			rra			r12
RS5			rra			r12
RS4			rra			r12
RS3			rra			r12
RS2			rra			r12
RS1			rra			r12
            ret

;-------------------------------------------------------------------------------
; ipow
;-------------------------------------------------------------------------------

ipow		push		r12
			push		r13
			push		#1
ipowloop	tst			2(SP)
			jeq			ipowret
			clrc
			rrc			2(SP)
			jnc			ipowskip
			mov			0(SP),		R12
			mov			4(SP),		R13
			call		#mult
			mov			R12,		0(SP)
ipowskip	mov			4(SP),		R12
			mov			4(SP),		R13
			call		#mult
			mov			R12,		4(SP)
			jmp			ipowloop
ipowret		pop			r12
			add			#4,			SP
			ret

;-------------------------------------------------------------------------------
; mult
;-------------------------------------------------------------------------------

mult		push		r13
			push		r12
			push		#0
multstart	bit			#1,			2(SP)
			jeq			multskip
			add			4(SP),		0(SP)
multskip	rla			4(SP)
			rra			2(SP)
			cmp			#0,			2(SP)
			jne			multstart
			pop			r12
			add			#4,			SP
			ret

;-------------------------------------------------------------------------------
; div
;-------------------------------------------------------------------------------

div			cmp			#0,			r13
			jnc			divret
			cmp			r13,		r12
			jc			divset
			mov			#0,			r12
			jmp			divret
divset		push		r13
			inv			0(SP)
			inc			0(SP)
			push		r12
			push		#0
divsub		cmp			0(SP),		2(SP)
			jnc			divend
			add			4(SP),		2(SP)
			inc			0(SP)
			jmp			divsub
divend		pop			r12
			pop			r13
			add			#2,			SP
divret		ret



;-------------------------------------------------------------------------------
; two's compliment
;-------------------------------------------------------------------------------

twos		inv			r12
			inc			r12
			ret

;-------------------------------------------------------------------------------
; end
;-------------------------------------------------------------------------------

            .global __STACK_END
            .sect   .stack
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
            
