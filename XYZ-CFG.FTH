.( Compiling  XYZ-Cfg.fth Version 8.00 ) cr
" XYZ-CFG.FTH Entry" stackCheck

(*
	2014-12-11	Ported to 32-bit
	2014-11-28	XYZ-CFG: HookMargin changed from 1.4 to 0.7. +HookXOffset for persistence in MCC (ADJUST.DAT).
	2013-05-14	Vertical axes backlash set to 0.000. Vertical motor Roundoff set to 1 instead of 0.
	2012-08-16	Addition of V1.2 for ICR upgrade
	2012-05-14	Addition of Bearing.X, Bearing.Y and HookMargin variables
	2012-01-19	All MCC7 XYZV accelerations reduced to X=700, Y=700
	2011-12-01	All MCC7 XYZV accelerations reduced to X=1500, Y=1200, Z/V=700mm/s/s
	2011-11-29	All start speeds reduced to 10.0mm/s and MCC6 accelerations to 500mm/s/s
	2011-10-11	XY acceleration increased from 350 to 700 mm/s for MCC6 systems.
	
*)

" XYZ-CFG.FTH Entry" stackCheck

virtual RezeroLS
virtual RezeroX
virtual RezeroY
virtual RezeroZ
virtual RezeroV

: RezeroX X RezeroLS ;
: RezeroY Y RezeroLS ;
: RezeroZ Z RezeroLS ;
: RezeroV nAxes 3 > if V RezeroLS endif ;

198.5	fvariable BearingPillar.X
1.8	fvariable BearingPillar.Y
0.0	fvariable HookXOffset
0.7	fvariable HookMargin


create _v12 {		( V1.2 =>Lz=60.5, Lv=50.5, NOx=0.0, NOy=0.0, Y Gearbox,  no ZV optos )
	
	0.300	0.300	0.450	0.450	( currents )
	321.0	151.0	60.50	50.50	( lengths )
	340.0	155.0	65.00	55.00	( ranges )
	0.050	0.050	0.000	0.000	( backlash )
	10.00	10.00	10.00	10.00	( startspeed )
	150.0	110.0	100.0	100.0	( maxspeed )
	700.0	700.0	700.0	700.0	( acceleration )
	0.050	0.050	0.050	0.050	( dwelltime )
	0.000	0.000	0.000	0.000	( optoposition )
	
	} 

create _v51 {	 						( V5.1 =>Lz=50.0, Lv=52.0, NOx=1.2, NOy=0.4, Y Gearbox,  no ZV optos )
	
	0.533	0.533	0.450	0.450	( currents )
	321.0	151.0	50.00	52.00	( lengths )
	340.0	155.0	55.00	55.00	( ranges )
	0.050	0.050	0.000	0.000	( backlash )
	10.00	10.00	10.00	10.00	( startspeed )
	130.0	80.00	30.00	30.00	( maxspeed )
	500.0	500.0	500.0	500.0	( acceleration )
	0.010	0.010	0.010	0.010	( dwelltime )
	1.200	0.400	0.000	0.000	( optoposition )
	
	} +


create _v54 {	 						( V5.4 =>Lz=62.0, Lv=52.0, NOx=1.2, NOy=0.4, Y Gearbox, ZV optos )
	
	0.533	0.533	0.450	0.450	( currents )
	321.0	151.0	62.00	52.00	( lengths )
	340.0	155.0	65.00	55.00	( ranges )
	0.050	0.050	0.000	0.000	( backlash )
	10.00	10.00	10.00	10.00	( startspeed )

CardType w@ 70 >= #if	

	150.0	110.00	100.0	100.0	( maxspeed )
	700.0	700.0	700.0	700.0	( acceleration )

#else

	150.0	70.00	60.00	60.00	( maxspeed )
	500.0	500.0	500.0	500.0	( acceleration )

#endif

	0.050	0.050	0.050	0.050	( dwelltime )
	1.200	0.400	0.000	0.000	( optoposition )
	
	} +


create _v55 {							( V5.5 =>Lz=62.0, Lv=52.0, NOx=1.2, NOy=0.4, no Y gearbox )
	
	0.533	0.533	0.450	0.450	( currents )
	321.0	151.0	62.00	52.00	( lengths )
	340.0	155.0	65.00	55.00	( ranges )
	0.050	0.050	0.000	0.000	( backlash )
	10.00	10.00	10.00	10.00	( startspeed )

CardType w@ 70 >= #if	

	150.0	110.00	100.0	100.0	( maxspeed )
	1500.0	1200.0	700.0	700.0	( acceleration )

#else

	150.0	70.00	60.00	60.00	( maxspeed )
	700.0	700.0	700.0	700.0	( acceleration )

#endif
	
	0.050	0.050	0.050	0.050	( dwelltime )
	1.200	0.400	0.000	0.000	( optoposition )
	
	} +


create _v56 {							( V5.6 =>Lz=62.0, Lv=52.0, NOx=0.0, NOy=0.0 )
	
	0.533	0.533	0.450	0.450	( currents )
	321.0	151.0	62.00	52.00	( lengths )
	340.0	155.0	65.00	55.00	( ranges )
	0.050	0.050	0.000	0.000	( backlash )
	10.00	10.00	10.00	10.00	( startspeed )

CardType w@ 70 >= #if	

	150.0	110.00	100.0	100.0	( maxspeed )
	700.0	700.0	700.0	700.0	( acceleration )

#else

	150.0	70.00	60.00	60.00	( maxspeed )
	700.0	700.0	500.0	500.0	( acceleration )

#endif

	0.050	0.050	0.050	0.050	( dwelltime )
	0.000	0.000	0.000	0.000	( optoposition )
	
	} +

