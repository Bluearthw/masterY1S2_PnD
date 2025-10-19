`timescale 1ps/1ps

module demod_test;
    parameter    NIN  = 16 ;
    parameter    NMAX = 40 ;
    parameter    NOUT = 16 ;

    reg clk_6400k;
    reg clk_320k;
    reg clk_16k;
    reg clk_800;
    reg rstn;
    reg en;
    reg signed [7:0]    adc_in;
    reg signed [NOUT-1:0] I_out;
    reg signed [NOUT-1:0] Q_out;
    reg sweep_done;
    reg  [8:0] phase;
    reg  signed [5:0] freq;
    

//==========================================
//200kHz clk generating

   localparam  time T6400k_HALF    =    78125; //5us period . 2.5us half-period
   localparam  time T320k_HALF     =  1562500; //5us period . 2.5us half-period
   localparam  time T16k_HALF      = 31250000;
   localparam  time T800_HALF      = T16k_HALF*20;
   initial begin
      clk_6400k = 1'b0 ;
      forever begin
         # T6400k_HALF clk_6400k = ~clk_6400k ;
      end

   end

   initial begin
      clk_320k = 1'b0 ;
      forever begin
         # T320k_HALF clk_320k = ~clk_320k ;
      end
   end

   initial begin
      clk_16k = 1'b0 ;
      forever begin
         # T16k_HALF clk_16k = ~clk_16k ;
      end
   end

      initial begin
      clk_800 = 1'b1 ;
      forever begin
         # T800_HALF clk_800 = ~clk_800 ;
      end
   end

//============================
//  reset and finish
   initial begin
      rstn = 1'b0 ;
      en  = 1'b0;
      # 2000;
      rstn = 1'b1;
      # 30000000;
      en = 1'b1;


    
   end

//=======================================
// read cos data into register
   parameter    SIN_DATA_NUM = 486401 ;
   reg          signed [8-1:0] stimulus [0: SIN_DATA_NUM-1] ;
   integer      i ;
   string infile;

   initial begin
      if (!$value$plusargs("input_file=%s", infile)) begin
         $display("ERROR: input_file not provided via +input_file=...");
         $finish;
      end
      $readmemb(infile, stimulus);
   end

   initial begin
      
      i         = 0 ;
      adc_in         = 0 ;

      forever begin
         @(negedge clk_320k) begin
            adc_in         = stimulus[i] ;
            if (i == SIN_DATA_NUM-1) begin
               i = 0 ;
               $finish;
            end
            else begin
               i = i + 1 ;
            end
         end
      end
   end

   downmixer_recovery #(.NIN(NIN), .NMAX(NMAX), .NOUT(NOUT))
   u_downmixer (
    .clk         (clk_6400k),
    .clk_80k     (clk_320k),
    .rst         (rstn),
    .en          (en),
    .adc_in      (adc_in),
    .I_out       (I_out),
    .Q_out       (Q_out),
    .sweep_done  (sweep_done));

    // output declaration of module demod_gmsk

    demod_gmsk u_demod_gmsk(
        .I      	(I_out       ),
        .Q      	(Q_out       ),
        .start    (sweep_done),
        .resetn 	(rstn  ),
        .clk    	(clk_6400k     ),
        .clk_800  (clk_800),
        .phase  	(phase   ),
        .freq   	(freq    )
    );
    

initial begin
      $dumpfile("demod_test.vcd");
      $dumpvars(0, demod_test);
end



endmodule // test

