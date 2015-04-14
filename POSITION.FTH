.( Compiling Position.fth Version 8.05 ) cr
" POSITION.FTH Entry" stackCheck

( TRUE [pfa] DEBUG ! )

string PosFile "POSITION.DAT"
string AdjustFile "ADJUST.DAT"

: pv? PositionsValid? . ;
: SetPositionsValid 1 _spv ;
: SaveMotorPositions

       ( PositionsValid? 0= if exit endif )

local	ds> >es 0 PosFile str>DOS1 fcreate const dword: fh

	( ." SMP: file handle = " fh . cr )
	fh if
	  16 0 do
	    fh
	    i 1+ dup GetPosition ( ." SMP data = " .s cr ... )
	    " %d %>%f%<" format str>DOS1
		( ." After moving to DOS buffer " .s cr ... )
	    count rdup fwrite
		( ." SMP bytes written = " dup . cr ... cr )
	    r> != if
	      6 error _! leave
	    endif
	  loop

	  fh fclose ?dup if cls dup error _! ." fclose error = " . endif
	else
	  ." Failed to create " PosFile count type cr
	  6 error _! 
	endif

	error @ ?dup if
	  "  : Can't write file <POSITION.DAT>" 1+ swap ."abort ( " )
	else
		SetPositionsValid
	endif
;

: LoadMotorPositions
	." Loading motor positions ..."
local	PosFile getfile const word: nbytes

	0 word: mcount
	nbytes if
	  es> 0 0 swapstream
	  begin
	     getuf if
		over Motor 0 over ( .s cr ... ) _! ( Unsafe )
		.PhaseOffset 0 swap _w!
		SetPosition mcount ++ FALSE else TRUE
	     endif
	  until
	  0 StepError _w! 
	  swapstream drop drop drop
	  mcount @ 16 = 
	  dup 0= if PosFile fdelete drop endif ( invalid position file )
	else
	  FALSE
	endif
	_spv ( saves 0 or -1 to PositionsValid )
	es> DOSfree drop
	0 error _! 
	( mcount @ )
	cr
;
: smp SaveMotorPositions ;
: lmp LoadMotorPositions ;

: shutdown
( noisy )

	ClearSteps
	12 1 do
		i SetPhase0
	loop
	off


	PositionsValid? if
	  SaveMotorPositions
	  -1 _spv
	endif

;

: SaveAdjustData
local	ds> >es 0 AdjustFile fcreate const word: fh

	0 error _!
	fh if
	
	  fh
	  4 0 do i  AxisOffset f@ loop
	  " IndexPosition %>  %f%>  %f%<IndexPositionZV %>  %f%>  %f%<" format
	  fputs
	  if
	  	." fputs failed (332) " cr
		( leave )
	  endif

	  fh
	  4 0 do
	  	i nAxes < if
			i Axis>Channel 1- LengthOffset
		else
			0.0
		endif
	  loop
	  " LengthOffset %>%f%>%f%<LengthOffsetZV %>%f%>%f%<" format
	  fputs
	  if
	  	." fputs failed (346) " cr
		( leave )
	  endif

	  fh
	  0 TipLengthAdjust f@ 1 TipLengthAdjust f@
	  " TipLengthAdjust %>%f%>%f%<" format
	  fputs
	  if
	  	." fputs failed (108) " cr
		( leave )
	  endif

	  fh
	  BearingPillar.X f@ BearingPillar.Y f@ HookMargin f@ HookXOffset f@
	  " BearingPillar %>%6.2f%>%6.2f%<HookMargin %>%6.2f%<HookXOffset %>%6.2f%<" format
	  fputs
	  if
	  	." fputs failed (116) " cr
		( leave )
	  endif

	  fh 12 0 do i Cx loop 
	  " Cx %>  %f%>  %f%>  %f%>  %f%<Cy %>  %f%>  %f%>  %f%>  %f%<Cz %>  %f%>  %f%>  %f%>  %f%<" format
	  fputs if
	  	." fputs failed (123) " cr
		( leave )
	  endif

	  fh Configuration " Configuration%>%d%<" format
	  fputs if
	  	." fputs failed (129) " cr
		( leave )
	  endif

	  fh fclose drop
	else
	  6 error _!
	endif

	error @ if
	  fh if
		"  : Can't write file <ADJUST.DAT>"
	  else
		"  : Can't open file <ADJUST.DAT> for writing"
	  endif
	  1+ error @ ."abort ( " )
	endif