create _v57 {							( V5.7 =>Lz=60.5, Lv=50.5, NOx=0.0, NOy=0.0 )
	
	0.533	0.533	0.450	0.450	( currents )
	321.0	151.0	60.50	50.50	( lengths )
	340.0	155.0	65.00	55.00	( ranges )
	0.050	0.050	0.000	0.000	( backlash )
	10.00	10.00	10.00	10.00	( startspeed )

CardType w@ 70 >= #if	

	150.0	110.0	100.0	100.0	( maxspeed )
	700.0	700.0	700.0	700.0	( acceleration )

#else

	150.0	70.00	60.00	60.00	( maxspeed )
	700.0	700.0	500.0	500.0	( acceleration )

#endif

	0.050	0.050	0.050	0.050	( dwelltime )
	0.000	0.000	0.000	0.000	( optoposition )
	
	} +

create _v58 {							( V5.8 for experimenting )
	
	0.533	0.533	0.450	0.450	( currents )
	321.0	151.0	60.50	50.50	( lengths )
	340.0	155.0	65.00	55.00	( ranges )
	0.050	0.050	0.000	0.000	( backlash )
	10.00	10.00	10.00	10.00	( startspeed )

CardType w@ 70 >= #if	

	50.00	50.00	120.0	120.0	( maxspeed )
	500.0	500.0	800.0	800.0	( acceleration )

#else

	1.500	0.700	0.600	0.600	( maxspeed )
	3.500	3.500	3.500	3.500	( acceleration )

#endif

	0.050	0.050	0.050	0.050	( dwelltime )
	0.000	0.000	0.000	0.000	( optoposition )
	
	} +
	
create _n10 {					( V1.0 =>Lx=130, Ly=133.5, Lz=50.0 )
	
	0.450	0.450	0.450	( currents )
	130.0	133.5	50.00	( lengths )
	132.0	135.0	55.00	( ranges )
	0.050	0.050	0.000	( backlash )
	10.00	10.00	10.00	( startspeed )
	52.00	52.00	100.0	( maxspeed )
	350.0	350.0	350.0	( acceleration )
	0.050	0.050	0.050	( dwelltime )
	0.000	0.000	0.000	( optoposition )
	
	} +

create _n11 {					( V1.1 =>Lx=132.5, Ly=133.5, Lz=50.0 )
	
	0.450	0.450	0.450	( currents )
	132.5	133.5	50.00	( lengths )
	132.0	135.0	55.00	( ranges )
	0.050	0.050	0.000	( backlash )
	10.00	10.00	10.00	( startspeed )
	80.00	80.00	100.0	( maxspeed )
	300.0	250.0	300.0	( acceleration )
	0.050	0.050	0.050	( dwelltime )
	0.000	0.000	0.000	( optoposition )
	
	} + drop (* . .( words allocated to tables ) cr *)

: _SetXYZ  word: n address: T

	n freverse ( reverse the stack )
	n 0 do

		i Axis>Channel >r

		r 		swap SetPitch
		r i' 4*		T + f@ SetCurrent
		r i' n 1 * + 4*	T + f@ SetLength
		r i' n 2 * + 4*	T + f@ SetRange
		r i' n 3 * + 4*	T + f@ SetBacklash
		r i' n 4 * + 4*	T + f@ SetStartSpeed
		r i' n 5 * + 4*	T + f@ SetMaxSpeed
		r i' n 6 * + 4*	T + f@ SetAcceleration
		r i' n 7 * + 4*	T + f@ SetDwellTime
		  i' n 8 * + 4*	T + f@ i' NominalOptoPosition f!
		i' 1 > if 1 else 0 endif r Motor .RoundOff _c!
		
		rdrop

	loop

	( 80 PulseGeneratorInterval ! )
;
: SetVerticalRoundoff word: ro
	nAxes 2 do
		ro i Axis>Channel Motor .RoundOff _c!
	loop
;

0 constant XYZ.Variant
: _SetXYZ.Variant [pfa] XYZ.Variant ! ;
: XYZV1.2	4 _v12 _SetXYZ 120 _SetXYZ.Variant ;
: XYZV5.1	4 _v51 _SetXYZ 3 [pfa] OptoAxes ! 510 _SetXYZ.Variant ; 
( 5.1 variants )
: XYZV5.0	XYZV5.1 500 _SetXYZ.Variant ; ( use customization )
: XYZV5.2	XYZV5.1
	zAxis 50.0 SetMaxSpeed vAxis 50.0 SetMaxSpeed
	zAxis 20.0 SetStartSpeed vAxis 20.0 SetStartSpeed
	zAxis 150.0 SetAcceleration vAxis 150.0 SetAcceleration
	520 _SetXYZ.Variant
;

: XYZV5.4	4 _v54 _SetXYZ  540 _SetXYZ.Variant ; 
( 5.4 variants )
: XYZV5.3	XYZV5.4 3 [pfa] OptoAxes ! 530 _SetXYZ.Variant ; ( only XY optos )

: XYZV5.5	4 _v55 _SetXYZ 550 _SetXYZ.Variant ;
: XYZV5.6	4 _v56 _SetXYZ 560 _SetXYZ.Variant ;
: XYZV5.7	4 _v57 _SetXYZ 570 _SetXYZ.Variant ;
: XYZV5.8
		XYZV5.7
		95.8 151.0 SetShieldHook
		580 _SetXYZ.Variant
;

( Nano )
: XYZN1.0	3 _n10 _SetXYZ 100 _SetXYZ.Variant ;
: XYZN1.1	3 _n11 _SetXYZ 110 _SetXYZ.Variant ;

" XYZ-CFG.FTH Exit" stackCheck
