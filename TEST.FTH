.( Compiling     TEST.FTH Version 5.29  ) cr
" TEST.FTH Entry" stackCheck
vocabulary test
test definitions
: _tbl word: bno

	8 0 do
		." test LED at " bno 1 r. ascii . emit i byte. cr
		i 2^ bno WriteLED 300 ms
		i 2^ not bno WriteLED 300 ms
	loop
	9 1 do
		$FF i 2^ 1- - bno WriteLED 300 ms
	loop

	$0F bno WriteLED 500 ms
	$F0 bno WriteLED 500 ms
	$55 bno WriteLED 500 ms
	$AA bno WriteLED 500 ms
	$33 bno WriteLED 500 ms
	$CC bno WriteLED 500 ms
	$96 bno WriteLED 500 ms
	$69 bno WriteLED 1000 ms
	
	256 4 0 do
		i bno WriteLED
	loop
	0 bno WriteLED
;
: lights
	PushLEDs
	3 0 do i _tbl loop
	PopLEDs
;

50.0 variable _speed
: speed >float _speed f! ;
: _setspeed _speed f@ SetCurrentSpeed ;

X	constant _jogaxis
xAxis	constant _jogmno
xAxis	constant _mno
0	constant _mname
1	constant LSChannel
: _showpos

	0 7 at _mname emit space
	_jogmno GetLPosition LSChannel GetMotorLSInputs
	" Position = %fmm LS=%d%<" format count type
;

: _setAxis word: Axis
	Axis [pfa] _jogaxis !
	Axis Axis>Channel [pfa] _mno !
	_mno [pfa] _jogmno !
	Axis AxisName [pfa] _mname !
;
: x X _setAxis ;
: y Y _setAxis ;
: z Z _setAxis ;
: v V _setAxis ;
: a 38 AxisActuate. ;
: > >float _mno swap MoveLTo _mno _setspeed ;
: +> >float _mno swap MoveLBy _mno _setspeed ;
: >> > a ;
: _>> word: Axis float: d
	Axis AxisName [pfa] _mname !
	Axis Axis>Channel dup [pfa] _jogmno !
	d MoveLBy 38 Actuate
;

: _jog
local word: mno
  begin
	waitKey ( dup 0 7 at hex. )
		dup $ff and select
		$E0 0 2 cases: ( Cursor key, ctrl-+/- )
			8 shr select

				$9D case: X 0.01 _>> endcase
				$4D case: X 0.05 _>> endcase
				$74 case: X 0.5 _>> endcase
				$9B case: X -0.01 _>> endcase
				$4B case: X -0.05 _>> endcase
				$73 case: X -0.5 _>> endcase
	
				$A0 case: Y 0.01 _>> endcase
				$50 case: Y 0.05 _>> endcase
				$91 case: Y 0.5 _>> endcase
				$98 case: Y -0.01 _>> endcase
				$48 case: Y -0.05 _>> endcase
				$8D case: Y -0.5 _>> endcase

				$99 case: Z 0.01 _>> endcase
				$49 case: Z 0.05 _>> endcase
				$84 case: Z 0.5 _>> endcase
				$A1 case: Z -0.01 _>> endcase
				$51 case: Z -0.05 _>> endcase
				$76 case: Z -0.5 _>> endcase

				$4E case: _jogaxis 0.01 _>> endcase
				$4A case: _jogaxis -0.01 _>> endcase
				$90 case: _jogaxis 0.5 _>> endcase
				$8E case: _jogaxis -0.5 _>> endcase

			endselect
			endcase
		TRUE ?case:
			$FF and select						
				ascii + case: _jogaxis 0.025 _>> endcase
				ascii - case: _jogaxis -0.025 _>> endcase
				ascii x case: x endcase
				ascii y case: y endcase 
				ascii z case: z endcase
				ascii v case: v endcase
				$1B case: "  : Cancelled" count drop 5 ."abort ( " )  endcase
				$0D case: exit endcase
			endselect
		endcase
	endselect

	_showpos
		
  FALSE until
