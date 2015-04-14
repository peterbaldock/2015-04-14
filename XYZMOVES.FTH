.( Compiling XYZMoves.fth Version 8.09 ) cr
" XYZMOVES.FTH Entry" stackCheck
virtual _vdheader
virtual _vd
( noisy )
: doglegs word: on
	amAXIS amVECTOR
	on select

		1	case: or		endcase
		TRUE	case: or		endcase
		FALSE	case: not and 	endcase

		"  : (doglegs needs 0 or 1)" 1+ 60 ."abort ( " )
		
	endselect

	[pfa] amAXIS !
;
: GetAxisCoefficients word: axis 4 0 do axis 4* i + Cx f. space loop ;
: SetAxisPositions 0 do >r Axis>Channel r> SetLPosition loop ;
: Axes.Fast nAxes 0 do i Axis>Channel 1.0 SetSpeedFactor loop ;
: AxisGoto float: position word: axis

local
axis 3 and Axis>Channel 	  const	word: mno

	ClearSteps
	axis 16 and if ( Physical moveto )
		mno position  MoveTo
	else
		axis X = if position else axis GetAxisPosition endif
		axis Y = if position else axis GetAxisPosition endif
		SetTargetXY
		axis position AxisTo
	endif

	amAXIS AxisActuate. eCheck
;

: XYGoto float: X float: Y

	ClearSteps
	X Y SetTargetXY amAXIS AxisActuate. eCheck
;

: ZVGoto float: Zmm float: Vmm

	ClearSteps
	zAxis 1.0 SetSpeedFactor Z Zmm AxisTo
	nAxes 4 = if
	  vAxis 1.0 SetSpeedFactor V Vmm AxisTo
	endif
	amAXIS AxisActuate. eCheck
;
: CheckVerticalRange word: Axis float: Value word: Comment
local
	Axis Axis>Channel const word: mno
	Value -2.0 f< Value mno GetLength 2.0 f+ f> or if
		." Range error on " Axis AxisName emit ." axis to " Value f. ."  when " Comment count type cr
	endif
;
: _CVR CheckVerticalRange ;

: TwoSpeedMove word: axis float: Target float: SlowThreshold float: SlowEnterSpeed float: SlowExitSpeed 

local axis GetAxisPosition const float: PosNow
	axis Axis>Channel const word: mno
	axis PosNow " TwoSpeedMove calculating PosNow value" _CVR
	PosNow Target f< const word: Leaving
	
	Leaving if
	
		PosNow SlowThreshold 0.1 f-
		f< if	( start in slow area )
			mno SlowExitSpeed SetCurrentSpeed
	  
			SlowThreshold Target f<
		  	dup if	( need move to SlowHeight )
				axis SlowThreshold " TwoSpeedMove (raising - 2) specifying SlowThreshold" _CVR
		    		SlowThreshold
		  	else
				axis Target " TwoSpeedMove (raising - 2) specifying Target" _CVR
				Target
			endif
		else
			FALSE
			mno 1.0 SetSpeedFactor
			axis Target " TwoSpeedMove (raising - 2) specifying Target" _CVR
			Target
		endif

	else

		PosNow SlowThreshold 0.1 f+
		f< if	( start in slow area )
	  		FALSE
			mno SlowEnterSpeed SetCurrentSpeed
			axis Target " TwoSpeedMove (lowering - 2) specifying Target" _CVR
			Target
	  	else

	  		mno 1.0 SetSpeedFactor
	  		
			Target SlowThreshold 0.1 f- f<
		  	dup if	( need move to SlowHeight )
				axis SlowThreshold " TwoSpeedMove (lowering - 2) specifying SlowThreshold" _CVR
		    		SlowThreshold
		  	else
				axis Target " TwoSpeedMove (lowering - 2) specifying Target" _CVR
				Target
			endif
		endif
	
	
	 endif
	 
	 axis swap
	 fdup axis swap " TwoSpeedMove specifying final destination" _CVR
	 AxisTo 
;

: ArmGoto word: Arm  float: TargetHeight  float: SlowSpeed  float: SlowHeight
local Arm if V else Z endif const word: axis

	ClearSteps

	axis TargetHeight SlowHeight SlowSpeed SlowSpeed TwoSpeedMove
	if
		amAXIS AxisActuate. eCheck
		axis TargetHeight SlowHeight SlowSpeed SlowSpeed TwoSpeedMove drop
	endif

	amAXIS AxisActuate. eCheck
	1 UpdateMotors
