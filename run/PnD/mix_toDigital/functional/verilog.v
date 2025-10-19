//Verilog HDL for "PnD", "mix_toDigital" "functional"


module mix_toDigital ( 
	input  [7:0] unsign_digital,
	output reg [7:0] signed_digital
 );
	always@(*)
	begin
		signed_digital = unsign_digital - 128;
	end
	
endmodule
