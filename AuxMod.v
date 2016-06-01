// Add more auxillary modules here...






// Display a Hexadecimal Digit, a Negative Sign, or a Blank, on a 7-segment Display
module SSeg(input [3:0] bin, input neg, input enable, output reg [6:0] segs);
	always @(*)
		if (enable) begin
			if (neg) segs = 7'b011_1111;
			else begin
				case (bin)
					0: segs = 7'b100_0000;
					1: segs = 7'b111_1001;
					2: segs = 7'b010_0100;
					3: segs = 7'b011_0000;
					4: segs = 7'b001_1001;
					5: segs = 7'b001_0010;
					6: segs = 7'b000_0010;
					7: segs = 7'b111_1000;
					8: segs = 7'b000_0000;
					9: segs = 7'b001_1000;
					10: segs = 7'b000_1000;
					11: segs = 7'b000_0011;
					12: segs = 7'b100_0110;
					13: segs = 7'b010_0001;
					14: segs = 7'b000_0110;
					15: segs = 7'b000_1110;
				endcase
			end
		end
		else segs = 7'b111_1111;
endmodule


module Debounce( Clock, Signal, debounced_signal);
	input Clock;
	input Signal;
	wire signal_changed;
	wire syn_out;
	reg [N-1:0] counter;
	output reg debounced_signal;
	wire add;
	Synchroniser synch (.clk(Clock),.signal(Signal),.synchronized_signal(syn_out));
	assign signal_changed = Signal ^ syn_out;
	localparam max = 150000000/40;
	assign add = ~(counter == max);
	wire go = add & (~signal_changed);
	parameter N = 26;
	always@(posedge Clock) begin
	
	if(go) counter <= counter + 26'b1;
	else counter <= 26'b0;
	end
	always@(posedge Clock) begin
		if(counter == max) debounced_signal <= syn_out;
		else debounced_signal <= debounced_signal;
	end
endmodule


module DetectFallingEdge(clock,btn_sync,fallingedgedetected);
	input clock,btn_sync;
	output fallingedgedetected;
	reg new_btn_sync;
	always@(posedge clock) begin
		new_btn_sync <= btn_sync;
	end
	assign fallingedgedetected = (new_btn_sync == 1'b1 && btn_sync == 1'b0) ? 1'b1 : 1'b0;
	
endmodule
module Disp2cNum(input signed [7:0] x, input enable, output [6:0] H3,H2,H1,H0/*, output [7:0] xo0_check,xo1_check,xo2_check,xo3_check*/);
  
	wire neg = (x<0);
	wire [7:0] ux = neg ? -x : x;
	
	
	wire [7:0] xo0,xo1,xo2,xo3;
	wire eno0,eno1,eno2,eno3;
	
	
	DispDec h0(ux,neg,enable,xo0,eno0,H0);
	DispDec h1(xo0,neg,eno0,xo1,eno1,H1);
	DispDec h2(xo1,neg,eno1,xo2,eno2,H2);
	DispDec h3(xo2,neg,eno2,xo3,eno3,H3);
	
	
endmodule


module DispDec(input [7:0] x, input neg,enable,output reg [7:0] xo, output reg eno,output [6:0] segs);
	wire [3:0] digit;
	wire n = (x == 8'b0 && neg == 1'b1) ? neg : 1'b0;
	
	assign digit = x % 8'd10;
	SSeg converter (digit,n,enable,segs);
	
	always@(x) begin
		xo = x /8'd10;
	end
	always@(x or neg or n or enable) begin
		if((x/10 == 0 && neg == 0) ||(n == 1))
		eno = 0;
		else eno = enable;
	end
	
	
	
endmodule



module DispHex(input [7:0] value, output [6:0] display0,display1);
	SSeg sseg0 (value[7:4],1'b0,1'b1,display0);
	SSeg sseg1 (value[3:0],1'b0,1'b1,display1);
endmodule

module Synchroniser(input clk,input signal,output reg synchronized_signal);
	reg meta;

	always @(posedge clk) begin
		meta <= signal;
		synchronized_signal <= meta;
	end
endmodule

