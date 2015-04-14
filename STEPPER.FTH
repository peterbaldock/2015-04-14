.( Compiling  Stepper.fth Version 8.05 ) cr
" STEPPER.FTH Entry" stackCheck
( noisy 3 ?stack )

-1	StepMask _w! 
16	DWORD	array	TempSteps
16	FLOAT	array	TempSpeeds
16	FLOAT	array 	TempPositions
16	BYTE	array	MotorProperty

16	WORD	array	_PCTable
2	FLOAT	array	TipLengthAdjust
	FLOAT	table	LengthOffset
	{ 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 }
	SetTableLength LengthOffset

	FLOAT	table	Cx
	{ 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 }
	SetTableLength Cx ( PlateLoader correction coefficients )

: Cy	4+ Cx ;
: Cz	8 + Cx ;
: Cc	12 + Cx ;
13 @tea Cx constant	_Txy
0 constant _TxyValid
: InitializeArrays

	16 0 do
		0 i _PCTable w! 
		0 i MotorRecord !
		( 0.0 i @tea Cx f! )
	loop
	0.0 0 TipLengthAdjust f!
	0.0 1 TipLengthAdjust f!
	1.0 12 @tea Cx f!
;
InitializeArrays
38 ?stack
( forget InitializeArrays )
16	constant	OPTO_INDEX
0	constant	_UsePC

: UsePositionCorrection if -1 else 0 endif [pfa] _UsePC ! ;
: CorrectionTable word: mno here mno 1- _PCTable w! here 0 , ;
: /Table 4/ swap w! ;

(*
: MTC word: mno float: pos

	mno pos	( set up original parameters )
	_UsePC mno 1- _PCTable w@ and	( get interpolation table address )
	4 interpolate drop MoveTo

;
: GPC word: mno

	mno GetPosition
	_UsePC mno 1- _PCTable w@ and
	-4 interpolate drop
;

: MoveTo	MTC ;
: GetPosition	GPC ;
*)

: @AxisLengthOffset Axis>Channel
	dup 0> if
	  1- nop @tea LengthOffset
	else
	  ." @AxisLengthoffset index error; mno = " . cr 128 abort
	endif
;

40.0	variable	zClear
40.0	variable	vClear

0.000125 SetTimebase
88 ?stack

: _SetTxy float: X float: Y
	X _Txy f!
	Y _Txy 4+ f!
	X Y f* 10000.0 f/ _Txy 8 + f!
	-1 [pfa] _TxyValid ! 
;

: _PnComp float: Xtarg float: Ytarg word: axis

	axis 2 min 4*
	1+ dup 1+ dup 1+
	Cx Xtarg f* Ytarg f* 10000.0 f/ >r
	Cx Ytarg f* 100.0 f/ >r
	Cx Xtarg f* 100.0 f/ r> f+ r> f+
;
: _AxisCorrect word: axis float: pos float: Xtarg float: Ytarg
	Xtarg Ytarg axis _PnComp
(	axis Z = if
		." Z Axis Correction = " fdup f. cr
	endif
)
	pos f+
	axis Axis>Channel swap
;
: TipLengthAdjustment word: mno
	mno zAxis = mno vAxis = or if
	 mno zAxis = if 0 else 1 endif TipLengthAdjust f@
	else
	  0.0
	endif
;

: MoveLBy	fnegate MoveBy ;
: MoveLTo	word: mno float: pos
	mno
	mno GetLength mno 1- LengthOffset f- pos f-
	mno TipLengthAdjustment f-
	MoveTo
;
: AxisTo word: axis float: pos
	axis nAxes < if
	  axis pos 1 Cc 2 Cc	 _AxisCorrect MoveLTo
	else
	  axis . ."  is not a valid axis " cr
	endif
;
: GetAbsPosition word: mno mno GetLength mno GetPosition f- mno TipLengthAdjustment f- ;	
: GetLPosition word: mno	mno GetAbsPosition mno 1- LengthOffset f- ;
: SetLPosition word: mno float: pos
	mno dup GetLength mno 1- LengthOffset f-
	mno TipLengthAdjustment f-
	pos f- SetPosition
;
: _iterateTxy
local
	xAxis GetLPosition const float: Px
	yAxis GetLPosition const float: Py

	Px Py
	3 0 do
		_SetTxy
		Px 1 Cc 2 Cc X _PnComp f-
		Py 1 Cc 2 Cc Y _PnComp f-
	loop
	_SetTxy
