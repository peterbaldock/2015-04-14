.( Compiling USDMoves.fth Version 8.00 ) cr
" USDMOVES.FTH Entry" stackCheck

: USDs.SetPosition

	0 do
	  swap Syringe>Channel swap SetLPosition
	loop
;
: USD.SetSpeed word: Sno float: Speed
	Sno Syringe>Channel Speed SetCurrentSpeed
;
: USDs.SetSpeed ( Sno1, Speed1, ...., n )   0 do USD.SetSpeed loop ;

: USDs.SetSpeedFactor

	0 do
	  swap Syringe>Channel swap SetSpeedFactor
	loop
;

: USDs.Fast nSyrs 0 do i Syringe>Channel 1.0 SetSpeedFactor loop ;

: USDs.Home word: Drives
	ClearSteps USDs.Fast
	nSyrs 0 do
		Drives i bit? if
			i Syringe>Channel 0.0 MoveTo
		endif
	loop
		
	amSYRINGE msSYRS Actuate.
	get_status
;

: USDs.MoveToLS word: Drives word: Direction
local
	Drives OptoDrives and const word: OD
	ClearSteps
	nSyrs 0 do
		OD i bit? if
			( ." Step on USD " i . cr )
			i Syringe>Channel
			Direction if -90.0 else 5.0 endif  MoveBy
		endif
	loop
		
	amSYRINGE amVECTOR or amLIMIT or
	Direction 0= if amLS_HIGH or endif
	msSYRS Actuate.
	get_status
;

: USDs.RezeroWU word: Drives

	cr ." Calling MoveToStop..." cr
	msSYRS Drives MoveToStop
	cr ." returned from MoveToStop, calling WindUp..." cr
	msSYRS Drives WindUp
	cr ." returned from WindUp. Waiting 250 ms" cr

	250 ms

	cr ." Calling BackOff" cr
	msSYRS Drives BackOff
	ClearSteps
	nSyrs 0 do
	  Drives i bit? if
	    i msSYRS GetMno dup 1.0 SetCurrentSpeed 2.0 MoveTo
	  endif
	loop

	amSYRINGE amBUTTON not and SyringeActuate.
	
	1 UpdateMotors

	USDs.Fast

;
: USDs.RezeroLS word: Drives

	Drives -1 USDs.MoveToLS
	0= if
	  nSyrs 0 do
	    Drives i bit? if
		i Syringe>Channel 0.05 SetSpeedFactor
	    endif
	  loop
	  Drives 0 USDs.MoveToLS
	else
	  1
	endif

	0= if	( successful, so check positions of all repositioned drives )
	
		nSyrs 0 do
			Drives OptoDrives and i bit? if
				i Syringe>Channel GetPosition ." Drive " i . ." at " f. cr
				i Syringe>Channel 0.0 SetPosition
			endif
		loop
		." SyringeRezero successfully completed" cr
	else
		." SyringRezero was prematurely stopped" cr
	endif
	
	1 UpdateMotors

	USDs.Fast
;

: SyringeRezero word: Drives
	Drives OptoDrives not and USDs.RezeroWU
	Drives OptoDrives and ?dup if USDs.RezeroLS endif
;
: LCPDrive.Home 1 LCPChannel shl USDs.Home ;

" USDMOVES.FTH Exit" stackCheck
