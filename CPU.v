/*Summary

Part1
Stage 1
The input and output CPU module and the top level module myComputer were defined for later use. 
Stage 2
The Synchroniser and Debounce module was created in AUXMOD.v.  
Stage 3
This stage checks the correctness of input output assignment of CPU and myComputer by setting when reset=1, Dout=0, when reset=0, all pins of GPO equals to 1. 
Stage 4
Created module Disp2cNum, DispHex, DispDec 
Stage 5
Step 1 utilise a counter to slow down the 50MHz clock, by only “go” (do calculations) when the counter is finished counting. 
Step 2, 3 introduced machine codes that tell the CPU what to do. 
Stage 6
Assigned SW8 to implement the turbo feature, which is just bypassing the counter and use the 50MHZ clock. 
Stage 7
Implementation of MOV command group. Functions are introduced in this stage (get_number, get_location). 
Stage 8
Implemented the ACC command group to do calculations and check argrimatic overflow. 
Stage 9
Implemented JMP command group to jump to a specific state under certain condition. 
Stage 10
If one bit of the RFLAG register is HIGH, jump to a specific address. After this, turn off that bit of the RFLAG register. Function regarding to command group MOV and JMP is implmemted in this stage. 
Stage 11
Assigned Flag registers to debug output and created set_bit and clr_bit function to set or clear a certain bit in the register. 
Stage 12
Synchronised all inputs from switches and buttons. Added falling edge detection for push buttons to prevent multiple times assignment to its corresponding register. 
Part2
Implemented a program of RPN calculator.

*/
`include "CPU.vh"

// CPU Module

module CPU(
	Din,Sample,Btns,Clock,Reset,Turbo,Dout,Dval,GPO,Debug,IP
);
input [7:0] Din;
input Sample;
input [2:0] Btns;
input Clock;
input Reset;
input Turbo;
output [7:0] Dout;
output Dval;
output [5:0] GPO;
output [3:0] Debug;
output reg [7:0] IP;
wire [7:0] din_safe;
genvar k;
generate
	for(k = 0; k<= 7; k = k+1) begin: sync
		Synchroniser syncs (.clk(Clock),.signal(Din[k]),.synchronized_signal(din_safe[k]));
	end
endgenerate


wire [3:0] pb_safe;
Synchroniser Sample_safe (.clk(Clock),.signal(Sample),.synchronized_signal(pb_safe[3]));
Synchroniser Btn2_safe (.clk(Clock),.signal(Btns[2]),.synchronized_signal(pb_safe[2]));
Synchroniser Btn1_safe (.clk(Clock),.signal(Btns[1]),.synchronized_signal(pb_safe[1]));
Synchroniser Btn0_safe (.clk(Clock),.signal(Btns[0]),.synchronized_signal(pb_safe[0]));

wire turbo_safe;
Synchroniser tbo(Clock,Turbo,turbo_safe);

genvar i;
wire [3:0] pb_activated;
generate
	for(i = 0; i<=3;i = i+ 1) begin: pb
		DetectFallingEdge dfe (Clock,pb_safe[i],pb_activated[i]);
	end
endgenerate
//Registers
reg [7:0] Reg [0:31];

//Use these to Read the Special Registers
wire [7:0] Rgout = Reg[29];
wire [7:0] Rdout = Reg[30];
wire [7:0] Rflag = Reg[31];
//Use these to write to the Flags and Din Registers
`define RFLAG Reg[31]
`define RDINP Reg[28]
`define RSTACK1 Reg[0]
`define RSTACK2 Reg[1]
`define RSTACK3 Reg[2]
`define RSTACK4 Reg[3]
`define RSTACKFLAG Reg[4]
//connect certain registers to the external world
assign Dout = Rdout;
assign GPO = Rgout[5:0];
// Instruction Cycle
wire [34:0] instruction;
wire [3:0] cmd_grp = instruction[34:31];
wire [2:0] cmd = instruction[30:28];
wire [1:0] arg1_typ = instruction[27:26];
wire [7:0] arg1 = instruction[25:18];
wire [1:0] arg2_typ = instruction[17:16];
wire [7:0] arg2 = instruction[15:8];
wire [7:0] addr = instruction[7:0];

integer j;// create in stage 12 step 3

function [7:0] get_number;
	input [1:0] arg_type;
	input [7:0] arg;
	begin
		case (arg_type)
			`REG: get_number = Reg[arg[5:0]];
			`IND: get_number = Reg[Reg[arg[5:0]][5:0]];
			default: get_number = arg;
		endcase
	end