;

: ZVGotoEx float: Zmm  float: Vmm  float: SlowHeight float: SlowDownSpeed float: SlowUpSpeed word: Raise
local 
	Raise if Z GetAxisPosition Zmm f< else TRUE endif
	const word: MustMoveZ
	
	nAxes 4 = if
		Raise if V GetAxisPosition Vmm f< else TRUE endif
	else
		FALSE
	endif
	const word: MustMoveV

	ClearSteps
	
	
	MustMoveZ if
		Z Zmm SlowHeight SlowDownSpeed SlowUpSpeed TwoSpeedMove	( leaves TRUE on stack if 2 Moves required )
	else
		FALSE
	endif
	
	nAxes 4 = if
		MustMoveV if
	 		V Vmm SlowHeight SlowDownSpeed SlowUpSpeed TwoSpeedMove or
	 	endif	 	
	endif
	 
	if	( 2 moves needed )
	 	amAXIS AxisActuate. eCheck

		MustMoveZ if
			Z Zmm SlowHeight SlowDownSpeed SlowUpSpeed TwoSpeedMove drop
		endif

		 nAxes 4 = if
		 	MustMoveV if
		 		V Vmm SlowHeight SlowDownSpeed SlowUpSpeed TwoSpeedMove drop
		 	endif
		 endif

	endif

	MustMoveZ MustMoveV or if amAXIS AxisActuate. eCheck endif

;
193 ?stack

: XYZVGotoEx float: Xmm float: Ymm float: Zmm  word: Arm float: VSlow float: ZSlow

local 0 word: Raise

	ClearSteps
	Z GetAxisPosition zClear f@ f< if
	  1 Raise !
	  Z zClear f@ AxisTo zAxis 1.0 SetSpeedFactor
	endif
	nAxes 4 = if
	  V GetAxisPosition vClear f@ f< if
	    1 Raise !
	    V vClear f@ AxisTo vAxis 1.0 SetSpeedFactor
	  endif
	endif
	Raise  w@  if
(*	  ." Must Raise" cr	*)
	  ." Show TipRaise.bmp" cr
	  amAXIS AxisActuate. eCheck
	endif

	." Show GotoXY.bmp" cr
	X Y XYGoto
	
	." Show TipLower.bmp" cr
	Arm Zmm VSlow ZSlow ArmGoto
;
212 ?stack

10.0 constant ZSlow0
10.0 constant VSlow0
216 ?stack

: XYZVGoto float: X float: Y float: Z  word: Arm

  X Y Z Arm VSlow0 Z ZSlow0 f+ XYZVGotoEx

;
: MustRezero?
	local 0 word: MR
	3 0 do 
	  OptoAxes i bit? if
	    i Axis>Channel 2 MotorPower 0= if -1 MR w! endif
	  endif
	loop
	MR  w@ 
;
: ROPU.Enable word: On

	On if
		MustRezero?
	else
		0
	endif
	[pfa] _ROPU? !
;
: Home word: axes

	ClearSteps

	OptoAxes 4 and zAxis 2 MotorPower 0= and if
(		." Rezeroing Z because power is off" cr )
		RezeroZ
	else
		axes 4 and if
			0 ROPU.Enable
			zAxis 1.0 SetSpeedFactor zAxis 0.0 MoveTo
			amAXIS AxisActuate. eCheck
			1 ROPU.Enable
		endif
	endif

	OptoAxes 8 and vAxis 2 MotorPower 0= and if
(		." Rezeroing V because power is off" cr )
		RezeroV
	else
		axes 8 and nAxes 4 = and if
			0 ROPU.Enable
			vAxis 1.0 SetSpeedFactor vAxis 0.0 MoveTo
			amAXIS AxisActuate. eCheck
			1 ROPU.Enable
		endif
	endif

	
	OptoAxes 2 and axes and yAxis 2 MotorPower 0= and if
(		." Rezeroing Y because power is off" cr )
		RezeroY
	else
		axes 2 and if
			0 ROPU.Enable
			yAxis 1.0 SetSpeedFactor yAxis 0.0 MoveTo
			amAXIS AxisActuate. eCheck
			1 ROPU.Enable
		endif
	endif
	
	OptoAxes 1 and axes and xAxis 2 MotorPower 0= and if
