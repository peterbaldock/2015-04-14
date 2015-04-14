.( Compiling    Moves.fth Version 8.00 ) cr
" MOVES.FTH Entry" stackCheck

12 variable oilAxis
8 variable oilSyr
zAxis constant SweepMno
0.0 fvariable dSweep
pi 2.0 f/ fconstant pi/2

: SetSweep dSweep f! ;
: SweepV vAxis [pfa] SweepMno ! ;

: SyringeMove ( sno, diff., ... , n, actuateMode - )

	PositionsValid? 0= if
		"  : Syringe positions invalid" 1+ 21 ."abort ( " )
	endif

	ClearSteps
	SweepMno dSweep f@ MoveLBy 0.0 dSweep f! zAxis [pfa] SweepMno ! 
	>r
	0 do swap Syringe>Channel swap MoveLBy loop
	r> SyringeActuate. eCheck
;

: TrySpeed word: Axis float: Position float: Speed word: n
local	Axis Axis>Channel const word: mno

	." Trying speed " Speed f. cr
	Axis NominalOptoPosition f@ const float: optoPos
	mno Motor .Pitch f@ 65536.0 f* const float: dCycle
	0 word: error
	0 word: count		

	begin
		TestStop
		count ++

		mno 
		count @ n + wtof n 2* wtof f/ Speed f* SetSpeedFactor ( half speed move to Position )

		mno Position MoveTo amAXIS AxisActuate.

		mno Speed SetSpeedFactor mno GetCurrentSpeed f. ." mm/s back to opto" cr

		mno optoPos MoveTo amAXIS AxisActuate.

		TestStop

		Axis GotoOpto
		mno GetPosition optoPos f- dCycle f/
		mno optoPos SetPosition
		fabs 0.49 f> error !
		error @ ." Error = " . cr
		( waitKey drop )

	count @ n = 
	error @
	or until

	error @
	dup if ." Failed " cr endif
	
;
: ScanForTopSpeed word: Axis float: Length var float: SpeedMin var float: SpeedMax
local
	Axis Axis>Channel const word: mno
	SpeedMin f@ float: speedNow

	Axis GotoOpto
	mno Axis AxisOffset f@
	fdup or 0= if fdrop Axis NominalOptoPosition f@ endif
	( ." Setting position at opto to " fdup f. cr )
	SetPosition
	( waitKey drop )

	begin
		TestStop

		Axis Length speedNow f@ 2 TrySpeed
		if ( error )
			speedNow f@ 0.97 f* SpeedMax f!
			speedNow f@ 0.8 f* SpeedMin f@ fmin SpeedMin f!
		else
			speedNow f@ ( SpeedMin f@ 2 fmean ) SpeedMin f!
		endif
		SpeedMin f@ fdup SpeedMax f@ 3 fmean speedNow f!
		SpeedMax f@ SpeedMin f@ f-
		0.05 f< 
	until
	
	speedNow f@
;		
4 FLOAT array _AxesSF
: _AxisSFDump word: Axis
	Axis AxisName emit
	Axis _AxesSF f@ Axis Axis>Channel GetMaxSpeed f*
	Axis _AxesSF f@
	" -Axis Maximum Speed : %6.0fmm/s (Speed Factor = %4.2f)%<" format count type
;
: sfdump
	nAxes 0 do
		OptoAxes i bit? if
		  i _AxisSFDump
		endif
	loop
;
: FindVmax word: Axis
local	
	Axis Axis>Channel const word: mno
	mno GetLength const float: lenMax
	
	Axis RezeroLS
	1.0 const float: speedMin
	2.2 const float: speedMax

	Axis lenMax 3.0 f- speedMin speedMax ScanForTopSpeed
	Axis _AxesSF f! Axis _AxisSFDump
;