;

: rall RezeroZ RezeroV RezeroY RezeroX rsdump ;
: fi FindIndexPositions ;


1.0 fconstant PinRadius
3.0 fconstant Zread

systemName " OryxNano" $= #if

	.( Loading XYZNano calibrator ) cr
	
	72.5 fconstant Yx
	30.0 fconstant Xy
	51.0 fconstant CalZx
	76.0 fconstant CalVx
	130.0 fconstant CalZy

	FLOAT table XCentre { 5.5 20.5 35.5 50.5 72.5  95.5 110.5 125.5  } 2/ constant Nx
	Nx SetTableCount XCentre

	FLOAT table YCentre { 7.0 30.0 52.0 67.0 82.0 97.0 112.0 127.0  } 2/ constant Ny
	Ny SetTableCount YCentre

	FLOAT table ZCentre { 5.0 10.0 15.0 20.0 25.0 30.0 35.0 40.0 45.0 50.0 } 2/ constant Nz
	Nz SetTableCount ZCentre

	FLOAT table VCentre { 0.0 5.0 10.0 15.0 20.0 25.0 30.0 35.0 40.0 } 2/ constant Nv
	Nv SetTableCount VCentre
	
	0.0 fconstant Vmax
	
#else

	.( Loading XYZV calibrator ) cr
	
	155.5 fconstant Yx
	22.0 fconstant Xy
	94.0 fconstant CalZx
	76.0 fconstant CalVx
	150.0 fconstant CalZy

	FLOAT table XCentre { 5.5 20.5 35.5 50.5 65.5 80.5 95.5 110.5 125.5 140.5 155.5 
	170.5 185.5 200.5 215.5 230.5 245.5 260.5 275.5 290.5 305.5 } 2/ constant Nx
	Nx SetTableCount XCentre

	FLOAT table YCentre { 7.0 22.0 52.0 67.0 82.0 97.0 112.0 127.0 142.0 } 2/ constant Ny
	Ny SetTableCount YCentre

	FLOAT table ZCentre { 5.0 10.0 15.0 20.0 25.0 30.0 35.0 40.0 45.0 50.0 } 2/ constant Nz
	Nz SetTableCount ZCentre

	FLOAT table VCentre { 0.0 5.0 10.0 15.0 20.0 25.0 30.0 35.0 40.0 } 2/ constant Nv
	Nv SetTableCount VCentre
	
	vAxis GetLength fconstant Vmax

#endif

zAxis GetLength fconstant Zmax
5.0 fconstant _SlowSpeed

0.0 fvariable CurrentError
2.50 fconstant SearchRange

: setslow [pfa] _SlowSpeed f! ;

: LSBit? LSChannel GetMotorLSInputs 0 bit? ;
	
