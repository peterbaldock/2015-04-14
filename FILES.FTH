.( Compiling    FILES.FTH Version 8.00 ) cr
" FILES.FTH Entry" stackCheck
: DOScall fcall carry? if ax w@ else 0 then ;
: set_dta ( buffer - error_flag )
	dx w! ds> ds w! $01A fcall drop ;

: find_first address: fmask dword: len ( returns error_flag )
local	DOSpad $30 + const address: maskcpy

	DOSpad set_dta			( address to receive result )

	fmask c@ if
		fmask maskcpy len cmove	( copy up mask string )
		0 maskcpy len + _c!	( nul terminate )
		maskcpy
	else
		" *.*" 1+
	endif

	dx w! 		( point dx to mask )
	$37 cx w! 	( not volume labels )
	$4E fcall
	carry? if
		ax w@	( error flag )
	else
		0
	endif
;

: GetCurDrv $19 fcall carry? if 0 else al c@ 1+ endif ;
: GetCurDir dword: drv address: buffer

	buffer si w! 
	drv dl c!
	ds> ds w! 
	$47 fcall carry? if 
		" : GetCurDir " 1+ 6 ."abort ( " )
	endif
;
: GetCurrentFolder 
	GetCurDrv ascii @ + DOSpad _c! ascii : DOSpad 1+ _c! ascii \ DOSpad 2+ _c!
	GetCurDrv DOSpad 3 + GetCurDir
;

: find_next ( - error_flag )
	$4f fcall
	carry? if
		ax w@		( error flag )
	else
		0
	endif
;


decimal
with Text ( for move>asciiz )
: fexist	( filename - flag )

	DOSpad $20 + dup dx w! move>asciiz
	ds> ds w! 
	0 al c!
	$43 fcall
	carry? if
	  0
	else
	  cx w@ $8000 or
	endif
;
endwith
0 constant FROM_START
1 constant FROM_CURRENT
2 constant FROM_END
: fsetpointer  ( word: fh word: from dword: offset  - longposition )

	cx w! dx w! al c! bx w! 
	ax w@
	$42 fcall carry? if
		FALSE
	else
		dx w@ TRUE
	endif
;
: fsize address: FName

	FName count find_first 
	0= if
		DOSpad $1a + @
	else
		6 error _! 0
	endif

;
: fmakedirectory 1+ str>DOS1 dx w! ds> ds w!	$39 DOScall ;
: fdeletedirectory 1+ str>DOS1 dx w! ds> ds w! $3A DOScall ;
: fsetdirectory 1+ str>DOS1 dx w! ds> ds w!	$3B DOScall ;
: frename
	1+ str>DOS1 di w! 
	1+ str>DOS2 dx w! 
	ds> ds w! ds> es w! 
	$56 DOScall
;

: MakeDir word: path

	path 1+ fexist if
	  0
	else
	  path fmakedirectory
	endif
;

: getfile address: FileName 	( leaves es=segment, count on dstack )
local
	ds> >es FileName fsize const dword: flen ( only up to 64k )
	( ." getfile.fsize returned " flen . cr ... cr )
	flen if
		0 FileName str>DOS1 ( _DOSBuffer1 1 dump ... cr )
		fopen const word: fh ( ." getfile.fopen returns fh = " fh . ... cr )
		fh if
			( _FNameBuffer count type ."  successfully opened; handle=" fh hex. cr )
			flen 1+ DOSalloc ?dup if
				>es fh 0 flen fread
				( dup ." Bytes read = " hex. cr )
				0 over es:c!		( nul terminate )
			else
				"  : No memory for file buffer" 1+ 6 ."abort ( " )
			endif
			fh fclose drop
		endif
	else
	  0
	endif
;

: TypeFile address: FileName

local FileName getfile const dword: flen

	flen 0 = if    " : No data found" 1+ 6 ."abort ( " ) endif
	0 flen es:type
	DOSfree
;

: date.
local	base c@ const dword: oldBase
	10 base _c!
	32 /mod swap const word: day
	16 /mod swap const word: month
	1980 +	<# # # # # #> type ascii - emit
	month	<# # # #> type ascii - emit
	day	<# # # #> type

	oldBase base _c!
;
: time. word: time
	base c@ >r 10 base _c!
	time 5 shr 64 /mod <# # # #> type ascii : emit
	<# # # #> type ascii : emit
	time 1 shl 63 and <# # # #> type
	r> base _c! ;
: attr? DOSpad $15 + c@ and ;
: attr. dup space byte. space

	dup 01 and if ascii R else sp then emit
	dup 02 and if ascii H else sp then emit
	dup 04 and if ascii S else sp then emit
	dup $20 and if ascii A else sp then emit
	dup $c0 and
	if
	  dup $10 and if sp else ascii D then emit
	  dup $40 and if sp else ascii P then emit
	  dup $80 and if sp else ascii X then emit
	then
	drop
;



: dir.
	
	DOSpad $1E + c@ ascii . -
	if
	  $18 attr? if
	    ( DOSpad $1E + 1 dump ) DOSpad $1E + 0 es:ztype $0D swap - spaces drop
	    ." <DIR>     " 0 
	  else
	    DOSpad $1E + ascii .  es:ztype $0A swap - spaces
	    dup if
	      0 es:ztype 4 swap -
	    else
	      3
	    endif
	    spaces drop
	    DOSpad $1a + @
	    dup 8 dr. space space
	  then
	  DOSpad $18 + w@ date. space space
	  DOSpad $16 + w@ time.
	  -1 attr? attr.
	  cr.
	else
	  0 ( size )
	endif

;
: fastdir.

	DOSpad $1E + c@ ascii . -
	if
	  $18 attr? if
	    DOSpad $1E + dup lenz type space
	    ." <DIR>     " 0 
	  else
	    DOSpad $1E + ascii .  es:ztype $0A swap - spaces
	    dup if
	      0 es:ztype 4 swap -
	    else
	      3
	    endif
	    spaces drop
	    DOSpad $1a + @
	    dup 8 dr. space space
	  then
	  DOSpad $18 + w@ date. space space
	  DOSpad $16 + w@ time.
	  -1 attr? attr.
	  cr.
	else
	  0 ( size )
	endif

;
create Path 80 staticallot drop
: ListFolders address: mask dword: action

	ds> >es
	mask Path strcpy
	Path ascii \ rchar swap c! 
	" *.*" Path strcat
	Path count find_first
	0= if
	  begin
		$10 attr? if action execute drop endif
		find_next
	  until
	endif

;
: ListFiles address: mask ( mask - bytes, Count )
local 0 word: FCount

	ds> >es mask count find_first
	0= if
	  0
	  begin
		$18 attr? 0= if dir. + FCount ++ endif
		find_next
	  until
	endif
	FCount @

;

: dir
local	sp word const address: mask
	mask ['] dir. ListFolders
	mask ListFiles
	cr. space . ." files found, " . ." bytes total" cr.
	cr
;

: cmdLoad

(*	argc 1 > if
	  argc 1 do
	    i 4 * 0 argv + far@ _fload
	  loop
	then
*)
;
( 1 CommDump )
" FILES.FTH Exit" stackCheck