: TryXYSpeed float: PositionX float: SpeedX float: PositionY float: SpeedY word: n
local	
	X NominalOptoPosition f@ const float: optoPosX
	Y NominalOptoPosition f@ const float: optoPosY
	xAxis Motor .Pitch f@ 65536.0 f* const float: dCycleX
	yAxis Motor .Pitch f@ 65536.0 f* const float: dCycleY
	
	0 word: error
	0 word: count		
	0 20 at
	." Trying X distance and speed " PositionX f. space SpeedX f. cr
	." Trying Y distance and speed " PositionY f. space SpeedY f. cr
	
	begin
		TestStop
		count ++

		xAxis count @ n + wtof n 2* wtof f/ SpeedX f* SetSpeedFactor ( half speed move to Position )
		yAxis count @ n + wtof n 2* wtof f/ SpeedY f* SetSpeedFactor ( half speed move to Position )

		xAxis PositionX MoveTo 
		yAxis PositionY MoveTo
		." Move to " PositionX f. PositionY f. cr ( ... )
		amAXIS AxisActuate.

		xAxis SpeedX SetSpeedFactor xAxis GetCurrentSpeed f. ." mm/s on X axis, "
		yAxis SpeedY SetSpeedFactor yAxis GetCurrentSpeed f. ." mm/s on Y axis back to opto" cr

		xAxis optoPosX MoveTo 
		yAxis optoPosY MoveTo 
		( ... )
		amAXIS AxisActuate.

		TestStop

		Y GotoOpto
		yAxis GetPosition optoPosY f- dCycleY f/
		yAxis optoPosY SetPosition
		fabs 0.49 f> if 2 error @ or error ! endif
		
		X GotoOpto
		xAxis GetPosition optoPosX f- dCycleX f/
		xAxis optoPosX SetPosition
		fabs 0.49 f> if 1 error @ or error ! endif
		
		error @ ." Error = " . cr
		( waitKey drop )

		count @ n = 
		error @
	or until

	error @
	dup if ." Failed " cr endif
	
;
: on 12 0 do i 1+ 1 MotorPower loop ;
(*
: >> float: x on
	( 1 actdiag ! )
	xAxis 0.0 SetPosition
	yAxis 0.0 SetPosition
	xAxis x MoveTo 
	xAxis 2.0 Setspeedfactor
	yAxis 2.0 MoveTo 
	yAxis 2.0 Setspeedfactor
	( 0 StepMask w! 0 status w! ) amAXIS AxisActuate.
;

: dosteps word: n
	cls
	0 3 at _vdheader
	n 0 do OneStep 0 4 at 9 _vd 10 _vd loop
;
100.0 fvariable xl
: ? cls SteppingStatus 16 + 1 dump ;
*)

: TestXY word: nAngles
local
	1.0 float: speedMinX
	2.2 float: speedMaxX
	1.0 float: speedNowX
	1.0 float: LengthX
	xAxis GetLength 3.0 f- const float: rX
	
	1.0 float: speedMinY
	2.2 float: speedMaxY
	1.0 float: speedNowY
	1.0 float: LengthY
	yAxis GetLength 3.0 f- const float: rY
	
	pi/2 nAngles ltof f/ const float: dTheta
	pi/2 dTheta f- float: Theta
	
	RezeroY RezeroX
	
	( 1 actdiag ! cls )
	begin
		
		rX Theta f@ fsin f* LengthX f!
		rY Theta f@ fcos f* LengthY f!

		1.0 speedMinX f!
		1.0 speedMinY f!
		
		begin

			TestStop
			( cr ." before try " cr .s waitKey drop cr )

			LengthX f@ speedNowX f@ LengthY f@ speedNowY f@ 2 TryXYSpeed
			( cr ." after try " cr .s cr )
			?dup if ( dup ." Error = " . cr )
				dup 1 and if
					speedNowX f@ 0.97 f* speedMaxX f!
					speedNowX f@ 0.8 f* speedMinX f@ fmin speedMinX f!
				endif
				2 and if
					speedNowY f@ 0.97 f* speedMaxY f!
					speedNowY f@ 0.8 f* speedMinY f@ fmin speedMinY f!
				endif
			else
			( cr ." after else " cr .s waitKey drop cr )
				speedNowX f@ ( speedMinX f@ 2 fmean ) speedMinX f!
				speedNowY f@ ( speedMinY f@ 2 fmean ) speedMinY f!
			endif
			( cr ." after error adjustment " cr .s waitKey drop cr )

			speedMinX f@ fdup speedMaxX f@ 3 fmean speedNowX f!
			speedMinY f@ fdup speedMaxY f@ 3 fmean speedNowY f!

			speedMaxX f@ speedMinX f@ f- 0.05 f< 
			speedMaxY f@ speedMinY f@ f- 0.05 f< 
			or
			( cr ." before until " cr .s waitKey drop cr )
		until
		
		dTheta fnegate Theta f+!
		Theta f@ -0.01 f< 
	until
	
	speedNowX f@ X _AxesSF f! X _AxisSFDump
	speedNowY f@ Y _AxesSF f! Y _AxisSFDump

;
(*
: txy 1 actdiag ! 2 testxy ;
: >x xl w! ;
*)
: TestAxes
 
	-1 3 do
		OptoAxes i drop bit? if
			i FindVmax
		endif
	-1 +loop
	
	OptoAxes 3 and 3 = if 9 TestXY endif

	cls sfdump
;