endfunction
function [5:0] get_location;
	input [1:0] arg_type;
	input [7:0] arg;
	begin
		case(arg_type)
			`REG: get_location = arg[5:0];
			`IND: get_location = Reg[arg[5:0]][5:0];
			default: get_location = 0;
		endcase
	end
endfunction









//Clock circuitry (250ms cycle)
reg [27:0] cnt;
localparam CntMax = 150000000/4;
reg [7:0] cnum;
reg [7:0] cloc;
reg [15:0] word;
reg signed [15:0] s_word;
reg cond;
always@(posedge Clock)
	cnt <= (cnt == CntMax) ? 26'b0 : cnt + 26'b1;

	//Synchronise CPU operations to when cnt == 0
	wire go = !Reset && ((cnt == 0)||turbo_safe);
	
	// Instruction cycle - instruction cycle block
	always @(posedge Clock) begin
		//Process Instruction
		if(go) begin 
			IP <= IP + 8'b1;// Default action is increment IP
			
			case(cmd_grp)
				`MOV: 
				 begin
					cnum = get_number(arg1_typ,arg1);
					case(cmd)
						`SHL:begin
							`RFLAG[`SHFT]<=cnum[7];
							if(cnum == 8'b0) cnum = {cnum[6:0],1'b1};
							else cnum = {cnum[6:0],1'b0};
						end
						`SHR: begin
							`RFLAG[`SHFT] <=cnum[0];
							cnum = {1'b0,cnum[7:1]};
						end
					endcase
					Reg[get_location(arg2_typ,arg2)]<=cnum;
		       end
				`ACC: begin
					cnum = get_number(arg2_typ,arg2);
					cloc = get_location(arg1_typ,arg1);
					case(cmd)
						`UAD: word = Reg[cloc] + cnum;//unsigned addition
						`SAD: s_word = $signed(Reg[cloc]) + $signed(cnum);//signed addtion
						`UMT: word = Reg[cloc] * cnum;//Unsigned Multiplication
						`SMT: s_word = $signed(Reg[cloc]) * $signed(cnum) ;// signed multiplication
						`AND: word = Reg[cloc] & cnum;//bitwise and
						`OR:  word = Reg[cloc] | cnum ;//bitwise or
						`XOR: word = Reg[cloc] ^ cnum;//bitwise xor
					endcase
					if(cmd[2] == 0) begin
						if(cmd[0] == 0) begin
							cnum = word[7:0];
							`RFLAG[`OFLW] <= (word > 255);
						end
						else begin
							cnum = s_word[7:0];
							`RFLAG[`OFLW] <=(s_word > 127 || s_word < -128);
						end
					Reg[cloc] <= cnum;
					end else begin
					Reg[cloc] <= word[7:0];
					end
					end
				`JMP:begin
					case(cmd)
					`UNC: cond = 1;
					`EQ:  cond = (get_number(arg1_typ,arg1) == get_number(arg2_typ,arg2));
					`ULT: cond = (get_number(arg1_typ,arg1) < get_number(arg2_typ,arg2));
					`SLT: cond = ($signed(get_number(arg1_typ,arg1)) < $signed(get_number(arg2_typ,arg2)));
					`ULE: cond = (get_number(arg1_typ,arg1) <= get_number(arg2_typ,arg2));
					`SLE: cond = ($signed(get_number(arg1_typ,arg1)) <= $signed(get_number(arg2_typ,arg2)));
					default: cond = 0;
					endcase
					if(cond) IP<=addr;
				end
				// The ATC Command Group is designed for reading the status of the push buttons. 
				// Nevertheless, we allow it to be applied to any bit of the Flag Register
				
				`ATC:begin
					cond = `RFLAG[cmd];
					`RFLAG[cmd] <= 0;
					if(cond) IP <=addr;
				end
					
		// For now, we just assumed a PUR move, with arg1 a number and arg2 a register!
			endcase
		end
		if(Reset) begin 
			IP <= 8'b0;
			`RFLAG <= 0;
		   Reg[`GOUT] <= 0; 
		end
		else begin
			for(j = 0;j<=3;j = j+1)
				if(pb_activated[j])`RFLAG[j]<=1;
			if(pb_activated[3]) `RDINP <= din_safe;
		end
	end
	
	
	
	
//Program memory

AsyncROM Pmem(IP,instruction);
assign Dval = Rflag[`DVAL];
//Debugging assignments - you can change these to suit yourself
assign Debug[3] = Rflag[`SHFT];
assign Debug[2] = Rflag[`OFLW];
assign Debug[1] = Rflag[`SMPL];
assign Debug[0] = go;

endmodule
