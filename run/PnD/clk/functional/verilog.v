//Verilog HDL for "PnD", "clk" "functional"
`timescale 1ns / 1ns

module clk ( output reg oclk );
	initial begin
		oclk = 0;
		forever #62.5 oclk = ~oclk;
	end
endmodule
