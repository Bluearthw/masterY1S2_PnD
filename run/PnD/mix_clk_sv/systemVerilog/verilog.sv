`timescale 10ps/1ps
module mix_clk_sv ( 
	output logic oclk, //16M
	output logic clk_cmp, //
	output logic rst_n,
	output logic en
	// output logic clk_1600k
  	// output logic clk_80k
	);
//analog 1.6M clk, 625ns, half period: 312.5ns
// digital 3.2M clk ,312.5ns,half 156.25ns
	//1ps/1ps
   	// localparam  time T3200k_HALF    = 312500; //3.2M = 312.5ns 312500ps /2 156250
   	// localparam  time T6400k_HALF    =    2*78125;
	
	//10ps/1ps 312500p
	localparam  time T3200k_HALF    = 31250; //3.2M = 312.5ns 312500ps /2 156250
   	// localparam  time T6400k_HALF    =    31250;
	localparam time T3200k_ONEHALF_HALF = 46875;
	initial begin
		oclk = 0;
		forever #T3200k_HALF oclk = ~oclk;//16M T = 62.5n=62500ps so half
	end

	initial begin
	clk_cmp = 0;	
	#T3200k_ONEHALF_HALF // 1.5 * 0.5 T phase shit,  #234375
	forever #T3200k_HALF clk_cmp = ~clk_cmp; // 3.2MHz
	 end

 	initial begin
		rst_n = 0;
		en  = 1'b0;
    	#T3200k_ONEHALF_HALF rst_n = 1;
		// # 30000000;//1ps/1ps
		# 3000000;//10ps/1ps
      	en = 1'b1;
	 end
// //digital clk
// 	initial begin
// 	clk_1600k = 0;	
// 	#T6400k_HALF
// 	forever #T6400k_HALF clk_1600k = ~clk_1600k; // 16 MHz
// 	 end
	


endmodule : mix_clk_sv