;
: SetAxisCoefficients word: axis
	4 0 do 3 i - axis 4* + @tea Cx f! loop
	axis 4 * Cx axis @AxisLengthOffset f!
	
;
: GuessSteps/Cycle word: Axis
local 	8 word: oldSteps/cycle

	Axis NominalOptoPosition f@ fabs 0.9 f> if ( yes - an old XYZV )
	
		Axis AxisOffset f@ Axis NominalOptoPosition f@ 0.2 f- f/ fabs
		begin
			fdup Axis 2 < if 22.0 else 38.0 endif f>
		while
			oldSteps/cycle @ 2* oldSteps/cycle ! 
			2.0 f/
		repeat
		2drop
		oldSteps/cycle @
	else
		0
	endif
;
( virtual FindIndexPositions )
: _AxOffPrime
	  TRUE 4 0 do i AxisOffset f@ f0= and loop ( if all AxisOffsets have 0.0 value, use NominalOptoPosition values )
	  if 4 0 do i NominalOptoPosition f@ i  AxisOffset f! loop endif
;
: _SetCf word: config
	config [pfa] Configuration !
	config cfLCP and LCP_Dispensing
;
: LoadAdjustData
	." Loading calibration data ..." 
( noisy )
local	ds> >es AdjustFile getfile const word: nbytes

199 ?stack
	( ." Enter LAD. File length = " nbytes . cr ... cr quit )
	TRUE dword: OldFormat
	64 word: oldSteps/cycle
	0 word: bad
	FALSE word: IndexPosInSteps

206 ?stack
	nbytes if
	  es> 0 0 swapstream
	  begin
210 ?stack
	  (  ." Start begin " .s cr ... )
	    wsword dup 1+ c@ if	( file terminated with nul )

		DEBUG if ." Record = " dup count type cr endif

	      select

		r " IndexPosition" $i= ?case:

			fnumber ?dup if ( numeric descriptor on stack )
			  ( ." fnumber produced " .s cr )
			  $4000 and if ( decimal point in number )
				DEBUG if ." mm position : " endif
			  else
				TRUE IndexPosInSteps w! 
				DEBUG if ." Step position : " endif
			  endif
			
			  DEBUG if fdup ." X IndexPosition = " f. cr endif
				
			  ( X AxisOffset f! ) fdrop
			else
			  bad ++ endif
			fnumber if ( Y AxisOffset f! ) fdrop else bad ++ endif
		endcase

		r " IndexPositionZV" $i= ?case:

			fnumber if ( Z AxisOffset f! ) fdrop else bad ++ endif
			fnumber if ( V AxisOffset f! ) fdrop else bad ++ endif
		endcase

		r " TipLengthAdjust" $i= ?case:

			fnumber if 0 TipLengthAdjust f! else bad ++ endif
			fnumber if 1 TipLengthAdjust f! else bad ++ endif
		endcase

		r " LengthOffset" $i= ?case:
			DEBUG if ." LengthOffset record" cr endif
			fnumber if fdup 0 @AxisLengthOffset f! 0 @tea Cx f! else bad ++ endif
			fnumber if fdup 1 @AxisLengthOffset f! 4 @tea Cx f! else bad ++ endif
		endcase

		r " LengthOffsetZV" $i= ?case:

			DEBUG if ." LengthOffsetZV record" cr endif
			
			fnumber if
				fdup 2 @AxisLengthOffset f!
				8 @tea Cx f!
			else
				bad ++
			endif
			
			fnumber if
				nAxes 4 = if
					3 @AxisLengthOffset f!
				else
					drop 
				endif
			else
				bad ++
			endif
			
			FALSE OldFormat ! 

		endcase

		r " BearingPillar" $i= ?case:
			fnumber if BearingPillar.X f! else bad ++ endif
			fnumber if BearingPillar.Y f! else bad ++ endif
		endcase

		r " HookMargin" $i= ?case:
			fnumber if HookMargin f! else bad ++ endif
		endcase

		r " HookXOffset" $i= ?case:
			fnumber if HookXOffset f! else bad ++ endif
		endcase

		r " Cx" $i= ?case:
			4 0 do fnumber 0= if bad ++ endif loop 0 SetAxisCoefficients
			0 Cx 0 @AxisLengthOffset f!
		endcase
		r " Cy" $i= ?case:
			4 0 do fnumber 0= if bad ++ endif loop 1 SetAxisCoefficients
			0 Cy 1 @AxisLengthOffset f!
			
		endcase

		r " Cz" $i= ?case:
