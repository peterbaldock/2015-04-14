.( Compiling Register.FTH Version 8.06 ) cr
" Register.FTH Entry" stackCheck

StaticTop SetRegisterImage

0 variable eax
0 variable ebx
0 variable ecx
0 variable edx
0 variable edi
0 variable esi
0 variable ebp
0 variable ds
0 variable es
0 variable flags

eax constant ax		ebx constant bx
ecx constant cx		edx constant dx
edi constant di		esi constant si
ebp constant bp

ax constant al		ax 1+ constant ah
bx constant bl		bx 1+ constant bh
cx constant cl		cx 1+ constant ch
dx constant dl		dx 1+ constant dh

: rdump
	." EAX=" eax @ dword. ."      EDI=" edi @ dword. ."   CS=" cs> hex. cr
	." EBX=" ebx @ dword. ."      ESI=" esi @ dword. ."   DS=" ds w@ hex. ." (" ds> word. ." )" cr
	." ECX=" ecx @ dword. ."      EBP=" ebp @ dword. ."   ES=" es w@ hex. ." (" es> word. ." )" cr
	." EDX=" edx @ dword. ."       SS=" ss> hex. 6 spaces ." FS=" fs> hex. 	." GS=" gs> hex. cr
;

: fcall ah c! $21 int ;

" Register.FTH Exit" stackCheck
