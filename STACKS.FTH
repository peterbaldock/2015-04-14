.( Compiling   Stacks.FTH Version 8.00 ) cr
" STACKS.FTH Entry" stackCheck
( noisy )
4 ?stack
: stack word: count word: elementsize
local	elementsize count * const word: nBytes
	<sbuilds
		{ 0 elementsize nBytes w} drop
		nBytes staticallot drop
	does>
;



: _--sp?Under dword: stk
	stk w@ dup 0= if "  : Stack object underflow" 1+ $F0 ."abort endif
	stk +
	stk 2+ w@ - 6 +
;
: _sp++?Over dword: stk
	stk w@ dup stk 3 + w@ >= if "  : Stack object overflow" 1+ $F1 ."abort endif
	stk + 6 + ( ." Element address = " ?dword cr )
;
21 ?stack
: push dword: stk
local	stk 2+ c@ const dword: size

	stk _sp++?Over
	size select

		BYTE case: c!	endcase

		WORD case: w! 	endcase

		FLOAT case: !	endcase

	endselect
	size stk +!
;
: writeTOS address: stk
local	stk 2+ c@ const word: size
	stk _--sp?Under
	size select

		BYTE case: c!	endcase
		WORD case: w! 	endcase
		FLOAT case: !	endcase

	endselect
;
: readTOS address: stk
local	stk 2+ c@ const word: size
	stk _--sp?Under
	size n@
;
: pop dword: stk
local	stk 2+ c@ const dword: size
	stk _--sp?Under
	size select

		BYTE case: c@	endcase
		WORD case: w@ 	endcase
		FLOAT case: @	endcase

	endselect
	size dnegate stk +!
;

60 ?stack
" STACKS.FTH Exit" stackCheck
quiet
