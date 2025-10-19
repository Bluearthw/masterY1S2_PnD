// This example makes use a dedicated driver module. The driver reads
// bits from a file and drives those into the dgtop input.

module dgtop_tb;

  parameter WIDTH = 4;
  parameter DELAY = 2;

  logic clk;
  logic rst_n;
  logic ctrl;
  logic [WIDTH-1:0] out;
  logic enable;
  bit eof;

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    rst_n = 0;
    #5 rst_n = 1;

    wait (eof == 1) #20 $finish;
  end

  driver #(
    .WIDTH  (1)
  ) i_driver (
    .clk    (clk),
    .rst_n  (rst_n),
    .out    (ctrl),
    .eof    (eof)
  );

  dgtop #(
    .DELAY  (DELAY),
    .WIDTH  (WIDTH)
  ) i_dgtop (
    .clk    (clk),
    .rst_n  (rst_n),
    .ctrl   (ctrl),
    .out    (out),
    .enable (enable)
  );

endmodule
