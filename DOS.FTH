.( Compiling      DOS.FTH Version 8.00 ) cr
" DOS.FTH Entry" stackCheck

0 variable _MidnightCount

: GetTickCount

	0 ax w! $1a int drop _MidnightCount @ 
	
	ax w@ if
		dup 1573040 + _MidnightCount !
	endif

	dx w@ cx w@ >far +
;

: Alarm.Set dword: Delay address: TVariable 
	Delay 1194.3182 f* ftol GetNanoTicks + TVariable !
; 

: Alarm.Test @ GetNanoTicks < ;


: bcd>	dup $0F and swap 4 shr 10 * + ;
: time	2 ah c! $1a int drop ch c@ bcd> cl c@ bcd> dh c@ bcd> ;
: date	4 ah c! $1a int drop 1900 ch c@ if 100 + endif cl c@ bcd> + dh c@ bcd> dl c@ bcd> ;
: leap? word: year
	year 4 /mod swap 0= if
		25 /mod swap 0= if	( century )
			3 and if ( not 4th century )
				0
			else
				1
			endif
		else
			drop 1
		endif
	else
		drop 0
	endif
;
: notleap word: year 1 year leap? - ;
: doy word: year word: month word: day
	month 275 * 9 /
	month 9 + 12 /
	1 year notleap +
	*
	-
	day + 30 -
;

: >datetime word: year word: month word: day word: hour word: minute word: second
	year 1900 - 1461 * 1- 4/ year month day doy + 16 shl 
	hour 60 * minute + 60 * second +
	+
;
: pack

	0 dx w! 0 ds w! $41 fcall drop
;

" DOS.FTH Exit" stackCheck
