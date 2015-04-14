.( Compiling  Version.fth Version)
string version "8.09 - April 2015     " version (version) _! 
: hedgehog version count type ;
space hedgehog cr

(*
2015-04-14	8.09 #	XYZMOVES.FTH RezeroLS corrections to calculation of number of cycles missed.
2015-04-10	8.08 +	FORTH-32.EXE upload; +FileReadEx
2015-03-25	8.07 #	XYZMOVES.FTH corrections to RezeroLS
2015-03-11	8.06 +	USB. ~Registers now in extended memory
2015-03-03	8.05 +	Heap vocabulary, Dump vocabulary.
2015-03-02	8.04 +	Memory manager (malloc vs. DOSalloc).
2015-02-25	8.03 +	Multiple context vocabularies, with and endwith
2015-02-06	8.02 #	All working in extended memory.
2015-01-06	8.01 ~	FORTH-32.EXE STOP button reenabled in CTRL.ASM
2014-12-16	8.00 +	First fully operational32-bit version.
*)
