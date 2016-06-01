/*`include "CPU.vh"

// Asynchronous ROM (Program Memory)

module AsyncROM(
	// You fill this in... 
	input [7:0] Addr, output reg [34:0] data
);
parameter INIT= 4'b0000, PUSH = 4'b0010, POP = 4'b0011, ADD = 4'b0100, MULT = 4'b0110, OVERFLOW = 4'b1000, ARITHOFLW = 4'b1001;
parameter STEP0 = 4'b0000, STEP1 = 4'b0001, STEP2 = 4'b0010, STEP3 = 4'b0011, STEP4 = 4'b0100, STEP5 = 4'b0101, STEP6 = 4'b0110, STEP7 = 4'b0111, STEP8 = 4'b1000,
STEP9 = 4'b1001, STEP10 = 4'b1010, STEP11 =4'b1011, STEP12 = 4'b1100;
parameter WAIT1 = {INIT,STEP7}, WAIT2 = {INIT,STEP8}, WAIT3 = {INIT,STEP9},WAIT4 = {INIT,STEP10},WAIT5 = {INIT,STEP11}, WAIT6 = {INIT,STEP12};
always@(Addr)
	case(Addr)
		
		//{INIT,STEP0}: data = set(`GOUT,`N8); // clear LEDRs
		{INIT,STEP0}: data = set(`DOUT,`N8); // clear outputs
		{INIT,STEP1}: data = set(`STACK1,`N8); // clear stacks 
		{INIT,STEP2}: data = set(`STACK2,`N8);
		{INIT,STEP3}: data = set(`STACK3,`N8);
		{INIT,STEP4}: data = set(`STACK4,`N8);
		{INIT,STEP5}: data = set(`STACKF,`N8);
		
		WAIT1: data = clr_bit(`FLAG,`DVAL);// turn off the display
		WAIT2: data = atc(3'd3,{PUSH,STEP0});// if sample button is pushed, go to "push" operations
		WAIT3: data = atc(3'd2,{POP,STEP0});// if pop button is pressed, go to "pop" operations
		WAIT4: data = atc(3'd1,{ADD,STEP0});// if add button is pressed, go to "add" operations
		WAIT5: data = atc(3'd0,{MULT,STEP0});// if mult button is pressed, go to "mult" operations
		WAIT6: data = jmp(WAIT2);// if nothing is happening, keep waiting
		//WAIT6: data = `NOP;
		// push

		// move down the stacks, discard the value in stack4
		{PUSH,STEP0}: data = move(`STACK3,`STACK4);//8'b0010_0000 
		//8'b0000_1001: data = move(`STACK3,`STACK4);//9
		{PUSH,STEP1}: data = move(`STACK2,`STACK3);//8'b0010_0001
		//8'b0000_1010: data = move(`STACK2,`STACK3);//10
		{PUSH,STEP2}: data = move(`STACK1,`STACK2);//8'b0010_0010
		//8'b0000_1011: data = move(`STACK1,`STACK2);
		// move the number in the input pins to stack1
		{PUSH,STEP3}: data = move(`DINP,`STACK1);//8'b0010_0011
		//8'b0000_1100: data = move(`DINP,`STACK1);
		// move the number in stack1 to register which stores the output numbers
		{PUSH,STEP4}: data = move(`STACK1,`DOUT);//8'b0010_0100
		//8'b0000_1101: data = move(`STACK1,`DOUT);
		{PUSH,STEP5}: data = set_bit(`FLAG,`DVAL);
		{PUSH,STEP6}: data = jmp_on_eq(`STACKF,8'd8,{OVERFLOW,STEP0});
		
		{PUSH,STEP7}: data = left_shift(`STACKF,`STACKF);
		{PUSH,STEP8}: data = move(`STACKF,`GOUT);
		//{PUSH,STEP8}: data = jmp_on_eq(`STACKF,8'd8,{OVERFLOW,STEP0});
		//{PUSH,STEP9}: data = clr_bit(`GOUT,3'd4);
		//{PUSH,STEP10}: data = clr_bit(`GOUT,3'd5);
        //{PUSH,STEP9}: data = jmp(WAIT1);
		  {PUSH,STEP9}: data = jmp(WAIT2);
        //pop
        {POP,STEP0}: data = jmp_on_eq(`STACKF,8'd0,{WAIT1});
        {POP,STEP1}: data = move(`STACK2,`STACK1);
        {POP,STEP2}: data = move(`STACK3,`STACK2);
        {POP,STEP3}: data = move(`STACK4,`STACK3);
        {POP,STEP4}: data = move(`STACK1,`DOUT);
        {POP,STEP5}: data = set_bit(`FLAG,`DVAL);
        {POP,STEP6}: data = right_shift(`STACKF,`STACKF);
		  {POP,STEP7}: data = move(`STACKF,`GOUT);
        {POP,STEP8}: data = clr_bit(`GOUT,3'd4);
        {POP,STEP9}: data = clr_bit(`GOUT,3'd5);
        //{POP,STEP10}: data = jmp(WAIT1);
		  {POP,STEP10}:data = jmp(WAIT2);
        //overflow
        {OVERFLOW,STEP0}: data = clr_bit(`GOUT,3'd5);
        {OVERFLOW,STEP1}: data = set_bit(`GOUT,3'd4);
        //{OVERFLOW,STEP2}: data = jmp(WAIT1);
		  {OVERFLOW,STEP2}: data = jmp(WAIT2);
        //add
        {ADD,STEP0}: data = jmp_on_eq(`STACKF,8'b0000_0001, WAIT2);
		  //{ADD,STEP0}: data = jmp_on_eq(`STACKF,8'b0000_0001,WAIT1);
        {ADD,STEP1}: data = signed_addition(`STACK1,`STACK2);// {`ACC,`SAD,`REG,`STACK1,`REG,`STACK2,`N8};
        {ADD,STEP2}: data = move(`STACK3,`STACK2);
        {ADD,STEP3}: data = move(`STACK4,`STACK3);
        {ADD,STEP4}: data = move(`STACK1,`DOUT);
        {ADD,STEP5}: data = set_bit(`FLAG,`DVAL);
		  {ADD,STEP6}: data = right_shift(`STACKF,`STACKF);
		  {ADD,STEP7}: data = move(`STACKF,`GOUT);
		  {ADD,STEP8}: data = clr_bit(`GOUT,3'd4);
        {ADD,STEP9}: data = atc(`OFLW,{ARITHOFLW,STEP0});
		  
		 // {ADD,STEP8}: data = set_bit(`GOUT,3'd5);//Set GOUT ARITHMETIC OVERFLOW TO 1 IF THERE IS ONE
		  //{ADD,STEP6}: data = set_bit(`GOUT,3'd5);//Set GOUT ARITHMETIC OVERFLOW TO 1 IF THERE IS ONE
        //{ADD,STEP7}: data = right_shift(`STACKF,`STACKF);
		  //{ADD,STEP8}: data = move(`STACKF,`GOUT);
        //{ADD,STEP9}: data = clr_bit(`GOUT,3'd4);
        //{ADD,STEP9}: data = jmp(WAIT1); 
		  {ADD,STEP10}: data = jmp(WAIT2);
        //multiplication
        {MULT,STEP0}: data = jmp_on_eq(`STACKF,8'b0000_0001,WAIT2);
		  //{MULT,STEP0}: data = jmp_on_eq(`STACKF,8'b0000_0001,WAIT1);
        {MULT,STEP1}: data = signed_multiplication(`STACK1,`STACK2);//{`ACC, `SMT, `REG, `STACK1, `REG, `STACK2, `N8};
        {MULT,STEP2}: data = jmp({ADD,STEP2});
		  {ARITHOFLW,STEP0}: data = set_bit(`GOUT,3'd5);
		  {ARITHOFLW,STEP1}: data = jmp({ADD,STEP10});
		default: data = 35'b0;
	endcase
	function [34:0] set;
		input [7:0] reg_num;
		input [7:0] value;
		set = {`MOV,`PUR,`NUM,value,`REG,reg_num,`N8};
	endfunction
	function [34:0] move;
		input [7:0] src_reg;
		input [7:0] dst_reg;
		move = {`MOV,`PUR,`REG,src_reg,`REG,dst_reg,`N8};
	endfunction
	function [34:0] jmp;
		input [7:0] addr;
		jmp = {`JMP,`UNC,`N10,`N10,addr};
	endfunction
	function [34:0] atc;
		input [2:0] bt;
		input [7:0] addr;
		atc = {`ATC, bt, `N10, `N10, addr};
	endfunction
	function [34:0] acc_rn;
		input [2:0] op;
		input [7:0] reg_num;
		input [7:0] value;
		acc_rn = {`ACC, op, `REG, reg_num, `NUM, value, `N8};
	endfunction
	function [34:0] set_bit;
		input [7:0] reg_num;
		input [2:0] bt;
		set_bit = {`ACC,`OR,`REG,reg_num,`NUM,8'b1<<bt,`N8};
	endfunction
	function [34:0] clr_bit;
		input [7:0] reg_num;
		input [2:0] b;
		clr_bit = {`ACC, `AND,`REG,reg_num,`NUM,~(8'b1<<b),`N8};
	endfunction
	// created by myself
	function [34:0] left_shift;
		input [7:0] src_reg_name;
		input	[7:0] dst_reg_name;
		left_shift = {`MOV,`SHL,`REG,src_reg_name,`REG,dst_reg_name,`N8};
	endfunction
	function [34:0] right_shift;
		input [7:0] src_reg_name;
		input [7:0] dst_reg_name;
		right_shift = {`MOV,`SHR,`REG,src_reg_name,`REG,dst_reg_name,`N8};
	endfunction
	function [34:0] jmp_on_eq;
		input [7:0] reg_name;
		input [7:0] number;
		input [7:0] addr;
		jmp_on_eq = {`JMP,`EQ,`REG,reg_name,`NUM,number,addr};
	endfunction
	function [34:0] signed_addition;
        input [7:0] dst_reg_name;
        input [7:0] reg_name;
        signed_addition = {`ACC,`SAD,`REG,`STACK1,`REG,`STACK2,`N8};
    endfunction
    function [34:0] signed_multiplication;
        input [7:0] reg_name1;
        input [7:0] reg_name2;
        signed_multiplication = {`ACC, `SMT, `REG, reg_name1, `REG, reg_name2, `N8};
    endfunction
endmodule
*/
`include "CPU.vh"

// Asynchronous ROM (Program Memory)

module AsyncROM(
	// You fill this in... 
	input [7:0] Addr, output reg [34:0] data
);
parameter INIT= 4'b0000, PUSH = 4'b0010, POP = 4'b0011, ADD = 4'b0100, MULT = 4'b0110, 
OVERFLOW = 4'b1000, ARITHOFLW = 4'b1001;
parameter STEP0 = 4'b0000, STEP1 = 4'b0001, STEP2 = 4'b0010, STEP3 = 4'b0011, STEP4 = 4'b0100, 
STEP5 = 4'b0101, STEP6 = 4'b0110, STEP7 = 4'b0111, STEP8 = 4'b1000,
STEP9 = 4'b1001, STEP10 = 4'b1010, STEP11 =4'b1011, STEP12 = 4'b1100;
parameter WAIT1 = {INIT,STEP7}, WAIT2 = {INIT,STEP8}, WAIT3 = {INIT,STEP9},
WAIT4 = {INIT,STEP10},WAIT5 = {INIT,STEP11}, WAIT6 = {INIT,STEP12};
localparam ONELEFT = 8'd1, EMPTY = 8'd0, FULL = 8'd8;
localparam PUSHBT = 3'd3, POPBT = 3'd2,ADDBT = 3'd1, MULTBT = 3'd0;
localparam STACKOFLWBIT = 3'd4, ARITHOFLWBIT = 3'd5;
always@(Addr)
	case(Addr)
		{INIT,STEP0}: data = set(`DOUT,`N8); // clear outputs
		{INIT,STEP1}: data = set(`STACK1,`N8); // clear stacks 
		{INIT,STEP2}: data = set(`STACK2,`N8);
		{INIT,STEP3}: data = set(`STACK3,`N8);
		{INIT,STEP4}: data = set(`STACK4,`N8);
		{INIT,STEP5}: data = set(`STACKF,`N8);
		
		WAIT1: data = clr_bit(`FLAG,`DVAL);// turn off the display
		WAIT2: data = atc(PUSHBT,{PUSH,STEP0});// if sample button is pushed, go to "push" operations
		WAIT3: data = atc(POPBT,{POP,STEP0});// if pop button is pressed, go to "pop" operations
		WAIT4: data = atc(ADDBT,{ADD,STEP0});// if add button is pressed, go to "add" operations
		WAIT5: data = atc(MULTBT,{MULT,STEP0});// if mult button is pressed, go to "mult" operations
		WAIT6: data = jmp(WAIT2);// if nothing is happening, keep waiting
		// PUSH:
		// When released, the number represented by the switches will be pushed onto the stack, 
		// and hence be displayed on the 7-segment display.
		
		// move down the stacks
		{PUSH,STEP0}: data = move(`STACK3,`STACK4);
		{PUSH,STEP1}: data = move(`STACK2,`STACK3);
		{PUSH,STEP2}: data = move(`STACK1,`STACK2);
		// move the number in the input pins to stack1
		{PUSH,STEP3}: data = move(`DINP,`STACK1);
		// move the number in stack1 to register which stores the output numbers
		{PUSH,STEP4}: data = move(`STACK1,`DOUT);
		// turn on the display
		{PUSH,STEP5}: data = set_bit(`FLAG,`DVAL);
		// if there are more than 4 numbers in the stack, jump to OVERFLOW section
		{PUSH,STEP6}: data = jmp_on_eq(`STACKF,FULL,{OVERFLOW,STEP0});
		{PUSH,STEP7}: data = left_shift(`STACKF,`STACKF);
		{PUSH,STEP8}: data = move(`STACKF,`GOUT);
		// jump back to wait section
		{PUSH,STEP9}: data = jmp(WAIT2);
		
      //POP:
		// STACK1 is discarded and 
		// the rest of the stack moves down: STACK1 <- STACK2 <- STACK3 <- STACK4 <- “empty”
		
		// jump to wait if there is no number in the stack
        {POP,STEP0}: data = jmp_on_eq(`STACKF,EMPTY,{WAIT2});
		// clear the overflow LEDs
		{POP,STEP1}: data = clr_bit(`GOUT,STACKOFLWBIT);
		{POP,STEP2}: data = clr_bit(`GOUT,ARITHOFLWBIT);
		// move up the stacks, discard the number in STACK1 
		{POP,STEP3}: data = move(`STACK2,`STACK1);
		{POP,STEP4}: data = move(`STACK3,`STACK2);
		{POP,STEP5}: data = move(`STACK4,`STACK3);
		{POP,STEP6}: data = right_shift(`STACKF,`STACKF);
		{POP,STEP7}: data = move(`STACKF,`GOUT);
		// turn of the display
		{POP,STEP8}: data = clr_bit(`FLAG,`DVAL);
		// jump to  wait if there is no number after the pop operation
		{POP,STEP9}: data = jmp_on_eq(`STACKF,EMPTY,{WAIT2});
		// move the number in STACK1 to the output
		{POP,STEP10}: data = move(`STACK1,`DOUT);
		// turn on the display
		{POP,STEP11}: data = set_bit(`FLAG,`DVAL);
		// jump back to wait
		{POP,STEP12}: data = jmp(WAIT2);
		
      // STACKOVERFLOW: Turning on the 5th LED when there is a stack overflow
        {OVERFLOW,STEP0}: data = clr_bit(`GOUT,ARITHOFLWBIT);
        {OVERFLOW,STEP1}: data = set_bit(`GOUT,STACKOFLWBIT);
		{OVERFLOW,STEP2}: data = jmp(WAIT2);
		
      // ADDITION: stack[0] = stack[0] + stack[1]; stack[1] <- stack[2] <- stack[3] <- “empty”.
	   //	The addition is signed addition.
		
		// jump back to wait if there is only one number in the stack
		{ADD,STEP0}: data = jmp_on_ule(`STACKF,ONELEFT,WAIT2);
		  //{ADD,STEP0}: data = jmp_on_eq(`STACKF,8'b0000_0001,WAIT1);
      {ADD,STEP1}: data = signed_addition(`STACK1,`STACK2);
      {ADD,STEP2}: data = move(`STACK3,`STACK2);
      {ADD,STEP3}: data = move(`STACK4,`STACK3);
      {ADD,STEP4}: data = move(`STACK1,`DOUT);
      {ADD,STEP5}: data = set_bit(`FLAG,`DVAL);
		{ADD,STEP6}: data = right_shift(`STACKF,`STACKF);
		{ADD,STEP7}: data = move(`STACKF,`GOUT);
		{ADD,STEP8}: data = clr_bit(`GOUT,STACKOFLWBIT);
      {ADD,STEP9}: data = atc(`OFLW,{ARITHOFLW,STEP0});
		{ADD,STEP10}: data = jmp(WAIT2);
        
		  
		// MULTIPLICATION: 
		{MULT,STEP0}: data = jmp_on_ule(`STACKF,ONELEFT,WAIT2);
      {MULT,STEP1}: data = signed_multiplication(`STACK1,`STACK2);//{`ACC, `SMT, `REG, `STACK1, `REG, `STACK2, `N8};
		// the rest of the steps in MULTIPLICAITON are the same as those in addition
      {MULT,STEP2}: data = jmp({ADD,STEP2});
		
		// ARITHMETIC OVERFLOW
		{ARITHOFLW,STEP0}: data = set_bit(`GOUT,ARITHOFLWBIT);
		{ARITHOFLW,STEP1}: data = jmp({ADD,STEP10});
		
		default: data = `NOP;
	endcase
	function [34:0] set;
		input [7:0] reg_num;
		input [7:0] value;
		set = {`MOV,`PUR,`NUM,value,`REG,reg_num,`N8};
	endfunction
	function [34:0] move;
		input [7:0] src_reg;
		input [7:0] dst_reg;
		move = {`MOV,`PUR,`REG,src_reg,`REG,dst_reg,`N8};
	endfunction
	function [34:0] jmp;
		input [7:0] addr;
		jmp = {`JMP,`UNC,`N10,`N10,addr};
	endfunction
	function [34:0] atc;
		input [2:0] bt;
		input [7:0] addr;
		atc = {`ATC, bt, `N10, `N10, addr};
	endfunction
	function [34:0] acc_rn;
		input [2:0] op;
		input [7:0] reg_num;
		input [7:0] value;
		acc_rn = {`ACC, op, `REG, reg_num, `NUM, value, `N8};
	endfunction
	function [34:0] set_bit;
		input [7:0] reg_num;
		input [2:0] bt;
		set_bit = {`ACC,`OR,`REG,reg_num,`NUM,8'b1<<bt,`N8};
	endfunction
	function [34:0] clr_bit;
		input [7:0] reg_num;
		input [2:0] b;
		clr_bit = {`ACC, `AND,`REG,reg_num,`NUM,~(8'b1<<b),`N8};
	endfunction
	// created by myself
	function [34:0] left_shift;
		input [7:0] src_reg_name;
		input	[7:0] dst_reg_name;
		left_shift = {`MOV,`SHL,`REG,src_reg_name,`REG,dst_reg_name,`N8};
	endfunction
	function [34:0] right_shift;
		input [7:0] src_reg_name;
		input [7:0] dst_reg_name;
		right_shift = {`MOV,`SHR,`REG,src_reg_name,`REG,dst_reg_name,`N8};
	endfunction
	function [34:0] jmp_on_eq;
		input [7:0] reg_name;
		input [7:0] number;
		input [7:0] addr;
		jmp_on_eq = {`JMP,`EQ,`REG,reg_name,`NUM,number,addr};
	endfunction
	function [34:0] jmp_on_ule;
		input [7:0] reg_name;
		input [7:0] number;
		input [7:0] addr;
		jmp_on_ule = {`JMP,`ULE,`REG,reg_name,`NUM,number,addr};
	endfunction
	function [34:0] signed_addition;
        input [7:0] dst_reg_name;
        input [7:0] reg_name;
        signed_addition = {`ACC,`SAD,`REG,`STACK1,`REG,`STACK2,`N8};
    endfunction
    function [34:0] signed_multiplication;
        input [7:0] reg_name1;
        input [7:0] reg_name2;
        signed_multiplication = {`ACC, `SMT, `REG, reg_name1, `REG, reg_name2, `N8};
    endfunction
endmodule