;
: GetAxisPosition word: axis 

	axis nAxes < if
	  _TxyValid 0= if
	    _iterateTxy
	  endif
	  axis Axis>Channel GetLPosition
( dup ." LPosition = " f. cr )
	  1 Cc 2 Cc axis _PnComp f-
( dup ." GetAxisPosition returns " f. )
	else
	  ." Axis out of range " 0.0
	endif
;
: gap GetAxisPosition .s cr f. ;

: GetAxisCorrection word: axis
	axis nAxes < if
	  axis Axis>Channel GetAbsPosition
	  axis GetAxisPosition f-
	else
	  0.0
	endif
;
: SetAxisPosition	1 Cc 2 Cc _AxisCorrect SetLPosition ;
: SetClearance		dup zClear f! vClear f! ;
: SetTargetXY	float: Xpos float: Ypos
local
	Z GetAxisPosition const float: ZNow
	V GetAxisPosition const float: VNow
	Xpos Ypos _SetTxy
	0 Xpos AxisTo
	1 Ypos AxisTo
	2 ZNow AxisTo
	3 VNow AxisTo
	0 [pfa] _TxyValid ! 
;
: AxisXYBy float: dX float: dY

	X GetAxisPosition dX f+
	Y GetAxisPosition dY f+
	SetTargetXY
;

: RaiseTo word: mno float: pos
local
	mno zAxis = if Z else V endif const word: axis
	axis GetAxisPosition pos f< if axis pos AxisTo endif
;

: eCheck get_status if 5 abort endif ;

: Actuate? Actuate eCheck ;

0 constant _ROPU?
: SetROPU [pfa] _ROPU? ! ;
: off
	13 1 do
	  i 0 MotorPower
	loop
	BeltDrive? SetROPU
;

: LS	getu if GetMotorLSInputs . then ;

: GetMno word: index word: motors

	index
	motors msSYRS = if Syringe>Channel endif
	motors msAXES = if Axis>Channel endif
;
: Position. word: index word: motors

	space index .
	motors msAXES = if
		index GetAxisPosition
	else
		index motors GetMno GetLPosition
	endif
	f.
;
218 ?stack
0 variable PrefixMsg
0 variable PostfixMsg
0 constant _supFB
: SuppressFeedback 1 [pfa] _supFB ! ;
: UpdateMotors word: forced
0 local word: nMotors

	_supFB if
	  0 [pfa] _supFB ! 
	else
		PrefixMsg @ ?dup if count type space 0 PrefixMsg ! endif

		HasStepped w@ SyringeMask and
		forced or if

			."  SPOS "
			nSyrs 0 do
			    HasStepped i msSYRS GetMno 1- btr
			    forced or if
				i msSYRS Position.
				nMotors ++
			    endif
			loop

		endif
		HasStepped w@ AxisMask and
		forced or if
			nMotors @ 4 > if cr endif
			."  APOS "
			nAxes 0 do
			    HasStepped i msAXES GetMno 1- btr
			    forced or if
				i msAXES Position.
			    endif
			loop
		endif
	
		PostfixMsg @ ?dup if space count type 0 PostfixMsg ! endif

		cr
	endif

	0 PulseOut _w! 
;




virtual RezeroPLOnFly
virtual xyzdump
virtual sdump
0 variable actdiag
0 variable TimingOn
0 variable StartTime
0 variable TotalTime
0 variable ActuateTime
0 variable ActuateAndFeedbackTime

0 constant _nomove
: NoMove [pfa] _nomove ! ;

: WaitForPacketAcknowledge
	begin
		poll
		OutState c@
	0= until
;
: Actuate. word: mode word: motors
local GetNanoTicks const dword: Tstart

  _nomove if
	
	13 1 do
	  i Motor .TargetPosition @ dup
	  i Motor 2+ @
	  - or if
		i Motor 2+ _!
		i 1- 2^ HasStepped w@ or HasStepped _w! 
	  else
		drop
	  endif
	loop
	
  else
	_ROPU? if	( must rezero the plateloader )
	  0 [pfa] _ROPU? ! 
	  RezeroPLOnFly
	endif

	0 PulseOut _w! 
	0 HasStepped _w! 
	mode 8 or Actuate

	begin
	  get_status STEPPING and
	while
	  poll
	  actdiag @ 0= if
	  	0 [pfa] _TxyValid ! 
	  	HasStepped w@ if
	  	  PulseOut w@ 1 and if
	  	    0 UpdateMotors
	  	  endif
	  	endif
	  else
		0 3 at sdump
	  endif
	repeat
	TimingOn @ if GetNanoTicks Tstart - ActuateTime +! endif
	
  endif
  0 UpdateMotors
  TimingOn @ if
	WaitForPacketAcknowledge
	GetNanoTicks Tstart - ActuateAndFeedbackTime +!
  endif
