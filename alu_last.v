`timescale 1ns / 1ps
//0316044 + 0316225
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:49:51 03/16/2016 
// Design Name: 
// Module Name:    alu_last 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module alu_last(
               src1,       //1 bit source 1 (input)
               src2,       //1 bit source 2 (input)
               less,       //1 bit less     (input)
               A_invert,   //1 bit A_invert (input)
               B_invert,   //1 bit B_invert (input)
               cin,        //1 bit carry in (input)
               operation,  //operation      (input)
               result,     //1 bit result   (output)
               cout,       //1 bit carry out(output)
					set,
					equal,
					cmp	//bonus
               );

input         src1;
input         src2;
input         less;
input         A_invert;
input         B_invert;
input         cin;
input [2-1:0] operation;
input			  equal;
input [2:0]   cmp;


output   reg  result;
output   reg   cout;
output		set;

reg s1, s2;
reg done;
//assign set = s1 ^ s2 ^ cin;//set_basic
//set_bonus
assign	set = (cmp==3'b000) ? (s1 ^ s2 ^ cin) : //set less than <
					(cmp==3'b001) ? ~( (s1 ^ s2 ^ cin) | equal) : //set great than >
					(cmp==3'b010) ? ((s1 ^ s2 ^ cin) | equal) : //set less equal <=
					(cmp==3'b011) ? (~ (s1 ^ s2 ^ cin)) ://set great equal >=
					(cmp==3'b110) ? (equal) ://set equal ==
					(cmp==3'b100) ? (~equal) : 0;//set not equal !=


always@( * )begin

done =0 ;

if(done == 0)begin
	if(A_invert) s1 = ~src1;	else s1 = src1;
	if(B_invert) s2 = ~src2;	else s2 = src2;
	
	case(operation)
		2'b00:begin//And
			result = s1 & s2;
			cout = 0;end
			
		2'b01:begin//Or
			result = s1 | s2;
			cout = 0;end
		
		2'b10:begin//Add
			result = s1 ^ s2 ^ cin;
			cout = (s1&s2) + (s1&cin) + (s2&cin); 
			end
		
		2'b11:begin//less
			result = less;
			cout = 0; //SLT do not have cout!
			//cout = (s1&s2) + (s1&cin) + (s2&cin); 
			end
	endcase
	
	done = 1;
	
	end
else begin
	result = result;
	cout = cout;
end
	
end

endmodule