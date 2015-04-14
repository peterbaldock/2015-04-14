.( Compiling     Dump.FTH Version 8.00 ) cr
" Dump.FTH Entry" stackCheck
: me.name [compile] me compile nfa ; immediate
: me.identify [compile] me compile nfa compile type ; immediate

: heapwalk

	$6000 >es
	1
	begin
	  dup . cr 1+
	  0 2 dump
	  2 es:@ dup 0>
	while
	  es> 1+ + >es
	repeat
	drop drop
;
" Dump.FTH:92" stackCheck
(*
: trace
	page wc@ >r $7w display	( save active page and display page 7 )
	dup hex. ." ->" w@ dup hex. ( print next cell and execution address )
	2+ nfa16 $0fw and	( and convert execution address to nfa )
	$10w over w- >r type r>	( calculate blank field length and type name)
	spaces			( print blank field )

	." Stack: " .s		( print stack contents )
	waitKey $ffw and $1Bw =	( wait for ESC )
	if
	  r> display quit
	then
	cr
	r> page c!
;
: setdebug	['] trace 2- (debug) w! ;

setdebug
*)
: p.			( From HOOKS.FTH )
	." Packet " rdup hex.
	r c@ ." > Type=" emit
	r 1+ c@ ."  ID=" .
	r 2+ c@ dup ."  Length=" . cr
	?dup
	if
	  $16 / 1+ r> 2+ 1+ swap dump cr
	else
	  rdrop
	then
;
: fdump dword: adr dword: lines

	lines 0 do
		i 16 * adr + dup hex.
		4 0 do
			dup i 4* + f@ swap
		loop
		drop
		" %12f %12f %12f %12f%<" format count type
	loop
;
64 ?stack

" Dump.FTH Exit" stackCheck
(* .( Line 193 ) .s cr ... *)
