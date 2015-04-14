.( Compiling  Numbers.FTH Version 8.00 ) cr
" Numbers.FTH Entry" stackCheck

: whex. word. space ;
: >float word: p1 word: p2 ( turn any number on the stack into a float )

	p1 p2
	p2 $3C00 $4500 between p2 $8C00 $C500 between or 0= if
	  p2 p1 or if
	  	cwd ltof
	  endif
	endif
;


: lnumber

	wsword >asciiz atol
( ." After atol in lnumber " .s cr )
	if
	  swap drop ( lose text pointer ) TRUE
	else
	  drop FALSE
	then
;

: fnumber
local	wsword ( dup count type cr )
	>asciiz atof const word: ftype

	ftype if swap drop endif
	ftype
;

: getll
  lnumber 0= if
    ERR_PARM1 StepError _w! FALSE exit
  then
  lnumber if
    TRUE
  else
    ERR_PARM2 StepError _w! FALSE
  then
;

: getuf
  lnumber 0= if
    ERR_PARM1 StepError _w! FALSE exit
  endif
  fnumber if
    TRUE
  else
    ERR_PARM2 StepError _w! FALSE
  then
;

: getuuf
  lnumber 0= if
    ERR_PARM1 StepError _w! FALSE exit
  endif
  lnumber 0= if
    drop ERR_PARM2 StepError _w! FALSE exit
  endif
  fnumber if
    TRUE
  else
    drop ERR_PARM3 StepError _w! FALSE
  then
;
: getu

  lnumber
  if
    TRUE
  else
    ERR_PARM1 StepError _w! FALSE
  then
;


: nibbleshow	( value4, x, y, colour w- )

(	8 shl >r
	$A0 * over + + swap
	$0f and dup $0a >= if 7 + then ascii 0 +
	r> or swap
	es> >r $B800 >es es:! r> >es ) drop drop drop drop
;


: byteshow	( value8, x, y, colour - )

	4 pick 4 shr 4 pick 4 pick 4 pick
	nibbleshow rot 1+ -rot nibbleshow
;

: wordshow dword: value dword: x dword: y dword: colour

(	4 pick 8 shr 4 pick 4 pick 4 pick
	byteshow rot 2+ -rot byteshow )
;

: dr.  dword: val dword: places

	val
	val 0< if negate endif
	places <# n#
	val sign ( 0< if ascii - hold endif )
	#> type
;

: r. dr. ;


" Numbers.FTH Exit" stackCheck
