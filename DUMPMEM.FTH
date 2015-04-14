.( Compiling  DumpMem.fth Version 8.05 ) cr
" DumpMem.fth Entry" stackCheck

: WaitKey begin ReadKeyboard ?dup until ;

vocabulary Dump
with Dump +definitions

: ReturnStackDump
	&r cwd 10 + local const dword: rtos
	rtos word. word. 2 spaces
	rtos 24 + rtos do
	    i w@ hex.
	2 +loop
;

: StackDump

	sp@ word. 2 spaces
	sp@ s0 = if
	  ." Empty Stack"
	else
	  sp@ 4+ s0 4+ do
	    i @ hex.
	  4 +loop
	endif
;

: dumpline dword: adr dword: seg

	seg if
		seg >gs seg word. ( ascii : ) $3A emit adr word.
	else
		ds> >gs adr dword.
	endif

	space

	16 0 do
	  i 3 and if
	    space
	  else
	    ( ascii ³ ) $7C emit
	  endif
	  adr i + gs:c@ byte.
	loop

	16 0 do
	  i 3 and 0= if
	    ( ascii ³ ) $7C emit
	  endif
	  adr i + gs:c@ an.
	loop

	( ascii ³ ) $7C emit cr 0 error _! 
;

ds> variable _dumpseg
0 variable _dumpstart
16 variable _dumplines

: _esd	dword: adr  dword: lines  dword: seg

local	0 word: Count

	seg _dumpseg ! 
	lines _dumplines ! 
	adr
	_dumplines @ 0 do
		dup _dumpseg @ dumpline 
		16 +
		Count ++ Count @ 16 = if
			0 Count ! WaitKey $FF and $1B = if
				leave 
			endif
		endif
	loop
	_dumpstart !
;
: _dump 0 _esd ; 
: safetype dword: adr dword: len
	len 32 < if adr len type else ." Bad string address!" endif
;
: _wdump dword: pfa
pfa 0= if ." Word not found." cr exit endif
local
" Name       : " const dword: sNa
" Properties : " const dword: sPr
" Link       : " const dword: sLF
" Code Field : " const dword: sCF
" Start ..."	 const dword: sSt
" Parameters ..." const dword: sPa

	pfa nfa >r ?dword sNa count type r> safetype cr
	pfa nfa drop ?dword sSt count type cr 1 _dump
	pfa 10 - ?dword sPr count type w@ word. cr
	pfa  8 - ?dword sLF count type @ dup dword. space 8 + nfa type cr
	pfa  4 - ?dword sCF count type cs> word. ascii : emit @ word. cr
	pfa ?dword sPa count type cr 4 _dump

;
: intdump word: start word: n

	n start + start do
		i 3 and 0= if
			cr i 4* word. space i byte.
		endif
		space space
		i 4* gs:2@
		wsplit dup cs> = if
			."   CS:" drop word.
		else
			word. ascii : emit word.
		endif
	loop
	cr
;


-definitions

: .r ReturnStackDump ;
: .s StackDump ;
: dump 0 _esd ; 
: cs:dump ( offset, nlines - ) cs> _esd ;
: ds:dump ( offset, nlines - ) ds> _esd ;
: es:dump ( offset, nlines - ) es> _esd ;

: .. _dumpstart @ _dumplines  @  _dumpseg  @  _esd ;

: wdump ' _wdump ;
: idump 0 48 intdump ;
: vochunt dword: adr 

	' @ dup
	adr > if

		begin
			dup adr >
		while
			@
		repeat
		8+ _wdump
	else
		drop ." Not found in " nfa type cr
	endif
;


endwith ( Dump )



vocabulary Heap with Heap +definitions

: # $8000000 malloc ?dup if dup handle.data hex. else ." Failed" endif cr ;

: mb.	address: hptr

	." Start=" hptr hex.
	
	." Size=" hptr @ hex. space
	."  Handle=" hptr 4+ @ hex. space
	hptr 8+ @ ?dup if ."  RCount=" . else ."  free" endif cr
;
: ?freed
	HandleSP dup ." Heap dump : HandleSP = " hex. cr
	begin
		dup w@ 4* HandleTable + dup @
		if dup hex. mb. else drop endif
		2+
		dup MemTop >=
	until
	drop
;

: heapdump
local	0 dword: freed
	0 dword: allocated
	HeapBase begin
		dup @ over 8+ @ if allocated +! else freed +! endif
		dup mb.
		dup @ +
		dup
	HeapLimit >= until
	drop cr
	." Allocated : " allocated @ hex.
	."  Free : " freed @ hex. cr
;
: ? heapdump ;
( # # # mfree mfree # # # ?
MergeFree
? )
-definitions
endwith ( Heap )

" Dump.FTH Exit" stackCheck
