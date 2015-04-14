.( Compiling     List.FTH Version 8.04 ) cr
" List.FTH Entry" stackCheck

with Text

: listWords address: voclink address: mask word: Limited

local	0 dword: Count
	[ nop ] 0 trappedKey !

	voclink 8 - const word: stoplink

	." Words matching mask : " mask countz type cr cr

(	." voclink = " voclink hex. cr )
	voclink	@ ( point to end of list )
	begin
	  dup 2-
	  dup 2-
	  dup c@ over 0 swap _c! ( temporarily nul terminate )
	  over over >r >r
	  - mask match*
	  r> r> swap _c! ( reinstate length )
	  if
	  	2-
		dup c@ rdup - r> 20 ntype Count @ 1+ Count !
	  	Count @ 63 and 0= if
			waitKey $0ff and $1B = if drop quit endif
		endif
	  else
	  	drop
	  endif
	  dup if
		dup stoplink = if
		  drop 0
		else 
			dup
			2- c@ Limited and
			if
			  drop 0
			else
		  	  @ ( next word )
			endif
		endif
	  endif
	?dup 0= until

	cr
	." Word count = " Count w@ . cr
;
endwith
	
: getwild
	wsword >asciiz ( ensure null terminated ) 
	dup c@ 0= if ascii * over _c! endif
;
: vlist context @ getwild 0 listWords ;
: olist context contextIndex @ 4* + @ getwild 0 listWords ;
(*
( address: voclink address: mask )

local
	nopcomp
	0 word: Count
	0 const word: Limited	
	xcontext @ dword: linkPtr
	xcontext @ linkPtr !
	( getwild const address: mask )
	0 trappedKey ! 
(	." Words matching mask : " mask countz type cr cr )

	begin
	  linkPtr @ @ dup
	while
	  dup linkPtr !
	  
	  8 + ( point to pfa )
	  nfa 20 ntype Count ++
  	  Count @ 63 and 0= if
		waitKey $FF and $1B = if quit endif
	  endif
	repeat
	cr
	." Word count = " Count @ . cr
;
*)

: withlist
	contextIndex @ 1+ 0 do i 4* context + @ loop
	contextIndex @ 1+ 0 do nfa type cr loop
;

: ?vocabulary	dup 10 - c@ VOCABULARY and ;
: StackVocabularies address: voc word: level

	voc

	begin
		@ dup 2- c@ VOCABULARY and
		if
			dup voc > if
				dup >r 8+ level 1+ StackVocabularies r>
			endif
		endif
		dup voc <
	until
	8+ level swap
;

: voctree
	0 ' ['] forth max 0 StackVocabularies
	begin
		?dup
	while
		swap 4* spaces
		nfa type cr
	repeat
;



" List.FTH Exit" stackCheck
