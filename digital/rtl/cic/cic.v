module cic
    #(parameter NIN  = 16,
      parameter NMAX = 40,
      parameter NOUT = 16,
      parameter SYS_CLK_FREQ = 6400_000,
      parameter MIXING_FREQ  = 320_000,
      parameter DEMOD_FREQ   = 16_000,
      parameter SAMPLE_RATE  = 800  )
    (
     input               clk,
     input               rstn,
     input               en,
     input signed[NIN-1:0]     din,
     output               valid,
     output signed[NOUT-1:0]   dout);

   wire signed [NMAX-1:0]      itg_out ;
   wire signed [NMAX-1:0]      dec_out ;
   wire [1:0]           en_r ;

   integrator   #(.NIN(NIN), .NOUT(NMAX), .SYS_CLK_FREQ(SYS_CLK_FREQ), .MIXING_FREQ(MIXING_FREQ), .DEMOD_FREQ(DEMOD_FREQ), .SAMPLE_RATE(SAMPLE_RATE))
   u_integrator (
       .clk         (clk),
       .rstn        (rstn),
       .en          (en),
       .din         (din),
       .valid       (en_r[0]),
       .dout        (itg_out));

   decimation   #(.NDEC(NMAX), .SYS_CLK_FREQ(SYS_CLK_FREQ), .MIXING_FREQ(MIXING_FREQ), .DEMOD_FREQ(DEMOD_FREQ), .SAMPLE_RATE(SAMPLE_RATE))
   u_decimator (
       .clk         (clk),
       .rstn        (rstn),
       .en          (en_r[0]),
       .din         (itg_out),
       .dout        (dec_out),
       .valid       (en_r[1]));

   comb         #(.NIN(NMAX), .NOUT(NOUT), .SYS_CLK_FREQ(SYS_CLK_FREQ), .MIXING_FREQ(MIXING_FREQ), .DEMOD_FREQ(DEMOD_FREQ), .SAMPLE_RATE(SAMPLE_RATE))
   u_comb (
       .clk         (clk),
       .rstn        (rstn),
       .en          (en_r[1]),
       .din         (dec_out),
       .valid       (valid),
       .dout        (dout));

endmodule

