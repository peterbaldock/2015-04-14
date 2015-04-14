.( Compiling    Hooks.fth Version 8.00 ) cr
" HOOKS.FTH Entry" stackCheck

0 variable trappedKey

decimal
ds> >es

vocabulary Hooks with Hooks +definitions

$10 constant MESSAGE
$20 constant POLL

( noisy 8 ?stack )
0 variable OverlappedCommandCount
0 variable (keyLink)
0 variable keyLink
0 variable lastKey
0 variable pollCount

$00AE constant	requestCommsReset

create editBufferLine 0 $84 staticallot !

: hook	word: index word: attributes

	<_builds
	  0 , 0 w, 			( link=0, linkseg=0 )
	  'processHook w, cs> w,	( +6=execution address )
	  attributes c,			( +10=attr)
	  index c,			( +11=index=number )
	  0 w, 0 c, 0 c, 		( +12=mask=0, +14=countw +15= spare )
	  ds> w,			( +16=data segment )
	  ['] hook 4- @ ,		( +18=???? )
	  ColonDefinition		( +22=$16=FORTH execute address )
	  [compile] ]
	does>
	$16 + execute
;
: installHook dword: pfa dword: fn

	( ." Installing hook with pfa = " pfa hex. cr )
	fn al c!		( function number eg message = 10h )
	pfa 4+ edi ! 		( hb ptr )
	pfa 14 + c@ cl c!	( attributes )
	pfa 15 + c@ ch c!	( index )
	ds> ds w! 
	0 ah c!			( fn 0 = install )
	0 dx w!			( mask = 0 )
	$80 int drop
;
: setHook ( hbPtr, fnum, index - flags )
	0 ah c!	( function 0 - install )
	ch c!		( ch = index )
	al c!		( al = number )
	di w! 		( ds:di = ptr )
	ds> ds w! 
	0 cl c!		( cl = attributes )
	0 dx w! 		( dx = mask )
	$80 int drop
;
: killLink ' ?dup if 4+ 0 over _! 2+ 0 swap _! endif ;

: message word: number word: source word: destination word: ID

	create { number source destination ID 0 0 0 0 c} drop
;
: done	( message - ) 2+ dup es:c@ $80 or swap es:c! ;
: done?	( message - boolean ) 2+ es:c@ $80 and $80 = ;
: nextDigit

	>r
	r es:c@
	$39 = if
	 ( ascii 0 ) $30 r 2- nextDigit
	else
	 r es:c@ 1+
	endif
	r> es:c!
;
$FF 0 hook pollDefault

	pollCount ++
	pollCount @ 1000 >=
	if
	  es> >r $B800 >es
	  $16 nextDigit
	  r> >es
(	  StepError w@ $48 0 $4F wordshow )
	  0 pollCount ! 
	endif
;
$80 ' pollDefault $0E + _c!	( preprocess )

(	==================	Diagnostics	=============	)

: msg.	address: msg word: seg
	
	es> seg >es

	msg	." Message at  : " seg word. ascii : emit word. cr
	msg	." Number      : " es:c@ byte. cr
	msg 1+	." Source      : " es:c@ byte. cr
	msg 2+	." Destination : " es:c@ byte. cr
	msg 3 +	." ID          : " es:c@ byte. cr
	msg 4+	." Data/pointer: " es:@ dword. cr

	>es
;
: t. 6 * taskList + 1 cs:dump ;
: far. dup 16 shr word. $3A emit word. ;
: hb. address: hb word: seg
local
	seg >es
	hb 4+ const address: ptr
	." HOOK "
	hb es:@ [pfa] pollDefault @ =
	if
		hb nfa type
	else
		hb es:@ if
			." <no name>"
		else
			hb 1- dup es:c@ - hb 1- es:c@ es:type
		endif
	endif
	."  CS=" cs> word. ."  ForthDS=" ds> word.
