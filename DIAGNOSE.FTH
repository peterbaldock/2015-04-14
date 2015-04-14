.( Compiling Diagnose.fth Version 8.05 ) cr
" DIAGNOSE.FTH Entry" stackCheck

0 constant	DEBUG	( Debugging is OFF by default )
: .s

	sp@ word. 2 spaces
	sp@ s0 = if
	  ." Empty Stack"
	else
	  sp@ 4+ s0 4+ do
	    i @ hex.
	  4 +loop
	endif
;
: heap? word: n
	DEBUG if
		HeapBase 8+ @ if ." Heap used " n . bye endif
	endif
;
1 heap?
0 variable _showSP
		
: ?f. _showSP if dup f. cr endif ;
: ?stack _showSP @ if ." Line "	d. space sp@ hex. cr else drop endif ;
: quiet 0 _showSP ! ;
: noisy 1 _showSP ! ;
: ?dword dup dword. space ;
: .?? ?dword cr ;
( noisy )

" DIAGNOSE.FTH Exit" stackCheck
