`timescale 1ns/1ns

module cic_test ;
   parameter    NIN  = 24 ;
   parameter    NMAX = 28 ;
   parameter    NOUT = NIN ;

   reg                  clk ;
   reg                  rstn ;
   reg                  en ;
   reg  [NIN-1:0]       din ;
   wire                 valid ;
   wire [NOUT-1:0]      dout ;

//=====================================
// 80kHz clk generating
   localparam  time T80k_HALF    = 6250; //12.5us period . 6.25us half-period
   initial begin
      clk = 1'b0 ;
      forever begin
         # T80k_HALF clk = ~clk ;
      end
   end

//============================
//  reset and finish
   initial begin
      rstn = 1'b0 ;
      # 30 ;
      rstn = 1'b1 ;
      # (T80k_HALF * 2 * 1600) ;
      $finish ;
   end





//=======================================
// read cos data into register
   parameter    SIN_DATA_NUM = 160 ;
   reg          [NIN-1:0] stimulus [0: SIN_DATA_NUM-1] ;
   integer      i ;
   string infile;

   initial begin
      if (!$value$plusargs("input_file=%s", infile)) begin
         $display("ERROR: input_file not provided via +input_file=...");
         $finish;
      end
      $readmemh(infile, stimulus);
   end

   initial begin
      
      i         = 0 ;
      en        = 0 ;
      din       = 0 ;
      # 200 ;
      forever begin
         @(negedge clk) begin
            en          = 1 ;
            din         = stimulus[i] ;
            if (i == SIN_DATA_NUM-1) begin
               i = 0 ;
            end
            else begin
               i = i + 1 ;
            end
         end
      end
   end

   cic #(.NIN(NIN), .NMAX(NMAX), .NOUT(NOUT))
   u_cic (
    .clk         (clk),
    .rstn        (rstn),
    .en          (en),
    .din         (din),
    .valid       (valid),
    .dout        (dout));

endmodule // test
