.( Compiling    Debug.fth : testing upload ) cr

: siren word: frequency word: duration word: sweep

	begin
		frequency duration sweep whoop
	getKey until
;
: gliss word: frequency word: duration word: sweep

	begin
		frequency duration sweep whoop
		frequency sweep + duration sweep negate whoop
	getKey until
;


(*
: upload address: FName

	." Loading file : " FName count type space  FName LoadFile
;
*)
: ? " register.fth" upload ;


(*
: USBStatus	USBPort @ in ;
: USBData	USBPort @ inw ;

: ? USBStatus ." Status = " byte. ."  Data = " USBData hex. ;
: ?? begin USBGet if emit endif getKey until ;
*)


vocabulary Test with Test +definitions

100 variable LightTime
: _tbl word: bno

	8 0 do
		." test LED at " bno 1 r. ascii . emit i byte. cr
		i 2^ bno WriteLED LightTime @ 3 * ms
		i 2^ not bno WriteLED LightTime @ 3 * ms
	loop
	9 1 do
		$FF i 2^ 1- - bno WriteLED LightTime @ 3 * ms
	loop

	$0F bno WriteLED LightTime @ 5 * ms
	$F0 bno WriteLED LightTime @ 5 * ms
	$55 bno WriteLED LightTime @ 5 * ms
	$AA bno WriteLED LightTime @ 5 * ms
	$33 bno WriteLED LightTime @ 5 * ms
	$CC bno WriteLED LightTime @ 5 * ms
	$96 bno WriteLED LightTime @ 5 * ms
	$69 bno WriteLED LightTime @ 10 * ms
	
	0 bno WriteLED
;
: >float 
	dup wsplit swap drop
	dup 0= swap -1 = or
	if ltof endif
;
: ms float: Delay
local 0 dword: waiter

	Delay >float waiter Alarm.Set

	begin
		getKey $FF and $1B = if "  : Interrupted with <ESC>" 1+ 5 ."abort endif
		waiter Alarm.Test
	until
;

: dimCycle word: bno
local	10.0 float: delay
	0 word: lc
	1.1 float: dir

	begin
		
		getKey 0 =
	while
		$AA bno WriteLED delay f@ ms
		$AA not bno WriteLED 10.0 delay f@ f- ms
		lc ++ lc @ $3 and 0= if
			delay f@ 10.0 > if 0.9 dir f! endif
			delay f@ 0.2 < if 1.1 dir f! endif
			dir f@ delay f@ f* delay f!
		endif
	repeat
;

: lights
	PushLEDs
	3 0 do i _tbl loop
	PopLEDs
;
-definitions
endwith
with Snap +definitions

: idleSnap CSnapRecord AutoSnap DSnapRecord AutoSnap XSnapRecord AutoSnap ;
: itime
	GetNanoTicks
	1000 0 do
		idleSnap
	loop
	GetNanoTicks swap - ltof 0.893 f* 1000.0 f/
	." idleSnap time (us) : " f. cr
;
 


: ` XSnap XSnapRecord 1 Snap. ;
: `` XSnapRecord 2 MemSnap drop ` ;
: `? XSnapRecord 0 Snap. ;

-definitions
endwith

(*

2014-12-09
There was a problem with BackOff : it used 0 Actuate which caused a hang.
2015-01-01
lnumber was not behaving
: lnumber

	wsword 
	>asciiz
	dup hex. cr
	here 1 dump
	atol
( ." After atol in lnumber " .s cr )
	if
	  swap drop ( lose text pointer ) TRUE
	else
	  drop FALSE
	then
;
*)
: xtime dword: n
	GetTickCount
	n 0 do 1000000 0 do loop loop
	GetTickCount swap - 55 * ltof 1000.0 f/ f.
;
(*
2014-02-05
Extended memory timing
.( Timing : ) 100 xtime cr
*)

" DEBUG.FTH Exit" stackCheck
