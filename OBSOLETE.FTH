.( Compiling Obsolete.fth Version 8.00 ) cr
" OBSOLETE.FTH Entry" stackCheck

(*	==================	Deprecated  Words	============================	*)

vocabulary Deprecated with Deprecated +definitions

: clr ClearSteps ;
: ssf getuf if SetSpeedFactor else 20w abort endif ; ( was eg. SSF 9 1.0 )
: SetSyringeSpeeds USDs.SetSpeed ;

: c	Contact . ;
: a	lnumber 0= if -1 else drop endif Actuate ;
: FullSpeed word: motors

	ClearSteps
	motors msALL = motors msSYRS = or if
	  USDs.Fast
	endif
	motors msALL = motors msAXES = or if
	  Axes.Fast
	endif
;
: FindIndexPositions

	." The FindIndexPositions function is not necessary with Version 7" cr
	." of the MCC software. Ten rezero operations will be done to show reproducibility."

	ClrRS
	10 0 do i .
		-1 3 do
			OptoAxes i bit? if
				i RezeroLS
			endif
		-1 +loop
	loop
;
: motorpower MotorPower ;

0 variable _axch
0 variable _syrch
: AxisChannel Axis>Channel _axch ! _axch ;
: SyringeChannel Syringe>Channel _syrch ! _syrch ;

-definitions

(*	==================	Obsolete  Words	============================	*)

vocabulary Obsolete with Obsolete +definitions

: obsolete 

	<_builds immediate does>
	ascii < emit
		4 - nfa type
	ascii > emit ."  command no longer supported. Please contact peter@douglas.co.uk " cr cr
	25 abort
;

obsolete clear
( obsolete clr )
( obsolete ssf )
obsolete mb
obsolete mt
obsolete get_pitch
obsolete gp
obsolete mp
obsolete AdjustXY

obsolete s
obsolete g
obsolete p
obsolete s/s
obsolete setpos
obsolete set_pitch
obsolete set_position
obsolete set_backlash
obsolete set_speed
obsolete phase0
obsolete get_backlash
obsolete SetPositions
obsolete windup
obsolete backoff
obsolete rezero
obsolete nudge
obsolete lipStepRadius
obsolete setLipRadius
obsolete lipDump
obsolete nextOilVol
obsolete xyOil
obsolete OilLip
obsolete LipSine
obsolete lipStepX
obsolete lipStepY
obsolete setLipStepX
obsolete setLipStepY
obsolete oil
( obsolete FullSpeed )

-definitions

" OBSOLETE.FTH Exit" stackCheck

