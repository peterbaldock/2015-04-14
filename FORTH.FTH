.( FORTH.FTH for FLASH-FORTH kernel - Douglas Instruments +44 14 88 64 90 90 ) cr
.( Compiling    Forth.fth Version 8.00 ) cr
" FORTH.FTH Entry" stackCheck
safe

forth definitions decimal ds> >es

fload diagnose.fth
fload constant.fth
fload register.fth
fload DOS.fth
fload text.fth
fload numbers.fth
fload dumpmem.fth
fload pointers.fth
fload stacks.fth
fload LEDs.fth 		( allows LED indication of progress )

1	LEDfload hooks.fth	LED++
2	LEDfload dump.fth	LED++
3	LEDfload files.fth	LED++
4	LEDfload comms.fth	LED++
5	LEDfload list.fth	LED++
6	LEDfload snap.fth	LED++
7	LEDfload version.fth	LED++
8	LEDfload help.fth	LED++
10	LEDfload MCC-cfg.fth	LED++
12	LEDfload USD-cfg.fth	LED++
13	LEDfload XYZ-cfg.fth	LED++
14	LEDfload stepper.fth	LED++
15	LEDfload position.fth	LED++
16	LEDfload USDMoves.fth	LED++
17	LEDfload XYZMoves.fth	LED++
18	LEDfload dumphard.fth	LED++
19	LEDfload moves.fth	LED++
20	LEDfload obsolete.fth	LED++
21	LEDfload hardware.fth	LED++
22	LEDfload startup.fth	LED++
( 23	LEDfload test.fth	LED++ )

info

99	LEDfload debug.fth	LED++
0 0 WriteLED 0 1 WriteLED 0 2 WriteLED
( 0 LEDRefresh 1 LEDRefresh 2 LEDRefresh  )

" FORTH.FTH Exit" stackCheck
