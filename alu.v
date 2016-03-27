`timescale 1ns/1ps

module alu(
           rst_n,         // negative reset            (input)
           src1,          // 32 bits source 1          (input)
           src2,          // 32 bits source 2          (input)
           ALU_control,   // 4 bits ALU control input  (input)
		  bonus_control, // 3 bits bonus control input(input) 
           result,        // 32 bits result            (output)
           zero,          // 1 bit when the output is 0, zero must be set (output)
           cout,          // 1 bit carry out           (output)
           overflow       // 1 bit overflow            (output)
           );


input           rst_n;
input  [32-1:0] src1;
input  [32-1:0] src2;
input   [4-1:0] ALU_control;
input   [3-1:0] bonus_control; 

output [32-1:0] result;
output          zero;
output          cout;
output          overflow;

wire             zero;
wire             cout;
wire             overflow;

reg [1:0] oper;
wire [31:0] carry;
reg a_in;
reg b_in;
reg less_sig;
wire			set;
wire			equal;

assign carry[0] = (ALU_control==4'b0110)? 1: (ALU_control==4'b0111)? 1: 0; //sub slt: cin =1
assign zero = (result == 0) ? 1 : 0;
//assign overflow = carry[31] ^ cout;
assign equal = (src1 == src2) ? 1 : 0;
assign overflow = ( (ALU_control==4'b0000) & src1[31] & src2[31] & ~result[31]) ? 1 
					  :( (ALU_control==4'b0000) & ~src1[31] & ~src2[31] & result[31]) ? 1 
					  :( (ALU_control==4'b0110) & src1[31] & ~src2[31] & ~(result[31])) ? 1 
					  :( (ALU_control==4'b0110) & ~src1[31] & src2[31] & result[31]) ? 1 
					  : 0;

genvar gvi;
generate
	for(gvi=0; gvi<32; gvi = gvi+1)
	begin: label
		if(gvi==0)begin
			alu_top alu0( .src1(src1[0]), .src2(src2[0]), .less(set), .A_invert(a_in), .B_invert(b_in), 
				.cin(carry[0]), .operation(oper), .result(result[0]), .cout(carry[1]) ); end
		else if(gvi==31) begin
			alu_last alu31( .src1(src1[31]), .src2(src2[31]), .less(less_sig), .A_invert(a_in), .B_invert(b_in),
					.cin(carry[31]), .operation(oper), .result(result[31]), .cout(cout),
					.set(set), .equal(equal), .cmp(bonus_control) ); end
		else begin
			alu_top alu1( .src1(src1[gvi]), .src2(src2[gvi]), .less(less_sig), .A_invert(a_in), .B_invert(b_in),
	 				.cin(carry[gvi]), .operation(oper), .result(result[gvi]), .cout(carry[gvi+1]) );
		end
	end
endgenerate

always@(*)begin
	if(rst_n==1)begin
		less_sig <= 1'b0;
		
		case(ALU_control)
			4'b0000:begin//And
					a_in  	<= 0;
					b_in 	 	<= 0;
					oper  	<= 2'b00;//and
					end
			4'b0001:begin//Or
					a_in  	<= 0;
					b_in 	 	<= 0;
					oper  	<= 2'b01;//or
					end
			4'b0010:begin//Add
					a_in  	<= 0;
					b_in 	 	<= 0;
					oper  	<= 2'b10;//add
					end
			4'b0110:begin//Sub
					a_in  	<= 0;
					b_in 	 	<= 1;
					oper  	<= 2'b10;//add
					end
			4'b1100:begin//Nor
					a_in  	<= 1;
					b_in 	 	<= 1;
					oper  	<= 2'b00;//and
					end
			4'b1101:begin//Nand
					a_in  	<= 1;
					b_in 	 	<= 1;
					oper  	<= 2'b01;//or
					end
			4'b0111:begin//SetLessThan
					a_in  	<= 0;
					b_in 	 	<= 1;
					oper  	<= 2'b11;//less
					end
			default: ;
		endcase
	end
end

endmodule