BYTE table StirTable { 1 1 -1 -2 -1 1 2 -1 -1 2 -1 -1 1 c} SetTableLength StirTable

" MOVES::StirTable" stackCheck
: doStir float: mm word: stirno
local mm 2.0 f/ const float: radius

	ClearSteps

	stirno 0 do
		." Stir " i 1+ . cr
		13 0 do
			i StirTable cbw
			i 1 and if
			  yAxis swap
			else
			  xAxis swap
			endif
			cwd ltof radius f* MoveBy 36 Actuate

			eCheck
		loop
		eCheck
	loop
;
" MOVES::doStir" stackCheck

: Stir		getuuf if 2swap 2drop 1 doStir endif ;
: nStirs doStir ;


: ZMoveBy float: z  zAxis z MoveBy amAXIS AxisActuate. ;
: XYMoveBy float: x float: y  xAxis x MoveBy yAxis y MoveBy amAXIS AxisActuate. ;


: Slit

ClearSteps 3 0 do i Axis>Channel 0.8 SetSpeedFactor loop

3.0 4.0 XYMoveBy

 4.5 ZMoveBy
	 0.0 -1.0 XYMoveBy
	-6.0 -6.0 XYMoveBy
	 0.0 -1.0 XYMoveBy
-4.5 ZMoveBy

 3.0 4.0 XYMoveBy
-3.0 4.0 XYMoveBy

 4.5 	ZMoveBy
	0.0 -1.0 XYMoveBy
	3.0 -3.0 XYMoveBy
-4.5 ZMoveBy

3.0 -4.0 XYMoveBy

 4.5 ZMoveBy
	 0.0 1.0 XYMoveBy
	-3.0 3.0 XYMoveBy
-4.5 ZMoveBy
;

: Streak

	ClearSteps 3 0 do i Axis>Channel 0.8 SetSpeedFactor loop

	0.75 0.0 XYMoveBy
	-1.5 0.0 XYMoveBy
	0.75 0.0 XYMoveBy

;
: OilDrop   float: zHeight float: Smm float: SSpeed

	oilSyr @ SSpeed SetCurrentSpeed
	oilAxis @ 1.0 SetSpeedFactor
	oilSyr @ Smm MoveBy		( S movement )
	V zHeight AxisTo	( V move down )
	37 SyringeActuate.
;

7 FLOAT array TrData
0 constant RINSEXOFF
1 constant RINSEYOFF
2 constant RESHEIGHT
3 constant SHELFCLEARANCE
4 constant DROPXOFF
5 constant DROPYOFF
6 constant DROPHEIGHT

0.00 constant _TDmm
0.03 variable dTipClear (* 0.03 mm = extra 0.05 ul to clear tip *)
7.00 constant _TVz
0.00 constant _ZCorrection
1 constant _TDDipCount
1 constant _TDRinseCount
FALSE constant _TDSuppressSolution

: SetTransferDischargeDistance [pfa] _TDmm f! ;
: SetTransferDischargeVolume 0.6 f* SetTransferDischargeDistance ;
: SetTransferVz [pfa] _TVz f! ;
: SetZCorrection [pfa] _ZCorrection f! ;
: SetTransferDropZ DROPHEIGHT TrData f! ;
: SetTransferData ( fp0 .. fp6 - ) 7 0 do 6 i - TrData f! loop ;
: SetTDDipCount [pfa] _TDDipCount ! ;
: SetTDRinseCount [pfa] _TDRinseCount ! ;
: SetTDSuppressSolution [pfa] _TDSuppressSolution ! ;
0.0 2.0 3.0 6.0 4.0 0.0 5.0 SetTransferData
: TrDump 7 0 do i . i TrData @ f. cr loop ;
: TransferDrop word: ProtSyr float: dProt word: SolSyr float: dSol float: dAir