(	hb 16 - 2 es:dump )
	."  start: " ptr seg word. ascii : emit dword. cr

	ptr     es:@	." Link  : " ptr 4+ es:w@ word. ascii : emit dword.
	ptr 10 + es:c@	."   Attr  : " byte.
	ptr $0c + es:w@	."   Mask  : " word.
	ptr $0f + es:c@	."  Spare : " byte. cr

	ptr 6 + es:@	." Entry : " far.
	ptr 11 + es:c@	."       Index : " byte.
	ptr $0e + es:c@	."   Count : " byte.
	ptr $10 + es:w@	."    DS    : " word. cr
	ptr $12 + 1 es:dump cr
;
: chain. ( function - )
local
	
	cs> >es 6 * taskList + 		( tasklist pointer )
	dup es:@ dword: link
	4+ es:w@ dword: seg
	0 word: Count
	begin
	  seg @ link @ or
	while
	  Count @ . Count ++
	  link @ 4- seg @ ( .s cr ) hb.
	  seg @ >es
	  link @ dup es:@ link ! 4+ es:w@ seg !
	repeat
	drop
;

MSG_KBD_LINE 0 0 0 message	RxKeyboardLine
MSG_KBD_CHAR 0 0 0 message	RxKeyboardChar

95 ?stack

(*
RxKeyboardLine .( RxKeyboardLine = ) hex. cr
RxKeyboardChar .( RxKeyboardChar = ) hex. cr
*)
$016 0 hook pollKbd

	$11 ah c!
	$16 int
	!zero? if
	  $10 ah c! $16 int
	  ax w@ dup lastKey w! 
	  RxKeyboardChar 4+ _!
	  RxKeyboardChar broadcast
	endif
;

MSG_KBD_CHAR 0 hook showKeyStroke

	>es dup c@
	MSG_KBD_CHAR = if
	  where >r >r 46 0 at
	  4 + es:w@ dup hex.
	    $FF and $1B = if bye then
	  r> r> at
	endif
;

4 0 hook pollComms
	( ascii . emit )
	handleComms
;

$F1 0 hook trapKey

	dup es:c@ MSG_KBD_CHAR =
	if
	 	dup 2+ es:c@ $C0 and
		0= if
			dup 4 + w@ trappedKey ! done
		else
			drop ( ." Not done " cr )
		endif
	else
		drop ( ." Not MSG_KBD_CHAR " cr bye )
	endif
;
" FORTH::trapKey" stackCheck
' pollDefault POLL installHook killLink pollDefault
' pollKbd POLL installHook
' pollComms POLL installHook
' trapKey MESSAGE installHook

-definitions

: inKey poll trappedKey @ ;
: getKey poll trappedKey @ 0 trappedKey ! ;
: waitKey
	begin
	  getKey
	  ?dup
	until
;
: wait 0 trappedKey ! begin inKey until ;
: ... 
	500 10 beep ." waiting..."
	waitKey cr $FF and $1B = if
		" : Interrupted" 1+ 5 ."abort
	endif
;
187 ?stack
" FORTH::wait" stackCheck
15 0 WriteLED
0 ByeOnError
: protect

   ' ?dup if
     keyLink w@ 0= if
	4 - dup (keyLink) w! dup w@ keyLink w! 
	['] bye 4 - w@ swap w! 
     endif
   else
     cr ." Warning! protect target word not found." cr
   endif
;
: unprotect keyLink w@ (keyLink) w@ w! 0 keyLink w! ;


$f2 0 hook logSpuriousInput   ( index f2 puts this handler behind
				CONIO::editBuffer_messageHandler as a trap )

	>es
	dup done? 0= if
	  dup es:c@ MSG_HOST_COMMAND =
	  if
	    dup done OverlappedCommandCount w++
	  endif
	endif
	drop
;
( ' logSpuriousInput MESSAGE installHook )
( 017 0 hook pollInputPackets

    inProgress c@ 2 = if
     inREADY 2+ count type cr
     0 inProgress c!
    then
;
' pollInputPackets POLL installHook
)

( MESSAGE chain. bye )
( ' showKeyStroke MESSAGE installHook )
endwith

" HOOKS.FTH Exit" stackCheck
