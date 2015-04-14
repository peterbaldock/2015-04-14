.( Compiling     HELP.FTH Version 8.00 ) cr
: _help address: subject

subject 1+ c@ 0= if
	cr
	." Help usage : help <topic>    //<topic>=filename without extension" cr
	." Help files : " cr 
	cr
	" *.hlp" ListFiles exit
endif

cls cr subject " %s.hlp" format TypeFile
;

: help sp word _help quit ;
