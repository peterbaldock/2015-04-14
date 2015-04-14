.( Compiling     Text.FTH Version 8.00 ) cr
" Text.fth Entry" stackCheck

1024 staticallot constant pad

: ascii	sp word 1+ c@

	compiling? if
		compile (literal) ,
	endif
; immediate

: countz dup lenz ; ( adr - adr, len ) ( equivalent of count for ascii string )

: nfa dword: pfa   ( long: pfa w- long: nfa, word: length )
	
	pfa 12 -
	dup c@ >r r - r>
;

vocabulary Text with Text +definitions

: es:cputs 
	dup begin
	 dup es:c@ while
		 1+
	repeat
	swap dup - es:type
;

: move>asciiz	( source, dest - )

	>r
	count dup -rot
	r swap cmove
	r> + 0 swap _c!
;

: startswithn >r str- r> >= ; ( address: text address: match word: n - true/false )
: strstrn address: text address: match dword: n
local	match c@ const dword: cstart
	
	cstart if
	  text lenz n - 1+ const dword: ntimes
	  0
	  ntimes 0> if
	    ntimes 0 do
		text i + c@ cstart = if
			text i + match n startswithn if drop text i + leave endif 
		endif
	    loop
	  endif
	else
	  text
	endif
;

: match* var address: text var address: mask

  begin
    mask @ c@ ?dup
  while
	dup ascii * = if
		mask ++ 
		mask @ c@ ?dup 0= if drop TRUE exit endif
		over = if ( if ** )
			text @ c@ != if ( next char is NOT * ) FALSE exit endif
		else	( not **, so look for next * in mask )
			mask @ swap strchrz
			?dup 0= if
			  mask @ lenz
			else
			  mask @ -
			endif
			>r text @ mask @ r> strstrn
			dup if text _! else exit endif
		endif
	else
		text @c@ != if FALSE exit endif
    	endif
	text ++
	mask ++

  repeat
  text @c@ 0=
;

string _#if "#if"
string _#else "#else"
string _#endif "#endif"

: SkipInputUntil address: token

local >in w@ const dword: start

(	." >in=" >in w@ hex. ."  start=" start hex. ." looking for " token count type cr )
	
	begin
		wsword
(		dup count type space )
		dup 1+ c@
		0= if
			drop
(			cr ." EOF at " >in w@ hex. ." start=" start hex. cr )
			start >in _w! FALSE exit
		endif
	token $= until
(	cr token count type ." found at " >in w@ hex. cr )
	TRUE
;
: #bad? address: prompt 
	0= if
		prompt count type ."  : " "  (no matching #endif) " 1+ $30 ."abort ( " )
	endif
;
: #next? address: token
local >in w@ const dword: start
	token SkipInputUntil if
		>in w@ start >in _w! 
		_#if SkipInputUntil if
			>in w@ over over > if
				>in _w! drop _#endif #next? _#if #bad?
				token #next?
			else
				drop >in _w! TRUE
			endif
		else
			>in _w! TRUE
		endif
	else
		start >in _w! FALSE
	endif
;


: token

	<_builds

	  begin
	    next dup
	  iswhite? while
	    drop
	  repeat

	  >r
	  begin
	    next dup if
	      dup r= if
		drop 0w
	      else
		1w
	      then
	    then
	  while
	   c,
	  repeat

	  rdrop 0w c,

	does>
	  swap >r 1w
	  begin
	    over c@
	    0= if
	      drop 0w TRUE
	    else
	      over c@ r=
	    then
	  not while
	    1+ swap 1+ swap
	  repeat
	  swap drop r> swap
;

(*
token	step-punc?	@ ,;:#'!"œ$%^&()[]{}@ 

( extra " to balance syntax checking )
token	radix-punc?	@$ fFlLhHxX%@
token	sdigit?		@+-0123456789@
token	fpoint?		@+-0123456789.,@
token	maths-op?  	@=+-*/%\|&^@
*)

: UniqueName date time drop " %x%x%02d%02d%02d" format ;
: UniqueFileName dword: extension date time drop extension " %x%x%02d%02d%02d.%s" format ;

-definitions

: #if 0= if
	_#else #next?
	0= if _#endif #next? _#if #bad? endif
  endif
; immediate

: #else _#endif #next? _#else #bad? ; immediate
: #endif ; immediate

endwith

" Text.FTH Exit" stackCheck