(		." Rezeroing X because power is off" cr )
		RezeroY
	else
		axes 1 and if
			0 ROPU.Enable
			xAxis 1.0 SetSpeedFactor xAxis 0.0 MoveTo
			amAXIS AxisActuate. eCheck
			1 ROPU.Enable
		endif

	endif
;
303 ?stack

( ==========================================================		Rezeroing	========================================================	)

4 BYTE 26 * array RezeroStats

0  offset .RSCount
2  offset .RSLastIndex
6  offset .RSGrossErrorCount
8  offset .RSSmallErrorCount
10 offset .RSMaxError
14 offset .RSSumError
18 offset .RSSum|Error|
22 offset .RSSumError2
318 ?stack

: Axis.s>mm Axis>Channel s>mm ;
: Axis.mm>s Axis>Channel mm>s ;

: RezeroPLOnFly

	( first save pending steps )
	16 0 do
	  i 1+ Motor .TargetPosition @
	  i 1+ Motor 2+ @
	  - i TempSteps !
	  i 1+ GetSpeed i TempSpeeds f!
	loop

	nAxes 0 do	( store plateloader position )
	  i Axis>Channel GetPosition i TempPositions f!
	loop
	
	ClearSteps
	OptoAxes 3 = if
		12 Home	( raise Z+V )
	else
		RezeroZ
		RezeroV
	endif
	RezeroY
	RezeroX
	2 0 do		( restore XY position )
	  i Axis>Channel i TempPositions f@ MoveTo
	loop
	amAXIS AxisActuate.

	nAxes 2 do	( restore ZV position )
	  i Axis>Channel i TempPositions f@ MoveTo
	loop
	amAXIS AxisActuate.

	16 0 do
	  i TempSteps @
	  i 1+ Motor 2+ @
	  + i 1+ Motor .TargetPosition _!
	  i 1+ i TempSpeeds f@ SetCurrentSpeed
	loop

;
	
: RezeroWU	word: axes

	0 ROPU.Enable	( inhibit RezeroPLOnTheFly )

	msAXES axes MoveToStop
	msAXES axes WindUp

	500 ms

	msAXES axes BackOff
	1 UpdateMotors
	1 ROPU.Enable	( Reenable RezeroLOnTheFly as appropriate )
;

377 ?stack
: ReturnToOpto word: Axis
local	Axis Axis>Channel 		const word: mno
	Axis NominalOptoPosition f@ const float: NOP

	ClearSteps
	mno GetPosition NOP f- fabs 0.001 f> if
		mno 1.0 SetSpeedFactor
		mno NOP MoveTo
		$3C AxisActuate. ( 00111100 )
	endif
	mno 0.25 SetSpeedFactor
	mno 400.0 MoveLBy $3C AxisActuate.
;
50 constant _CDelay
5.0 fconstant _CSpeed

: CreepToOpto word: Axis
local Axis Axis>Channel 		const word: mno

	ClearSteps
	Axis 2 < if
	  _CDelay ms
	  mno _CSpeed SetCurrentSpeed
	else
		mno nAxes 4 = if ( XYZV ) _CSpeed else ( Nano ) _CSpeed 2.0 f/ endif SetCurrentSpeed
	endif
	mno -0.5 MoveBy $304 Actuate
	mno 50.0 MoveBy $314 Actuate

	(* take account of backlash/gravity on vertical axes *)

	Axis 2 >= if
	  ( mno 1.0 MoveBy
	  $04 Actuate )
	  _CDelay ms
	  mno _CSpeed SetCurrentSpeed
	  mno -2.0 MoveBy $114 Actuate
	endif

	mno 1.0 SetSpeedFactor
	( _vdheader xAxis _vd ... cr )
;

: BackOffOpto word: Axis
local Axis Axis>Channel 		const word: mno

	ClearSteps mno 0.2 SetSpeedFactor mno -0.5 MoveBy $04 Actuate

;

: GotoOpto word: Axis	Axis ReturnToOpto 	Axis CreepToOpto ;
0 variable _rre	(* Stands for    ' return Rezero errors' *)
: RezeroLS word: Axis