local	dAir 0.25 f*	const float: dBack (* must be smaller than dAir for WASP volume tracking *)

	SolSyr Syringe>Channel	const word: SolChannel 	
	ProtSyr 0 >= if ProtSyr Syringe>Channel else 0 endif	const word: ProtChannel 
	SolChannel GetCurrentSpeed	const float: OriginalSolSpeed 
	zAxis GetCurrentSpeed		const float: OriginalZSpeed 

	_TDRinseCount _TDDipCount + 1+ ltof 2.0 f/ dup 
	RINSEXOFF TrData @ swap f/ const float: dX 
	RINSEYOFF TrData @ swap f/ const float: dY 
	
	RINSEXOFF TrData @ fnegate 
	RINSEYOFF TrData @ fnegate 
	SuppressFeedback AxisXYBy amAXIS AxisActuate.
	
	_TDRinseCount if 
		" TipZ In Show TipLowerG.bmp" PrefixMsg ! 
		Z RESHEIGHT TrData @ AxisTo
		" Show Dispense.bmp" PostfixMsg ! 
		amAXIS AxisActuate.				( Generates feedback #1 )
	
		_TDRinseCount 0 do
			SolChannel dSol dBack f+ MoveLBy
			SuppressFeedback amSYRINGE SyringeActuate.
			SolChannel dSol dBack f+ MoveBy
			amSYRINGE SyringeActuate.			( Generates feedback #2 )
	
			dX dY AxisXYBy amAXIS AxisActuate.	( Generates feedback #3 )
		loop

		" TipZ Out Show TipRaiseG.bmp" PrefixMsg ! 
		Z SHELFCLEARANCE TrData @ AxisTo
		amAXIS AxisActuate.				( Generates feedback #4 )

	endif

	_TDDipCount if
		SolChannel 2.0 SetCurrentSpeed
		_TDDipCount 0 do
		
			" TipZ Out Show TipRaiseG.bmp" PrefixMsg ! 
			SolChannel dAir _TDmm f+ MoveBy
			amSYRINGE SyringeActuate.	( Generates feedback #5 )
	
			" TipZ In Show TipLower.bmp" PrefixMsg ! 
			Z RESHEIGHT TrData @ AxisTo
			SuppressFeedback
			amAXIS AxisActuate.
	
			dX dY AxisXYBy amAXIS AxisActuate.	( Generates feedback #6 )

			" TipZ Out Show TipRaise.bmp" PrefixMsg ! 
			Z SHELFCLEARANCE TrData @ AxisTo
			SuppressFeedback
			amAXIS AxisActuate.
	
			SolChannel dAir 
			ProtSyr -1 > if
				_TDSuppressSolution 0= if dTipClear f@ f+ endif
			endif
			MoveLBy amSYRINGE SyringeActuate.	( Generates feedback #7 )
			
		loop
	endif

	" TipZ In Show TipLower.bmp" PrefixMsg ! 
	dX dY AxisXYBy Z RESHEIGHT TrData @ AxisTo
	amAXIS AxisActuate.	( Generates feedback #8 )

	SolChannel OriginalSolSpeed SetCurrentSpeed
	( 100 ms )
	_TDSuppressSolution 0= if

		" Show Withdraw.bmp" PrefixMsg ! 
		SolChannel dSol dBack f+ MoveLBy
		SuppressFeedback
		amSYRINGE SyringeActuate.

		SolChannel dBack MoveBy
		( " Show TransferDrop.bmp" PostfixMsg ! )
		amSYRINGE SyringeActuate.	( Generates feedback #9 )
	endif
		
	zAxis _TVz SetCurrentSpeed
	Z SHELFCLEARANCE TrData @ _ZCorrection f+ AxisTo
	amAXIS AxisActuate.	( Generates feedback #10 )
	zAxis OriginalZSpeed SetCurrentSpeed

	ProtSyr -1 > if
	
		" Show TransferDrop.bmp" PrefixMsg ! 
		SuppressFeedback
		amAXIS AxisActuate.	( Generates feedback #10 )
		zAxis OriginalZSpeed SetCurrentSpeed
		DROPXOFF TrData @ RINSEXOFF TrData @ f+ fnegate
		DROPYOFF TrData @ RINSEYOFF TrData @ f+ fnegate
		SuppressFeedback
		AxisXYBy amAXIS AxisActuate.

		Z DROPHEIGHT TrData @ _ZCorrection f+ AxisTo
		amAXIS AxisActuate.	( Generates feedback #11 )
	
		" Show Dispense.bmp" PrefixMsg ! 
		zAxis dSweep f@ MoveLBy 0.0 dSweep f!
		_TDSuppressSolution 0= if SolChannel dSol dTipClear f@ f+ MoveBy endif
		ProtChannel dProt MoveBy
		" Status Transfer complete." PostfixMsg ! 
		amSYRINGE SyringeActuate.	( Generates feedback #12 )
	else
		" Show TransferDrop.bmp" PrefixMsg ! 
		amAXIS AxisActuate.	( Generates feedback #10 )
		zAxis OriginalZSpeed SetCurrentSpeed

	endif

;
" TransferDrop" stackCheck

: P getu if GetStepPosition d. endif ;

: accelerationTime

	cr cr
	." Your hardware file needs updating for this version of the stepper motor driver. Acceleration must be specified individually" cr
	." for each motor." cr
	cr
	." Please contact Douglas instruments for a revised file." cr 25 abort
;
" MOVES.FTH Exit" stackCheck
