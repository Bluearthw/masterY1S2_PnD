module dgtop#(parameter NIN  = 12,
      parameter NMAX = 21,
      parameter NOUT = 17
)(
     input  logic             clk,
     input  logic             rstn,
     input  logic             en,
     input  logic [NIN-1:0]   din,
     input  logic             valid,
     output logic [NOUT-1:0]  dout

);
cic #(
   .NIN (NIN),
   .NMAX(NMAX),
   .NOUT(NOUT)
) i_cic(
 .clk (clk),
 .rstn(rstn),
 .en(en),
 .din(din),
 .valid(valid),
 .dout(dout)
);


endmodule: dgtop