local

Axis Axis>Channel 		const word: mno
mno 2 MotorPower		const word: checking?
Axis RezeroStats 		const word: ptr

	( Axis AxisName emit ."  RezeroLS: Disabling _ROPU " ... cr )
	0 ROPU.Enable	( inhibit RezeroPLOnTheFly )
	Axis ReturnToOpto
	( Axis BackOffOpto )
	Axis CreepToOpto
	mno GetPosition 		const float: posNow
	Axis NominalOptoPosition f@	const float: indexPos
	posNow indexPos f-		const float: diff
	diff mno Motor .Pitch f@ f/
	ftol dup 0< if 1+ endif ( divide by 65536 and round up )
	const word: delta

	checking? if
	  ptr .RSCount ++
	  posNow ptr .RSLastIndex f!
	  diff ptr .RSSumError f+!
	  diff fabs ptr .RSSum|Error| f+!
	  diff dup f* ptr .RSSumError2 f+!

	  delta 2 >= if
		ptr .RSGrossErrorCount ++
	  else
		delta if ptr .RSSmallErrorCount ++ endif
	  endif

	  diff fabs ptr .RSMaxError f@ fabs f> if diff ptr .RSMaxError f! endif
	endif
	( mno Motor dup 2 +  w@  $FF00 and swap .PhaseOffset _w! )
	mno  indexPos SetPosition
	( ." SetPosition to " indexPos f. cr )
	Axes.Fast
	mno 0.0 MoveTo 4 Actuate
	1 UpdateMotors
	1 ROPU.Enable	( Reenable RezeroLOnTheFly as appropriate )
	( Axis AxisName emit ."  RezeroLS: Reenabled ROPU " cr )

	_rre  w@  if
		checking? if 
	  		diff delta ( return error and missed cycle count )
	  	else
	  		0.0 0
	  	endif
	endif ;

( =====================	Rezero error recording and reporting ===================== )
485 ?stack

: ClearRezeroRecord dword: Axes
 
 	ds> >es
	4 0 do
		Axes i bit? if
			i RezeroStats 26 0 fill
		endif
	loop
;
: ClrRS 15 ClearRezeroRecord ;	ClrRS
497 ?stack
( 0 RezeroStats )
: rsdump

local
0 RezeroStats address: RRec
0 dword: mno

cr me.identify cr
."   #R   Index    Last   #>0  #>2   E.Max    E.Sum   E.|Sum|     s   " cr

	nAxes 0 do
	  i Axis>Channel mno ! 
	  i AxisName emit

	  RRec  @  .RSCount  w@ 
	  i AxisOffset f@
	  RRec  @  .RSLastIndex f@
	  RRec  @  .RSSmallErrorCount  w@ 
	  RRec  @  .RSGrossErrorCount  w@ 
	  RRec  @  .RSMaxError f@
	  RRec  @  .RSSumError f@
	  RRec  @  .RSSum|Error| f@
	  RRec  @  .RSCount  w@  if
		RRec  @  .RSSumError2 f@ RRec  w@  .RSCount  w@  wtof f/ fsqrt
	  else
		0.0
	  endif

	
	  " %3d  %7f %7f %3d  %3d   %7f  %7f  %7f  %7f%<" format count type
	  26 RRec +!
	loop
	cr
	." #R    : Number of Rezeros with power ON. (Power OFF not recorded)" cr
	." Index : Optoswitch reference position in mm. " cr
	." Last  : Last Rezero position in mm." cr
	." #>0   : COUNT of Rezeros where 1 or 2 electrical cycles were missed." cr
	." #>2   : COUNT of Rezeros where more than 2 electrical cycles were missed." cr
	." E.*   : Maximum positioning errors and sums of errors in mm." cr
	." s     : Root of variance (r.m.s. of errors)." cr
	."         The value of |E.Max| should not exceed 0.05mm" cr
;
: RezeroDump rsdump ;

: wiggle word: axis float: distance word: ntimes

	ntimes 0 do
	  axis distance MoveBy amAXIS amLIMIT or AxisActuate. eCheck
	  axis distance fnegate MoveBy amAXIS amLIMIT or AxisActuate. eCheck
	loop
;
549 ?stack
" XYZMOVES.FTH Exit" stackCheck
