`timescale 1ns/1ps

module cordic_test();

 localparam [15:0] sweep_steps [0:10] = '{16'd4386*2, 16'd4410*2, 16'd4432*2, 16'd4454*2, 16'd4476*2,16'd4500*2, 16'd4522*2, 16'd4546*2, 16'd4568*2, 16'd4590*2, 16'd4612*2};


parameter PERIOD = 10;
reg clk;
reg rst_n;
reg [15:0]angle;
reg start;

wire signed	 [7:0] 		Sin;
wire signed	 [7:0] 		Cos;
wire 					finished;

initial begin
	clk = 0;
	rst_n = 0;
	start = 0;
	angle = 'b0;

	#100 rst_n =1;
			
	//#100 @(posedge clk) start = 1'b1   ;angle = 8'd60;
	// #100 @(posedge clk) 				angle = 8'd30;

   
	
	#100 @(posedge clk) start = 1'b1   ; angle = 16'd4500;
	#1000 rst_n = 0; start = 1'b0;
    #100 rst_n = 1;
    #100 @(posedge clk) start = 1'b1   ;angle = 16'd6000; 
    #1000 rst_n = 0; start = 1'b0;
    #100 rst_n = 1;
    #100 @(posedge clk) start = 1'b1   ;angle = 16'd3000;
    #1000 rst_n = 0; start = 1'b0;
    #100 rst_n = 1;
    #100 @(posedge clk) start = 1'b1   ;angle = 16'd9000;
    #1000 rst_n = 0; start = 1'b0;
    #100 rst_n = 1;
    #100 @(posedge clk) start = 1'b1   ;angle = 16'd000;
    #1000 rst_n = 0; start = 1'b0;
    #100 rst_n = 1;
    #100 @(posedge clk) start = 1'b1   ;angle = 16'd12000; 
    #1000 rst_n = 0; start = 1'b0;
    #100 rst_n = 1;
    #100 @(posedge clk) start = 1'b1   ;angle = 16'd15000;
    #1000 rst_n = 0; start = 1'b0;
    #100 rst_n = 1;
    #100 @(posedge clk) start = 1'b1   ;angle = 16'd18000;
    #1000 rst_n = 0; start = 1'b0;
    #100 rst_n = 1;
    #100 @(posedge clk) start = 1'b1   ;angle = 16'd21000;
    #1000 rst_n = 0; start = 1'b0;
    #100 rst_n = 1;
    #100 @(posedge clk) start = 1'b1   ;angle = 16'd22500;
    #1000 rst_n = 0; start = 1'b0;
    #100 rst_n = 1;
    #100 @(posedge clk) start = 1'b1   ;angle = 16'd25000;
    #1000 rst_n = 0; start = 1'b0;
    #100 rst_n = 1;
    #100 @(posedge clk) start = 1'b1   ;angle = 16'd27000;
	#1000 rst_n = 0; start = 1'b0;
    #100 rst_n = 1;
    #100 @(posedge clk) start = 1'b1   ;angle = 16'd30000;
    #1000 rst_n = 0; start = 1'b0;
    #100 rst_n = 1;
    #100 @(posedge clk) start = 1'b1   ;angle = 16'd31500;
    #1000 rst_n = 0; start = 1'b0;
    #100 rst_n = 1;
    #100 @(posedge clk) start = 1'b1   ;angle = 16'd33000;
	#1000 rst_n = 0; start = 1'b0;
    #100 rst_n = 1;
    #100 @(posedge clk) start = 1'b1   ;angle = 16'd36000;
    #1000 start = 1'b0;
    #1000 rst_n = 0; start = 1'b0;
    #100 rst_n = 1;
    #100 @(posedge clk) start = 1'b1   ;angle = sweep_steps[0];
    #1000 start = 1'b0;
        #1000 rst_n = 0; start = 1'b0;
    #100 rst_n = 1;
    #100 @(posedge clk) start = 1'b1   ;angle = sweep_steps[1];
    #1000 start = 1'b0;
        #1000 rst_n = 0; start = 1'b0;
    #100 rst_n = 1;
    #100 @(posedge clk) start = 1'b1   ;angle = sweep_steps[2];
    #1000 start = 1'b0;
        #1000 rst_n = 0; start = 1'b0;
    #100 rst_n = 1;
    #100 @(posedge clk) start = 1'b1   ;angle = sweep_steps[3];
    #1000 start = 1'b0;
        #1000 rst_n = 0; start = 1'b0;
    #100 rst_n = 1;
    #100 @(posedge clk) start = 1'b1   ;angle = sweep_steps[4];
    #1000 start = 1'b0;
        #1000 rst_n = 0; start = 1'b0;
    #100 rst_n = 1;
    #100 @(posedge clk) start = 1'b1   ;angle = sweep_steps[5];
    #1000 start = 1'b0;
        #1000 rst_n = 0; start = 1'b0;
    #100 rst_n = 1;
    #100 @(posedge clk) start = 1'b1   ;angle = sweep_steps[6];
    #1000 start = 1'b0;
        #1000 rst_n = 0; start = 1'b0;
    #100 rst_n = 1;
    #100 @(posedge clk) start = 1'b1   ;angle = sweep_steps[7];
    #1000 start = 1'b0;
        #1000 rst_n = 0; start = 1'b0;
    #100 rst_n = 1;
    #100 @(posedge clk) start = 1'b1   ;angle = sweep_steps[8];
    #1000 start = 1'b0;
        #1000 rst_n = 0; start = 1'b0;
    #100 rst_n = 1;
    #100 @(posedge clk) start = 1'b1   ;angle = sweep_steps[9];
    #1000 start = 1'b0;
        #1000 rst_n = 0; start = 1'b0;
    #100 rst_n = 1;
    #100 @(posedge clk) start = 1'b1   ;angle = sweep_steps[10];
    #1000 start = 1'b0;

  
    $stop;	
end

always #(PERIOD/2) clk = ~clk;

cordic inst1(
		.clk(clk),
		.rst_n(rst_n),
		.angle(angle),
		.start(start),
		
		.Sin(Sin),
		.Cos(Cos),
		.finished(finished)
		
);

endmodule