: MoveToLS word: Sense
local 0 word: LSIn

	amAXIS amNO_ACC or Actuate
	begin
		get_status STEPPING and	0=	( don't hang )
		LSBit? dup LSIn w!
		Sense = 
		or
	until
	Stop
	ClearSteps
	
	LSIn @
;

: CreepToEdge word: Leading

 	Leading MoveToLS
 	Leading - if
		." Did not find edge. Calibration will abort." waitKey
		15 Home 10 abort
	endif
;

0 variable fh

4 FLOAT array SumX
4 FLOAT array SumXS
4 FLOAT array SumS
4 FLOAT array SumS2

4 FLOAT array CalA
4 FLOAT array CalB

: FindPinEdge word: Index word: Mno word: Leaving word: Backwards

local	Index 
	Mno	select
		xAxis case: XCentre endcase
		yAxis case: YCentre endcase
		zAxis case: ZCentre endcase
		vAxis case: VCentre endcase
	endselect const float: Centre
	
	Centre PinRadius
		Backwards Leaving xor if fnegate endif f- const float: Target
	
	SearchRange Backwards if fnegate endif const float: Margin
	Target Margin f- CurrentError f@ f+ const float: SlowTarget
	0 Leaving if 1+ endif Backwards if 2+ endif const word: SI

(	Centre Target Margin SlowTarget " Centre=%f  Target=%f Margin=%f SlowTarget=%f%<" format count type	waitKey drop )
	Mno 30.0 SetCurrentSpeed
(	Index 1+ Centre " Moving to pin %d at %f ...%<" format count type )
	Mno SlowTarget MoveLTo 38 Actuate

	Mno _SlowSpeed SetCurrentSpeed
	Mno Margin 2.0 f* MoveLBy
	Leaving 0= CreepToEdge
	Mno GetLPosition const float: PNow
	Mno GetPitch PNow f* const float: S
	PNow Target f- CurrentError f!
	
	Target  SI SumX f+!
	Target S f* SI SumXS f+!
	S SI SumS f+!
	S S f* SI SumS2 f+!
	
	Index Target PNow S " Pin %d%> Target = %f%> PNow=%f%> Microsteps=%12f%<" format
	fh w@ over fputs if 50 abort endif
	count type
	
	1.0 [pfa] SearchRange f!
	( jog )
	 
;

: PitchCalc word: N word: SI
local N wtof const float: N.

	N. SI SumXS f@ f* SI SumS f@ SI SumX f@ f* f-
	N. SI SumS2 f@ f* SI SumS f@ fdup f* f-
	f/ ( TOS = a ) const float: a
	SI SumX f@ a SI SumS f@ f* f- N. f/ const float: b

	a b
;
	
: FindAllEdges word: Axis
local Axis Axis>Channel const word: mno

	mno	select
		xAxis case: Nx endcase
		yAxis case: Ny endcase
		zAxis case: Nz endcase
		vAxis case: Nv endcase
	endselect const word: N
	
	0.0 float: a
	0.0 float: b
	4.0 [pfa] SearchRange f!
	ds> >es
	0 " _Cal.dat" Axis AxisName over 1+ c! fcreate dup fh w! 0= if " Can't create calibration file. " 1+ 10 ."abort ( " ) endif
	
	4 0 do
		0.0 i SumX f!
		0.0 i SumXS f!
		0.0 i SumS f!
		0.0 i SumS2 f!
	loop
	
	mno 2.0 MoveLBy amAXIS Actuate
	Axis 2 < if
		Zread Vmax ZVGoto
	endif
		

	0.0 CurrentError f!
	-1 N 1- do
		i mno FALSE TRUE FindPinEdge
		i mno TRUE TRUE FindPinEdge
	-1 +loop
	
	mno -2.0 MoveLBy amAXIS Actuate
	N 0 do
		i mno FALSE FALSE FindPinEdge
		i mno TRUE FALSE FindPinEdge
	loop

	( calculate pitch and offset )
	
	4 0 do
		N i PitchCalc ( leave coefficients a and b on stack )
		b f+!
		a f+!
	loop
	
	a f@ 4.0 f/ fdup a f! Axis CalA f!
	b f@ 4.0 f/ fdup b f! Axis CalB f!
	
	( invert pitch to get steps/mm )
	
	1.0 a f@ f/ ( steps/cycle wtof f/ 8.0 f* ) const float: Pitch

	Pitch b f@ " %<Pitch : %f%> Offset : %f%<" format dup count type
	fh w@ swap fputs
	mno Pitch SetPitch
	
	fh w@ fclose
	15 Home
;
: Fast
	xAxis 1.0 SetSpeedFactor
	yAxis 1.0 SetSpeedFactor
	zAxis 1.0 SetSpeedFactor
	vAxis ?dup if 1.0 SetSpeedFactor endif
;
: jog
	cls
	." Use cursor keys and PgUp/PgDown to move plateloader. " cr
	." Hold Ctrl for big jumps, and Alt for minute jumps." cr
	." Press <Enter> to quit : "
	_jog
;