306 ?stack
			4 0 do fnumber 0= if bad ++ endif loop 2 SetAxisCoefficients
			0 Cz 2 @AxisLengthOffset f!
			nAxes 4 = if
				0 Cz 3 @AxisLengthOffset f!
			endif
312 ?stack
		endcase

		r " Configuration" $i= ?case:
			lnumber
			0= if bad ++ endif _SetCf
		endcase
	      endselect

	      bad @
	    else
	      drop TRUE
	    endif
324 ?stack
	  until
327 ?stack
	  swapstream drop drop drop

	  bad @ if ." Format is BAD " cr endif

	  IndexPosInSteps @ OldFormat @ or if
	  	cr
	  	cr
	  	IndexPosInSteps @ if	." IndexPos was in steps in ADJUST.DAT" endif
	  	OldFormat @ if	." Old Format ADJUST.DAT" endif
		cr
	  	." Warning : calibration information obsolete. Attempting to rebuild from old data..." cr
	  	( AxisOffset values will be in microsteps, so try and work out old pitch )
	  	
(*	  	Y GuessSteps/Cycle ?dup if
	  		oldSteps/cycle w! 
	  	else
	  		X GuessSteps/Cycle ?dup if
	  			oldSteps/cycle w! 
	  		endif
	  	endif
280 ?stack			  	
	  	nAxes 0 do
	  		i AxisOffset f@ i Axis>Channel GetPitch f/ 64 oldSteps/cycle w@ / 0 ltof f*
	  		fdup i AxisOffset f! ." Axis " i . ." offset set to " f. cr
	  	loop
	  	
	  	." FindIndexPositions " cr *)
	  	
	  endif
  	
	  bad @ 0=
	else
	  FALSE
	endif
	es> DOSfree drop
	if
	  0 error _!
	else
	  6 error _!
	endif
356 ?stack
	_AxOffPrime	
358 ?stack
	cr
;
: sad SaveAdjustData ;
: lad LoadAdjustData ;
: SetConfiguration _SetCf SaveAdjustData ;

: GetChannels word: motors

	motors msAXES = if ." AChan" nAxes endif
	motors msSYRS = if ." SChan" nSyrs endif
	0 do
	 space i . i motors GetMno .
	loop cr
;
: GetPitches word: motors

	motors msAXES = if ." APitch" nAxes endif
	motors msSYRS = if ." SPitch" nSyrs endif
	0 do
	 space i . i motors GetMno GetPitch f.
	loop cr
;
: GetLengths word: motors

	motors msAXES = if ." ALen" nAxes endif
	motors msSYRS = if ." SLen" nSyrs endif
	0 do
	 space i . i motors GetMno GetLength f.
	loop cr
;
: GetRanges word: motors

	motors msAXES = if ." ARange" nAxes endif
	motors msSYRS = if ." SRange" nSyrs endif
	0 do
	 space i . i motors GetMno GetRange f.
	loop cr
;
: GetSpeeds word: motors

	motors msAXES = if ." ASpeed" nAxes endif
	motors msSYRS = if ." SSpeed" nSyrs endif
	0 do
	 space i . i motors GetMno GetCurrentSpeed f.
	loop cr
;
: GetMaxSpeeds word: motors

	motors msAXES = if ." AMaxSpeed" nAxes endif
	motors msSYRS = if ." SMaxSpeed" nSyrs endif
	0 do
	 space i . i motors GetMno GetMaxSpeed f.
	loop cr
;

: GetMotorData

	msAXES	GetChannels
	msAXES	GetPitches
	msAXES	GetLengths
	msAXES	GetRanges
	msAXES	GetSpeeds

	msSYRS	GetChannels
	msSYRS	GetPitches
	msSYRS	GetLengths
	msSYRS	GetRanges
	msSYRS	GetSpeeds
	msSYRS	GetMaxSpeeds
	PositionsValid? 0= if
	  LoadMotorPositions
	endif
	PositionsValid? if 1 UpdateMotors endif
;

: mmNudge word: mno float: mm

	mno 10.0 SetCurrentSpeed mno mm MoveLBy 
	mno GetLPosition 
	amSPEED Actuate
	begin
	  get_status STEPPING and
	while
	repeat
	mno GetLPosition dup f. mno 1.0 SetSpeedFactor
	swap
;

" POSITION.FTH Exit" stackCheck
