.( Compiling DumpHard.fth Version 8.01 ) cr
" DumpHard.FTH Entry" stackCheck

with Dump +definitions

: ldump
	cr me.identify cr
	." m#  Length    Range  Position  Offset    " cr
	17 1 do
	  i 2		r. space
	  i GetLength	f. space
	  i GetRange	f. space
	  i GetPosition	f. space
	  i 1- LengthOffset f. space
	  cr
	loop
;
: _vdheader 	."  # Stat   Position      Target   Distance  DeltaX DeltaXRun  DeltaV  Acc.Dist" cr ;
: _vd dword: mno
local	mno Motor const address: Mptr

	mno 2 r. space
	Mptr .Status  w@  whex. space
	Mptr  w@  Mptr 2+ @ word. ascii . emit hex.
	Mptr .TargetPosition	@ word. ascii . emit whex.
	Mptr .Distance	@ word. ascii . emit whex.
	Mptr .DeltaX	@ hex.
	Mptr .DeltaXRun	@ hex.
	Mptr .DeltaV	@ hex.
	Mptr .AccelerationDistance @ hex.
	cr
;
: sdump
	cr me.identify cr
	_vdheader
	
	12 0 do
		i 1+ _vd
	loop
;
: ccdump
	cr me.identify cr
	." Cx " 4 0 do i Cx f. loop cr
	." Cy " 4 0 do i Cy f. loop cr
	." Cz " 4 0 do i Cz f. loop cr
	." Cc " 4 0 do i Cc f. loop cr
;

: cdump

	cr me.identify cr
	."  #   VStart     VRun   Accelerat Distance  DeltaX   DeltaXRun   DeltaV" cr

	12 0 do
		i 1+ 2 r. space
		i 1+ Motor .Vstart	@ word. ascii . emit whex.
		i 1+ Motor .Vrun	@ word. ascii . emit whex.
		i 1+ Motor .Acceleration @ word. ascii . emit whex.
		i 1+ Motor .Distance	@ hex.
		i 1+ Motor .DeltaX	@ word. ascii . emit whex.
		i 1+ Motor .DeltaXRun	@ word. ascii . emit whex.
		i 1+ Motor .DeltaV	@ word. ascii . emit whex.
		cr
	loop
;

: mdump
	cr me.identify cr
	." m#   Pitch  Position  LimitLo  LimitHi StartSpeed RunSpeed MaxSpeed" cr
	17 1 do
	  i 2		r. space
	  i GetPitch	f. space
	  i GetLPosition f. space
	  i GetLimitLo	f. space
	  i GetLimitHi	f. space
	  i GetStartSpeed f. space
	  i GetCurrentSpeed	f.
	  i GetMaxSpeed	f.
	  cr
	loop
;

: | $B3 emit ;

: _motor?1 dword: Index dword: Group
	Index Group msAXES = if Axis>Channel else Syringe>Channel endif
	local const dword: mno

	Index . mno 2 r. 2 spaces
	Group msAXES = if
		Index 2 < if
			OptoAxes Index bit?
		else
			FALSE
		endif
		if ."   Belt" else ."  Screw" endif
	else
		( syringe drive )
		mno 1- MotorRecord @
		?dup if
		  with SyringeDrives
			.Type @ nfa swap 1+ swap 1- type
		  endwith ( stepper )
		else
		  ." (null)"
		endif
	endif
	space |

	mno GetPitch f. |
	mno Motor .Pitch f@ 65536.0 f* f. |
	mno GetLPosition f. |
	mno GetPosition f. |
	mno GetBacklash f. |
	mno GetLength f. |
	mno GetRange f. |
	mno Motor .PhaseOffset 1+ c@ byte.
	cr
;

: _motor?2 dword: Index dword: Group

	Index Group msAXES = if Axis>Channel else Syringe>Channel endif
	local const dword: mno
	
	Index . mno 2 r. space
	mno GetCurrent f. |
	mno GetStartSpeed f. |
	mno GetCurrentSpeed f. |
	mno GetMaxSpeed f. |
	mno GetAcceleration f. |
	mno GetDwellTime f. |
	space mno Motor .AccelCount w@ whex. |
	mno Motor .RoundOff c@ ascii 0 + emit |
	space mno Motor .Status w@ whex. |
	mno GetMotorLSInputs 1 r. |
	mno 2 MotorPower if ascii 1 else ascii 0 endif emit
	cr
;
: _motordump dword: Group
	Group msAXES = if nAxes else nSyrs endif
	local const dword: nMotors

	." #  m  Style  ³  Pitch ³mm/cycle³ Pos(L) ³ Pos(P) ³Backlash³ Length ³  Range ³Ph" cr
	nMotors 0 do i Group _motor?1 loop cr

	." #  m  Current³ vStart ³  vNow  ³  vMax  ³  dv/dt ³ tDwell ³aCount³R³Status³L³P" cr
	nMotors 0 do i Group _motor?2 loop
;

-definitions

: usddump
	cr me.identify cr
	msSYRS _motordump
;

: xyzdump
	cr ." xyzdump" cr
	XYZ.Variant wtof 100.0 f/ " XYZ=%4.2f%<" format count type
	msAXES _motordump
;
: .LS	( display all limit switch values continuously )

	cls
	me.identify
	0 5 at ." Motor           1   2   3   4   5   6   7   8   9   10  11  12  - <ESC> to end" cr
	begin
		0 6 at ." Value "
		( 15 0 do GetAllLSInputs 2drop loop )
		GetAllLSInputs dup hex.
		13 1 do
			space dup 3 and . space
			2 shr
		loop
		drop
		10 ms
	getKey until
;
+definitions
: DB6. dword: bno
local	bno 8 * BaseAddr  w@  + const dword: port
	port word. ascii : emit space
	port inw hex.
	port 1+ in dup byte. space
	port 4+ inw hex.
	$10 and if
	  ."  : configured."
	else
	  ."  : reset."
	endif
;

: DB6dump
	cr me.identify cr
	3 0 do
		." Board# " i . i DB6. cr
	loop
	cr ."  Stat  Addr  Inst  Last  Max" cr
	SteppingStatus 5 0 do
	  dup i 2* +  w@  space hex.
	loop drop cr
;

: DB7? dword: bno 0 $30 bno + >DB7 1 ms DB7> ;
: DC7Response? GetDC7Status 2 and 0= ;
: DC7? GetDC7Status ;
: DB7dump
	cr me.identify cr
	4 0 do
		i . i DB7? 1 ms
		DC7Response? if
			dup hex. ." Inputs : " i GetDB7LSInputs byte.
			."  FPGA Version "
			dup $8000 and if
				." D1."
			else
				." R1."
			endif
			12 shr 7 and .
		else
			drop ." ----"
		endif
		cr
	loop
;
-definitions

: DBdump CardType  w@  70 < if DB6dump else DB7dump endif ;
endwith

" DumpHard.FTH Exit" stackCheck