: JogToPin
	cls
	." Use <+> and <-> keys to centre the opto over the pin." cr cr
	." Press <Enter> when ready, or <ESC> to Cancel : "
	_jog
;

: CalX
	( move to starting position for X line )
	Fast
	Zmax Vmax ZVGoto
	Nx 1-  XCentre Xy XYGoto
	Zread 7.0 f+ Vmax ZVGoto
	y JogToPin
	X FindAllEdges
;
: CalY

	( move to starting position for Y line )
	Fast
	Zmax Vmax ZVGoto
	Yx Ny 1-  YCentre XYGoto
	Zread 7.0 f+ Vmax ZVGoto
	x JogToPin
	Y FindAllEdges
;
: CalZ
	( move to starting position for Z calibration tree )
	Fast
	Nz 1- ZCentre Vmax ZVGoto
	CalZx CalZy 7.0 f- XYGoto
	x JogToPin
	yAxis 7.0 MoveLBy 38 Actuate
	Z FindAllEdges
;

: CalV
	( move to starting position for Z calibration tree )
	Fast
	Zmax Nv 1- VCentre ZVGoto
	CalVx CalZy 7.0 f- XYGoto
	x JogToPin
	yAxis 7.0 MoveLBy 38 Actuate
	V FindAllEdges
;

200.0 fconstant SyringePitch
85.6 fconstant SyringeTravel
TRUE constant BallScrew?

: BallScrew
	TRUE [pfa] BallScrew? !
	200.0 [pfa] SyringePitch f!
	85.6 [pfa] SyringeTravel f!
;
: LeadScrew
	FALSE [pfa] BallScrew? !
	314.96 [pfa] SyringePitch f!
	92.0 [pfa] SyringeTravel f!
;

: _s>> word: mno float: d
	9 [pfa] LSChannel !
	mno 200.0 SetPitch
	ClearSteps
	begin
	  LSChannel GetMotorLSInputs dup .
	d 0.0 f< if 0= endif
	while
	  mno d MoveBy 36 Actuate
	repeat
	mno GetPosition ." Position = " f. cr
;
: ?Position GetPosition ." Position = " f. cr
;
: s- dup -0.005 _s>> ?Position ;
: s-- dup -1.0 _s>> ?Position ;
: s+ dup 0.005 _s>> ?Position ;
: s++ dup 1.0 _s>> ?Position ;


: _b word: sno word: n

	9 [pfa] LSChannel !
	sno 1.0 SetSpeedFactor sno -90.0 MoveBy TRUE MoveToLS 0= if "  : Move failed" 1+ 5 ."abort ( " ) endif
	sno 0.1 SetSpeedFactor sno 1.0 MoveBy FALSE MoveToLS if quit endif
	
	n 0 do
		sno -1.0 MoveBy TRUE MoveToLS if
			sno GetPosition
			sno 1.0 MoveBy FALSE MoveToLS 0= if
				sno GetPosition f- fdup ." Backlash = " f. cr
			else
				quit
			endif
		else
			quit
		endif
	loop

	n fmean
;

BallScrew

: b word: sno

	BallScrew? if
		." Measuring OptoSwitch hysteresis... no syringe should be attached." cr
		." Stretch a rubber band between carriage and nose. Press <SPACE> when ready : " waitKey $FF and $20 - if quit endif cr

		local sno 10 _b const float: Unloaded

		." Now attach the test syringe to the USD. Press <SPACE> when ready : " waitKey $FF and $20 - if quit endif cr

		sno 10 _b const float: Loaded
		cr cr
		." The measured hysteresis with rubber band = " Unloaded f. ." mm" cr
		." The measured backlash with the test syringe = " Loaded f. ." mm" cr
		." The backlash increase with the test syringe = " Loaded Unloaded f- f. ." mm" cr
	else
		." Backlash.fth module must be loaded" cr 
	endif
;
(
fload run-in.fth
test definitions
: free? cr $F000 here - . ." dictionary bytes free." cr ;

free?
)
