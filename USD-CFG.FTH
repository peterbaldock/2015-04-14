.( Compiling  USD-Cfg.fth Version 8.00 ) cr
" USD-CFG.FTH Entry" stackCheck

: Mno>Syringe word: Mno
local -1 word: Syringe
	nSyrs 0 do
		i Syringe>Channel Mno =
		if
			i Syringe ! leave
		endif
	loop

	Syringe @
;


here
vocabulary SyringeDrives SyringeDrives definitions

create _USD1.0
{
	me	( Type )
	0	( Mno )
	FALSE	( HasOpto )
	0.533	( Current )
	314.96	( Pitch )
	92.000	( Length )
	0.000	( ClampOffset )
	0.000	( Backlash )
	4.00	( MaxSpeed )
	3.00	( StartSpeed )
	50.0	( Acceleration )
	0.00	( DwellTime )
	4	( RoundOff )
} dup constant SDTable.Length

create _USD2.0
{
	me	( Type )
	0	( Mno )
	FALSE	( HasOpto )
	0.533	( Current )
	200.00	( Pitch )
	85.500	( Length )
	6.500	( ClampOffset )
	0.000	( Backlash )
	6.00	( MaxSpeed )
	3.00	( StartSpeed )
	50.0	( Acceleration )
	0.00	( DwellTime )
	4	( RoundOff )
} +

create _USD2.1
{
	me	( Type )
	0	( Mno )
	TRUE	( HasOpto )
	0.533	( Current )
	200.00	( Pitch )
	85.500	( Length )
	6.500	( ClampOffset )
	0.000	( Backlash )
	6.00	( MaxSpeed )
	3.00	( StartSpeed )
	50.0	( Acceleration )
	0.00	( DwellTime )
	4	( RoundOff )
} +

create _LCP2.0
{
	me	( Type )
	0	( Mno )
	FALSE	( HasOpto )
	0.533	( Current )
	200.00	( Pitch )
	85.500	( Length )
	20.80	( ClampOffset )
	0.000	( Backlash )
	6.00	( MaxSpeed )
	3.00	( StartSpeed )
	50.0	( Acceleration )
	0.05	( DwellTime )
	4	( RoundOff )
} +

create _LCP2.1
{
	me	( Type )
	0	( Mno )
	TRUE	( HasOpto )
	0.533	( Current )
	200.00	( Pitch )
	83.040	( Length )
	20.80	( ClampOffset )
	0.000	( Backlash )
	10.00	( MaxSpeed )
	3.00	( StartSpeed )
	50.0	( Acceleration )
	0.05	( DwellTime )
	4	( RoundOff )
} +

DEBUG #if . .( Bytes used in Syringe Tables ) cr #else drop #endif

: SDRecord
		address: Type
		word:	Mno
		float:	Backlash
	<_builds	
		here 0 , ( reserve to hold length )
		Type ,
		Mno , 

		SDTable.Length 0 do	( copy static table data )
		  Type i + c@ c,
		loop
		0 ,			( spare )
		Backlash over .Backlash f!	( @@@@@ careful here )

		dup here - swap !
	does>
;

(*	16-bit structure
0 			offset	.RecordLength WORD
.RecordLength offset	.Type	WORD
.Type 		offset	.Mno	WORD
.Mno		offset	.HasOpto	WORD
.HasOpto		offset	.Current	FLOAT
.Current		offset	.Pitch	FLOAT
.Pitch		offset	.Length	FLOAT
.Length		offset	.ClampOffset	FLOAT
.ClampOffset	offset	.Backlash	FLOAT
.Backlash	offset	.MaxSpeed	FLOAT
.MaxSpeed	offset	.StartSpeed	FLOAT
.StartSpeed	offset	.Acceleration	FLOAT
.Acceleration	offset	.DwellTime	FLOAT
.DwellTime	offset	.RoundOff	WORD
.RoundOff	offset	.Spare		WORD
.Spare		constant	SDRecord.Length
*)
(*	32-bit structure	*)
0 offset	.RecordLength
4 offset	.Type
8 offset	.Mno
12 offset	.HasOpto
16 offset	.Current
20 offset	.Pitch
24 offset	.Length
28 offset	.ClampOffset
32 offset	.Backlash
36 offset	.MaxSpeed
40 offset	.StartSpeed
44 offset	.Acceleration
48 offset	.DwellTime
52 offset	.RoundOff
56 offset	.Spare
64 constant 	SDRecord.Length


