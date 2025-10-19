`timescale 1ns/1ps

module cordic_vector_test();

parameter PERIOD = 10;
reg clk;
reg rst_n;
reg start;
reg signed	 [15:0] 		I;
reg signed 	 [15:0] 		Q;
wire         [8:0]      angle;
wire 					finished;

initial begin
	clk = 0;
	rst_n = 0;
	start = 0;
	I = 'b0;
    Q = 'b0;

	#100 rst_n =1;
			
	//#100 @(posedge clk) start = 1'b1   ;angle = 8'd60;
	// #100 @(posedge clk) 				angle = 8'd30;

	
	#100 @(posedge clk) start = 1'b1   ; I=15'd100;Q=15'd100;
    #210 @(posedge clk)    I=-'d26566;Q=15'd15901;
    #210 @(posedge clk)    I=-'d26500;Q=-'d15900;
    #210 @(posedge clk)    I=15'd265;Q=-'d159;
    #210 @(posedge clk)    I=15'd2650;Q=15'd1590;
    #210 @(posedge clk)    I=15'd0;Q=15'd100;
    #210 @(posedge clk)    I=-'d17320;Q=15'd10000;
	#210 @(posedge clk)    I='d1732;Q=-15'd1000;
	#210 @(posedge clk)    I='d173;Q=-15'd100;
	#210 @(posedge clk)    I='d17;Q=-15'd10;
	#210 @(posedge clk)    I='d100000;Q=-15'd200;
    #210 @(posedge clk)    I='d0;Q=-15'd1000;
    #210 @(posedge clk)    I=15'd100;Q=15'd0;
    #100
    $stop;	
end

always #(PERIOD/2) clk = ~clk;




cordic_vector #(
	.SYS_CLK_FREQ 	(16_000  ),
	.MIXING_FREQ  	(160_000   ),
	.DEMOD_FREQ   	(16_000    ),
	.SAMPLE_RATE  	(800       ))

u_cordic_vector(
		.clk(clk),
		.rst_n(rst_n),
		.x(I),
        .y(Q),
		.start(start),
		.angle(angle),
		.finished(finished)
		
);


endmodule

