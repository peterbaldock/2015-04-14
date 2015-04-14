" LEDS.FTH Entry" stackCheck
.( Compiling     LEDs.fth Version 6.00 ) cr
( noisy )
vocabulary LEDs
with LEDs +definitions

8 BYTE stack _led0
8 BYTE stack _led1
8 BYTE stack _led2
8 BYTE stack _led3

12 ?stack
DWORD table LEDStack { _led0 _led1 _led2 _led3 } SetTableLength LEDStack
14 ?stack
: PushLED word: BoardNo
16 ?stack
	BoardNo ReadLED BoardNo LEDStack push
18 ?stack
;
: PopLED word: BoardNo
	BoardNo LEDStack pop
	BoardNo WriteLED
;
1 0 WriteLED 0 1 WriteLED $FF 2 WriteLED

: LEDRefresh word: b b ReadLED  dup 1+ b WriteLED 1 ms b WriteLED ;

0 LEDRefresh
1 LEDRefresh
2 LEDRefresh
3 LEDRefresh

-definitions

: PushLEDs 4 0 do i PushLED loop ;
: PopLEDs 4 0 do i PopLED loop ;

: LED++ 0 ReadLED 1+ 0 WriteLED ;

: LEDfload dword: Index

	PushLEDs
	Index 2 r. space
	Index 2 WriteLED 0 0 WriteLED
	fload
	PopLEDs
;

endwith

" LEDS.FTH Exit" stackCheck
quiet