;
: StartTiming 1 TimingOn ! GetNanoTicks StartTime ! ;
: ClearTiming 0 ActuateTime ! 0 ActuateAndFeedbackTime ! 0 TotalTime ! ;
: StopTiming
	0 TimingOn !
	GetNanoTicks StartTime @ - TotalTime +!
;
: ReportTiming
	." Actuate time = " ActuateTime @ ltof 1193181.75 f/ f. ."  secs.  "
	." Actuate(feedback) time = " ActuateAndFeedbackTime @ ltof 1193181.75 f/ f. ."  secs.  "
	." Total time = " TotalTime @ ltof 1193181.75 f/ f. ."  secs" cr
;
: SyringePosition.	msSYRS Position. ;
: SyringeActuate. msAXES msSYRS or Actuate. ;
: AxisPosition.		msAXES Position. ;
: AxisActuate.    msAXES Actuate. ;
: s>mm dword: steps word: mno steps ltof mno GetPitch f/ ;
: mm>s GetPitch f* ftol ;
: pitch<0? ( mno - flag ) GetPitch f0< ;


: MoveToStop word: ChannelGroup word: MotorBits
local

	ChannelGroup msAXES = 
	if
		nAxes 0.633
	else
		nSyrs 1.000
	endif
	const float: RelSpeed
	const dword: MCount

	ClearSteps
	
	PositionsValid? if
		MCount 0 do
		  MotorBits i bit? if
		    i ChannelGroup GetMno
		    dup 1.0 SetSpeedFactor 0.0 MoveTo
		  endif
		loop
		14 ChannelGroup msAXES = if AxisActuate. else SyringeActuate. endif (* No STOP button *)
		." ShowSTOP" cr
	endif	
	
	MCount 0 do
	  MotorBits i bit? if
	    i ChannelGroup GetMno
	    dup RelSpeed SetSpeedFactor
	    dup GetRange -1.1 f* MoveBy
	  endif
	loop
	amAXIS ChannelGroup msAXES = if AxisActuate. else SyringeActuate. endif
;
: WindUp word: ChannelGroup word: MotorBits

	ChannelGroup msAXES =
	if
	  nAxes
	else
	  nSyrs
	endif
	
local	const dword: mcount

	ClearSteps
	mcount 0 do
	  MotorBits i bit? if
	    i ChannelGroup GetMno SetPhase0
	  endif
	loop

	( steps/cycle 8 * steps/sec 0 Actuate )

	mcount 0 do
	  MotorBits i bit? if
	    ( i ChannelGroup GetMno
	     steps/cycle 4 *  over pitch<0? not if negate then cwd StepBy )
	    	i ChannelGroup GetMno 32.0 i ChannelGroup GetMno GetPitch f/ MoveBy
	    	i ChannelGroup GetMno 0.05 SetSpeedFactor
	  endif
	loop

	amSYRINGE Actuate

	mcount 0 do
	  MotorBits i bit? if
	    i ChannelGroup GetMno 0 MotorPower
	  endif
	loop

;
: BackOff word: ChannelGroup word: MotorBits

local
	ChannelGroup msAXES = const word: XYZ?
	XYZ? if nAxes else nSyrs endif const dword: mcount

	mcount 0 do
	  MotorBits i bit? if
	    i ChannelGroup GetMno
	    XYZ? i 2 < and if
	    	i AxisOffset f@ else 0.0 endif
	    	SetPosition
	  endif
	loop

	mcount 0 do
	  MotorBits i bit? if
	    i ChannelGroup GetMno 1 MotorPower
	  endif
	loop

	ClearSteps
	mcount 0 do
	  MotorBits i bit? if
	    	i ChannelGroup GetMno 8.0 i ChannelGroup GetMno GetPitch f/ MoveBy
	    	i ChannelGroup GetMno 0.05 SetSpeedFactor
	  endif
	loop

	amSYRINGE Actuate

	mcount 0 do
	  MotorBits i bit? if
	    i ChannelGroup GetMno Reset
	  endif
	loop


;

: TestStop
	  getKey 0= Contact 1 and 0= and if
		"  : Testing stopped by user" count drop 5 ."abort ( " )
	  endif
;

" STEPPER.FTH Exit" stackCheck

