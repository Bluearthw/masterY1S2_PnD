`timescale 1ps/1ps

module downmixer_test;
    parameter    NIN  = 16 ;
    parameter    NMAX = 40 ;
    parameter    NOUT = 16 ;

    reg clk;
    reg clk_80k;
    reg rstn;
    reg en;
    reg signed [7:0]    adc_in;
    reg signed [NOUT-1:0] I_out;
    reg signed [NOUT-1:0] Q_out;
    reg sweep_done;

//==========================================
//200kHz clk generating

   localparam  time T6400k_HALF    =   78125; //5us period . 2.5us half-period
   localparam  time T320k_HALF     = 1562500; //5us period . 2.5us half-period
   initial begin
      clk = 1'b0 ;
      forever begin
         # T6400k_HALF clk = ~clk ;
      end

   end

   initial begin
      clk_80k = 1'b0 ;
      forever begin
         # T320k_HALF clk_80k = ~clk_80k ;
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
   parameter    SIN_DATA_NUM = 204801 ;
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
         @(negedge clk_80k) begin
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
    .clk         (clk),
    .clk_80k     (clk_80k),
    .rst         (rstn),
    .en          (en),
    .adc_in      (adc_in),
    .I_out       (I_out),
    .Q_out       (Q_out),
    .sweep_done  (sweep_done));

initial begin
      $dumpfile("downmixer_test.vcd");
      $dumpvars(0, downmixer_test);
end



endmodule // test