16 SDRecord.Length array DriveList
0 variable ListIndex

: .copy address: source address: target
	source @ target @ = if
		source target source ( get size ) @ cmove
	else
		" SyringeDrives.Copy : target is different size " 1+ 8 ."abort ( " )
	endif
;
: .dump address: SDRec

	SDRec .Type @ nfa type cr
	." Mno         : "	SDRec .Mno		@ . cr
	." Current     : "	SDRec .Current	f@ f. cr
	." Pitch       : "	SDRec .Pitch		f@ f. cr
	." Length      : "	SDRec .Length	f@ f. cr 
	." ClampOffset : "	SDRec .ClampOffset	f@ f. cr
	." Backlash    : "	SDRec .Backlash	f@ f. cr
	." MaxSpeed    : "	SDRec .MaxSpeed	f@ f. cr
	." StartSpeed  : "	SDRec .StartSpeed	f@ f. cr
	." Acceleration: "	SDRec .Acceleration	f@ f. cr
	." DwellTime   : "	SDRec .DwellTime	f@ f. cr
	." RoundOff    : "	SDRec .RoundOff	@ . cr
;
: .SetChannel address: SDRec
local SDRec .Mno @ const word: Mno

	Mno SDRec .Current	f@ SetCurrent
	Mno SDRec .Pitch	f@ SetPitch
	Mno SDRec .Length	f@ SDRec .ClampOffset f@ f+ SetLength
	Mno SDRec .Length	f@ SetRange
	Mno SDRec .Backlash	f@ SetBacklash
	Mno SDRec .MaxSpeed	f@ SetMaxSpeed
	Mno SDRec .StartSpeed f@ SetStartSpeed
	Mno SDRec .Acceleration f@ SetAcceleration
	Mno SDRec .DwellTime	f@ SetDwellTime

	SDRec .RoundOff @ Mno Motor .RoundOff _c!
	SDRec .HasOpto @ Mno 1- [pfa] OptoDrives >bit!

	SDRec Mno 1- MotorRecord !	( save pointer to record for this motor )

;
: .SetProperties address: SDTable word: Mno float: Backlash
local	ListIndex @ DriveList const address: SDRec 

(	SDTable SDRec .Type ! )
	SDTable SDRec .Type SDTable.Length cmove
	Mno SDRec .Mno !
	Backlash SDRec .Backlash f!

	SDRec .SetChannel
	ListIndex ++
;
0 constant _LCPIndex
0 constant _LVIndex

stepper definitions
with SyringeDrives

: ForLargeVolume ListIndex @ 1- [pfa] _LVIndex ! ;
: ForLCP ListIndex @ 1- [pfa] _LCPIndex ! ;

: USD1.0 word: Mno float: Backlash
	_USD1.0 Mno Backlash .SetProperties
;
: USD2.0 word: Mno float: Backlash
	_USD2.0 Mno Backlash .SetProperties
;
: USD2.1 word: Mno float: Backlash
	_USD2.1 Mno Backlash .SetProperties
;
: LCP2.0 word: Mno float: Backlash
	ListIndex @ 1- [pfa] _LCPIndex !
	_LCP2.0 Mno Backlash .SetProperties
;
: LCP2.1 word: Mno float: Backlash
	ListIndex @ 1- [pfa] _LCPIndex !
	_LCP2.1 Mno Backlash .SetProperties
;
: LCP_Dispensing word: Enabled
local	_LCPIndex DriveList const word: LCPDrive
	LCPDrive .Mno @ const word: Mno

	Enabled if
		LCPDrive .SetChannel
		vAxis 550.0 SetAcceleration
		vAxis 60.0 SetMaxSpeed	( **Reduced speed and acceleration for LCP arm )
	else
		ListIndex 0 do
			i LCPDrive != if
				i DriveList .Mno @ Mno = if
					i DriveList .SetChannel
					vAxis zAxis GetAcceleration SetAcceleration
					vAxis zAxis GetMaxSpeed SetMaxSpeed
					leave
				endif
			endif
		loop
	endif
;	
: LCPChannel
	Configuration 2 and 0= if
		" Not configured for LCP" 1+ 33 ."abort ( " )
	endif

	_LCPIndex DriveList .Mno @ Mno>Syringe
;

DEBUG #if
	.( USD-CFG.FTH Bytes used : ) here swap - . cr
#else
	drop
#endif

endwith

" USD-CFG.FTH Exit" stackCheck
