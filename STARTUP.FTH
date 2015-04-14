.( Compiling  Startup.fth Version 8.00 ) cr
" Startup.fth Entry" stackCheck

: info
	cr
	." Douglas Instruments Motion Control Centre" cr
	."         Control Software Version " version count type cr
	."         Hardware configuration : " systemName count type
				    ."  for " userName count type cr
	."         Hardware Serial Number : " serialNumber count type
	." Updated  : " hardwareDate count type cr cr
;
LED++
LoadAdjustData
LED++
LoadMotorPositions
LED++
: test  " test.fth" >asciiz str>DOS1 _fload ;
: tunes " tunes.fth" >asciiz str>DOS1 _fload ;
: hedgehog version count type cr ;
cmdLoad	(			LED++ )
Snap definitions

( create snap records )

0 DOSpad CreateSnapRecord DSnapRecord
0 $D594 CreateSnapRecord CSnapRecord cs> CSnapRecord SetSnapSegment
_xbase here _xbase - CreateSnapRecord XSnapRecord

( set triggers and initialize snap records )

30	DSnapRecord .SnapTrigger _!
2	CSnapRecord .SnapTrigger _!
2	XSnapRecord .SnapTrigger _!

DSnapRecord 0 MemSnap drop
CSnapRecord 0 MemSnap drop
XSnapRecord 0 MemSnap drop

: CSnap	CSnapRecord AutoSnap CSnapRecord 1 SnapPrint ;
: DSnap DSnapRecord AutoSnap DSnapRecord 1 SnapPrint ;
: XSnap	XSnapRecord AutoSnap XSnapRecord 1 SnapPrint ;

: DS. DSnapRecord SnapRecord. ;
: CS. CSnapRecord SnapRecord. ;
: XS. XSnapRecord SnapRecord. ;

( CS. DS. XS. )

forth stepper definitions

" STARTUP.FTH Exit" stackCheck
