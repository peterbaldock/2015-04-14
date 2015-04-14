.( Compiling Pointers.fth Version 8.00 ) cr
" POINTERS.FTH Entry" stackCheck

: pointer	<_builds c, , does> dup c@ rot * swap 1+ @ + ;
: ptrsetsize    ' 4+ compiling? if [literal] compile c! else c! endif ; immediate
: ptrsetstart	' 5 + compiling? if [literal] compile w! else w! endif ; immediate
: ptr+		' 5 + compiling? if [literal] compile +! else +! endif ; immediate
: SetTableCount dword: count
local ' const dword: pfa
	pfa w@ count 1- * ( # bytes )
	pfa 4+ _w!
;
: SetTableLength dword: len
local ' const address: pfa
	len pfa w@ -
	pfa 4+ _w! 
;
: SetSTableCount dword: count
local ' const dword: pfa
	pfa w@ count 1- * ( # bytes )
	pfa 4+ _w!
;
: SetSTableLength dword: len
local ' const address: pfa
	len pfa w@ -
	pfa 4+ _w! 
;
(*
: SetTableLength dword: len
	." Stack in SetTableLength=" .s cr
local ' const address: pfa
	." Stack after Find in SetTableLength=" .s cr
	len pfa
	." Stack after len pfa=" .s cr
	 w@ -
	." Stack should have upper bound offset" .s cr
	pfa 4+ w! 
	." Stack should be empty" .s cr
;
*)
: @tea
	compiling? if
		' [literal] compile GetElementAddress
	else
		' GetElementAddress
	endif
; immediate

: me current @ @ 8+ compiling? if [literal] endif ; immediate

" POINTERS.FTH Exit" stackCheck
