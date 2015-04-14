.( Compiling Constant.fth Version 8.00 ) cr
-1 constant	TRUE
0  constant	FALSE

$01 constant	VOCABULARY
$02 constant	OBJECT
$08 constant	VIRTUAL
$10 constant	STOP_FIND
$80 constant	IMMEDIATE

1  constant 	BYTE
2  constant	WORD
4  constant	FLOAT
4  constant	DWORD

200 constant	MSG_PACKET_RCVD
201 constant	MSG_HOST_ACKNOWLEDGE
202 constant	MSG_HOST_BINARY
203 constant	MSG_HOST_COMMAND
204 constant	MSG_HOST_DATA
205 constant	MSG_HOST_ERROR
212 constant	MSG_HOST_LARGE
213 constant	MSG_HOST_MESSAGE

220 constant	MSG_KBD_CHAR
221 constant	MSG_KBD_LINE


1   constant	PIN_READY
2   constant	POUT_READY

11  constant	ERR_PARM1
12  constant	ERR_PARM2
13  constant	ERR_PARM3

$01  constant	USB_ACTIVE
$02  constant	LOCAL_IDLE
$04  constant	COMMS_IN_ON
$08  constant	COMMS_OUT_ON
$10  constant	CON_IN_EN
$20  constant	CON_OUT_EN
$40  constant	COMMS_IN_EN
$80  constant	COMMS_OUT_EN

$8000 constant	STEPPING

(* actuate constants *)
$0001	constant	amBACKLASH
$0002	constant	amVECTOR
$0004	constant	amSPEED
$0008	constant	amCONCURRENT
$0010	constant	amLIMIT
$0020	constant	amBUTTON
$0040	constant	amKEYBD
$0080	constant	amLIMITS
$0100	constant	amNO_ACC
$0200	constant	amLS_HIGH
$1000	constant	amNO_WAIT

amSPEED amBUTTON or amCONCURRENT or amBACKLASH or constant amSYRINGE
amSPEED amBUTTON or amCONCURRENT or amVECTOR or constant amAXIS
amAXIS 	constant amDOGLEG

0	constant X
1	constant Y
2	constant Z
3	constant V

1	constant	msAXES
2	constant	msSYRS
3	constant	msALL
