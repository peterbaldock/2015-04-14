.( Compiling    Comms.fth Version 8.10 ) cr
(*
	2015-04-14	Local versioning, moved to GitHub
	2015-04-14	Version 08.10.0000	GitHub
	
*)

" COMMS.FTH Entry" stackCheck
decimal
1	constant HOSTPORT
115200 constant HOSTRATE
2	constant LEVELPORT
9600 constant LEVELRATE
HOSTPORT HostPort _w! 
HOSTPORT CommReset drop
LEVELPORT CommReset drop
7 LEVELPORT CommPort 6 + w@ out ( reset and enable FIFO )
0 LEVELPORT CommPort $16 + _c! ( mask hardware handshaking )
0.5 LEVELPORT CommPort $0D + _!	( TOin = 1/2 second )

( USB Section )
$319 USBPort _w!	( poke USB address )

: CommsLog 
	if
		0 " COMMS.LOG" ds> >es fcreate CommsLogHandle w! 
	else
		CommsLogHandle w@ fclose hex. 0 CommsLogHandle w! 
	endif
;

: BitDump address: Legend dword: nBits dword: Bits
local Legend c@ nBits / const dword: dS
	nBits 0 do
	  Legend 1+ i drop dS * + dS type ascii = emit
	  Bits nBits i - 1- bit? if ascii 1 else ascii 0 endif emit space
	loop
;

: CommDump word: Port
local	Port CommPort 6 + w@ const address: paddr

	cr Port CommPort 1+ 4 type ."  : RxD IEn ISR LCR MCR LSR MSR Scr" cr
	paddr hex. ." :"
	paddr 1- paddr 7 + 0 do
	  i in
	-1 +loop
	8 0 do space space byte. loop cr
	cr
	." MCR: " " LoopOut2Out1 RTS DTR" 5 paddr 4 + in BitDump cr
	." LSR: " " FIFOTEMTTHRE  BI  FE  PE  OE  DR" 8 paddr 5 + in BitDump cr
	." MSR: " "  DCD  RI DSR CTSDDCDTERIDDSRDCTS" 8 paddr 6 + in BitDump cr

;

: CommSetRate dword: Rate dword: Port
local
	Port CommPort 6 + w@ const address: paddr
	paddr 3 + const address: LCR

	115200 Rate /
	cwbb

	LCR in $80 or LCR out

	paddr 1+ out paddr out

	LCR in $7f and LCR out

;

0	variable	CommAlarm
74 ?stack

: CommPutWait dword: c dword: Port

	Port CommPort $11 + f@ CommAlarm Alarm.Set

	begin
		c Port CommPut
		dup if
			CommAlarm Alarm.Test if 0 endif
		else
			0
		endif
	while
		poll 
	repeat

;

: CommPutString address: S dword: Port

	S count over + swap do
	
		i c@ Port CommPutWait
		if
			." Can't output on " Port CommPort 1+ 4 type 25 abort 
		endif

	loop

;
: CommGet dword: Port	( does not use BIOS interrupt )

local Port CommPort 6 + w@ const address: paddr

	paddr 5 + in 1 and dup
	if
	  paddr in swap
	endif
;
113 ?stack
: CommGetWait word: Port

(	Returns:

		character, 1 for success.
		0 for failure
)	
	Port CommPort 13 + f@ CommAlarm Alarm.Set

	begin

	 Port CommGet
	 dup if
	 	TRUE	( terminate while on success )
	 else
	 	CommAlarm Alarm.Test if
	 		TRUE
	 	endif
	 endif
	 
	0= while
		poll 
	repeat

(	." CommGetWait returns " .s cr )
;
: CommGetString address: str dword: Port
local	str count const dword: n
		  const address: buff

	0 str c!

	buff n + buff do
			
		Port CommGetWait
		0= if	( ." (no input)" )

			i buff - str c!
			( ." Count = " str wc@ . cr )
			rdrop r> dup >r 1- >r
		else
		 ( dup ." Ch=" hex. cr )
		 i c!
		 i str - str c!
		endif
		
	loop
	0 str count + c!
	
;
164 ?stack

: CommGetUntilChar address: str dword: Port dword: Char
local	str count const dword: n
		  const address: buff
	0 str c!

	buff n + buff do
			
		Port CommGetWait
		0= if	(* ." (no input)" *)
		  TRUE
		else
		 dup i c!
		 i str - str c!
		 Char =
		endif

		if 		
		 rdrop r> dup >r 1- >r
		endif
	loop
	0 str count + c!
	
;
: CommGetLine $0d CommGetUntilChar ;

HOSTRATE HOSTPORT CommSetRate
LEVELRATE LEVELPORT CommSetRate
187 ?stack

COMMS_IN_ON COMMS_IN_EN or
190 ?stack
 COMMS_OUT_EN or CON_OUT_EN or HostControl
192 ?stack
 _w! 
194 ?stack

" COMMS.FTH Exit" stackCheck

