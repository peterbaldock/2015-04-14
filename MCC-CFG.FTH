.( Compiling  MCC-Cfg.fth Version 8.00 ) cr
" MCC-CFG.FTH Entry" stackCheck
vocabulary stepper stepper definitions

16	DWORD	array	MotorRecord

string n/a "[Data not available]"
: userName n/a ;
: hardwareDate n/a ;

	BYTE	table	AxisName
	{ ascii X ascii Y ascii Z ascii V c} SetTableCount AxisName
			
	BYTE	table 	Axis>Channel { 9 10 11 12 c} SetTableCount Axis>Channel
	BYTE	table 	Syringe>Channel { 0 0 0 0 0 0 0 0 c} SetTableCount Syringe>Channel
4	FLOAT	array	AxisOffset
4	FLOAT	array	NominalOptoPosition

" MCC-CFG.FTH arrays" stackCheck

virtual	OptoAxes
virtual	OptoDrives
virtual	BeltDrive?
virtual	XYZ.Variant

0	constant	OptoAxes
0	constant	OptoDrives
1	constant	BeltDrive?
0	constant	XYZ.Variant

FALSE	constant	ShieldHook?
0.0	fconstant	ShieldHook.X
0.0	fconstant	ShieldHook.Y


0	constant	systemName
8	constant	steps/cycle
4	constant	nAxes
6	constant	nSyrs
0	constant	AxisMask
0	constant	SyringeMask

virtual LCP_Dispensing
0	constant	Configuration	( 0=Nano, 1=LV, 2=LCP )
1	constant	cfLV
2	constant	cfLCP

: xAxis	X Axis>Channel ;
: yAxis	Y Axis>Channel ;
: zAxis	Z Axis>Channel ;
: vAxis	V Axis>Channel ;

: SetShieldHook float: X float: Y
	X [pfa] ShieldHook.X _!
	Y [pfa] ShieldHook.Y _! 
	X f0= Y f0= and not [pfa] ShieldHook? _! 
;

: SetAxesAndSyrs dword: aCount dword: sCount
	aCount [pfa] nAxes ! 
	sCount [pfa] nSyrs !
	( 16 0 do 0 i MotorProperty c! loop )
	0.0 0.0 SetShieldHook
;

: OryxNano
	3 4 SetAxesAndSyrs
	3 0 do i 9 + i @tea Axis>Channel c! loop
	0 3 @tea Axis>Channel c!
	4 0 do i 1+ i @tea Syringe>Channel c! loop
	$700 [pfa] AxisMask ! 
	$00F [pfa] SyringeMask ! 
	7 [pfa] OptoAxes ! 			(* because OptoAxes is virtual *)
	101.1 152.4 SetShieldHook
	" OryxNano" [pfa] systemName ! 
;
: OryxNanoV 
	OryxNano
	12 2 @tea Axis>Channel c! 
	$B00 [pfa] AxisMask ! 
;
: Oryx
	4 6 SetAxesAndSyrs
	4 0 do i 9 + i @tea Axis>Channel c! loop
	6 0 do i 1+ i @tea Syringe>Channel c! loop
	$F00 [pfa] AxisMask ! 
	$03F [pfa] SyringeMask ! 
	" Oryx" [pfa] systemName ! 
;
: Oryx4
	4 4 SetAxesAndSyrs
	4 0 do i 9 + i @tea Axis>Channel c! loop
	4 0 do i 1+ i @tea Syringe>Channel c! loop
	$F00 [pfa] AxisMask ! 
	$00F [pfa] SyringeMask ! 
	" Oryx4" [pfa] systemName ! 
;
: Oryx6
	4 6 SetAxesAndSyrs
	4 0 do i 9 + i @tea Axis>Channel c! loop
	4 0 do i 1+ i @tea Syringe>Channel c! loop
	6 4 do i 3 + i @tea Syringe>Channel c! loop
	$F00 [pfa] AxisMask ! 
	$0CF [pfa] SyringeMask ! 
	" Oryx6" [pfa] systemName ! 
