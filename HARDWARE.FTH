.( Compiling Hardware.fth Version 8.00) cr
string serialNumber "XYZV-WD"
string hardwareDate "23/04/2003"
string LastChangedDate "2010-09-10"
string userName "Westfield Oryx8 Lab DB7"

Oryx8  (* .( Hardware 6 ) .s cr ... *)
DB7.0

( Syringe drives, format : int:sno float:backlash [in mm]   USDx.x )
( USD1.0 = Leadscrew syringe drive w- 314.96 half steps/mm)
( USD2.0 = Ballscrew syringe drive, no limit switch w- 200.00 half steps/mm )
( USD2.1 = Ballscrew syringe drive, with limit switch w- 200.00 half steps/mm )

1 0.0250 USD1.0
2 0.0254 USD2.1
3 0.0191 USD2.1
4 0.0159 USD2.1
5 0.0064 USD2.1
6 0.0095 USD2.1
7 0.0349 USD2.1
8 0.0095 USD2.1 ForLargeVolume
8 0.0000 LCP2.1 ForLCP

-13.3297 20.0031 39.4584 39.4833	XYZV5.1

: KillPositions " POSITION.DAT" fdelete drop ;
: random
	GetNanoTicks drop $FF drop and ?dup if
		wtof 255.0 f/ ( random 0 to 1.0 )
		flog 5.0 f* fexp
		GetNanoTicks drop 1 and if fnegate endif
		GetNanoTicks drop $1f drop and if 100.0 f/ endif
	else
		0.0
	endif
;
: # random 1000.0 f* f. ;
: RezeroLS word: Axis
local
	Axis Axis>Channel Motor .Pitch f@ 65536.0 f* const float: mm/cycle
	( random 16.0 f* ) 
	0.0 const float: diff

	diff mm/cycle f/ fabs ftol const word: delta
	Axis Axis>Channel 0.0 SetPosition
	Axis Axis>Channel 1 MotorPower
	1 UpdateMotors Axes.Fast
	( return error and missed cycle count ) diff delta

	KillPositions 
;

: RezeroX X RezeroLS 0.019 0 ;
: RezeroY Y RezeroLS 0.725 1 ;
: RezeroZ Z RezeroLS -0.003 0 ;
: RezeroV V RezeroLS -0.115 2 ;

101.5 151.0 SetShieldHook
15 [pfa] OptoAxes _w! 
