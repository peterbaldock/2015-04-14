.( Compiling     Snap.FTH Version 8.00 ) cr
" Snap.FTH Entry" stackCheck

2 0 WriteLED

vocabulary Snap immediate Snap definitions

: CreateSnapRecord dword: start dword: length

local	length 15 + $FFFFFFF0 and const dword: elen

	elen 2 shr elen + const dword: tlen
	tlen malloc handle.data const dword: image
(	cr ." Snap image created at " image hex. cr ...  )
	<sbuilds
	    {
		start			( 00	Start )
		elen			( 04	Len )
		image			( 08	Image )
		image elen + dup	( 0C	MaskMap )
		elen 3 shr +		( 10	DifferenceMap )
		0			( 14	DifferenceCount )
		0			( 18	SnapCount )
		0			( 1C	Trigger )
		ds>			( 20	SourceSegment default = DS )
	    } drop
	does>
;

$04 offset .SnapLength
$08 offset .SnapImage
$0C offset .SnapMask
$10 offset .SnapDiff
$14 offset .SnapDiff#
$18 offset .SnapCount
$1C offset .SnapTrigger
$20 offset .SnapSegment

: -hex. dword: value
	value wsplit const dword: high const dword: low
	high if
		high $100 xor $10 < if
			ascii x emit high nibble. low word. 6
		else
			high word. low word. 8
		endif
	else
		low word. 4
	endif
;

: SetSnapSegment word: segment address: SR	segment SR .SnapSegment _! ;

: SnapPrint address: SnapRecord word: DnotM

local	SnapRecord DnotM if .SnapDiff else .SnapMask endif @ dword: dptr
	0 dword: Count

	SnapRecord @ dword: sa
	0 dword: diff

	( SnapRecord .SnapImage @ )

	SnapRecord .SnapLength @ 0 do

		i 7 and 0= if
			dptr @ @ diff ! 
			dptr ++
		endif

		diff @ 1 and
		DnotM = if
		
			sa @ -hex. ( leaves chars used )
			Count ++
			DnotM if
				space 4+
				SnapRecord .SnapImage @ i + c@ byte.
			else
				1+
			endif
			80 swap / ( number of columns )
			Count @ swap /mod drop if space else cr endif
		endif


		diff @ 2/ diff ! 

		sa ++
	loop
	cr cr Count @ .
	DnotM if
		." changed bytes."
	else
		." masked bytes."
	endif
	cr
;

: SnapRecord. address: SR
	cr
	." SnapRecord " SR 4- nfa type cr
	." Start   " SR .SnapSegment	@ word. ascii : emit SR	@ hex. 2 spaces
	." Length  " SR .SnapLength	@ hex. 4 spaces
	." Image   " SR .SnapImage	@ hex. cr
	." Mask    " SR .SnapMask	@ hex. 7 spaces
	." Diff    " SR .SnapDiff	@ hex. 4 spaces
	." End     " SR .SnapDiff @ dup SR .SnapMask @ - + hex. cr
	." Diff#   " SR .SnapDiff#	@ hex. 7 spaces
	." Count   " SR .SnapCount	@ hex. 4 spaces
	." Trigger " SR .SnapTrigger	@ hex. cr
;

: Snap. address: SR dword: DnotM

	." MCC " SR 4- nfa type ."  #" SR .SnapCount @ . cr
	SR DnotM SnapPrint
;

: AutoSnap address: SR
	SR 1 MemSnap drop
	SR .SnapCount @ SR .SnapTrigger @ <= if
		SR 2 MemSnap drop
	endif
;

forth definitions

3 0 WriteLED

" Snap.FTH Exit" stackCheck