;
: Oryx8
	4 8 SetAxesAndSyrs
	4 0 do i 9 + i @tea Axis>Channel c! loop
	8 0 do i 1+ i @tea Syringe>Channel c! loop
	$F00 [pfa] AxisMask ! 
	$0FF [pfa] SyringeMask ! 
	" Oryx8" [pfa] systemName ! 
;
: OryxOnIMPAX
	4 6 SetAxesAndSyrs
	4 0 do i 5 + i @tea Axis>Channel c! loop
	3 0 do i 1+ i @tea Syringe>Channel c! loop
	3 4 @tea Syringe>Channel c!
	3 5 @tea Syringe>Channel c!
	4 6 @tea Syringe>Channel c!
	$0F0 [pfa] AxisMask ! 
	$0F [pfa] SyringeMask ! 
	" Oryx" [pfa] systemName ! 
;

: Signature
	."      " $18 0 do i byte. space loop cr
	$300 hex. $1C 4 do i Board c@ byte. space loop cr
	$320 hex. $3C $24 do i Board c@ byte. space loop cr
;
: System.
local 3 Board c@ const word: V
local 0 Board c@ const word: Type


	Type 50 = if
	  ." DB5 " V 12 - if ." Error: " endif
	else
	  Type 60 = if
	    ." DB6 "
	  else
	    ."  : Driver cards not found." cr exit
	  endif
	endif
	V . ." Volt "
	2 Board c@ Type = if ." Oryx" else ." IMPAX" endif
	."  System"
	CardType w@ ?dup if
	  ." , CardType=DB" 10 /mod $30 + emit $2E emit .
	else
	  ." , Invalid CardType."
	endif
	cr
;
: info System. ;

: DB5
	0 Board c@ 50 = if
	  3 Board c@ 12 = if
	    50 CardType w! $300 BaseAddr w! 8 [pfa] steps/cycle ! 
	  else
	    ." Hardware incompatible with " System. 12 abort
	  endif
	else
	  ." DB5 System specified without DB5 driver cards." cr
	  Signature cr 12 abort
	endif
;
TRUE variable VoltageChecking
: DB6! word: Type


	0 Board c@ 60 = if
	  $320 BaseAddr w! 
	  3 Board c@ 12 = if	( 12V system requires 1/2 stepping )
	    Type 64 >= VoltageChecking @ and if
	      $69 dup 0 WriteLED 2 WriteLED
	      "  (5V system not detected for microstepping)" 1+ 12 ."abort ."abort
	    endif
	  else
	    Type 64 < if
	      System. ." Hardware requires CardType DB6.4 or higher." cr 12 abort
	    endif
	  endif
	else
	  $5A 0 WriteLED
	  ." DB6 System specified without DB6 driver cards." cr
	  Signature cr 12 abort
	endif
	Type CardType w! 
	$88 $321 out $88 $329 out $88 $331 out
;

: DB6.0 60 DB6! 8 [pfa] steps/cycle ! ;
: DB6.4 64 DB6! 8 [pfa] steps/cycle ! ;
: DB6.6 66 DB6! 8 [pfa] steps/cycle ! ;
: DB6.8 68 DB6! 8 [pfa] steps/cycle ! ;
: DB6 DB6.0 ;
: DB6.4(12V) FALSE VoltageChecking ! DB6.4 ;
: DB6.6(12V) FALSE VoltageChecking ! DB6.6 ;
: DB6.8(12V) FALSE VoltageChecking ! DB6.8 ;

: DB7> CardAddress w@ dup inw swap 4+ inw and ;
: _DB7.0 $440 swap $10 + >DB7 1 ms ;
: DB7.0

	2 Board c@ 70 = if
		$318 BaseAddr _w! 
	else
	  $5A 0 WriteLED
	  ." DB7 System specified without DC7/DB7 driver cards." cr
	  Signature cr 12 abort
	endif
	70 CardType _w! 
	256 [pfa] steps/cycle ! 
	$318 CardAddress _w! 
	0 _DB7.0 1 _DB7.0 2 _DB7.0
;

( Oryx8 DB7.0 )

" MCC-CFG.FTH Exit" stackCheck
