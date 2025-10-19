`timescale 1ps/1ps
module mix_clk ( 
	output logic oclk, //16M
	output logic clk_cmp, //
	output logic rst_n,
	output logic en,
	output logic clk_1600k
  	// output logic clk_80k
	);

   	localparam  time T16M_HALF    = 31250; 
   	localparam  time T6400k_HALF    =    78125;
	initial begin
		oclk = 0;
		forever #T16M_HALF oclk = ~oclk;//16M T = 62.5n=62500ps so half
	end

	initial begin
	clk_cmp = 0;	
	#46875 // 1.5 * 0.5 T phase shit,  #46.875
	forever #T16M_HALF clk_cmp = ~clk_cmp; // 16 MHz
	 end

 	initial begin
		rst_n = 0;
		en  = 1'b0;
    	#33000 rst_n = 1;
		# 30000000;
      	en = 1'b1;
	 end

	initial begin
	clk_1600k = 0;	
	forever #T6400k_HALF clk_1600k = ~clk_1600k; // 16 MHz
	 end
	


endmodule : mix_clk
