module dgtop #(
    parameter DELAY = 1,
    parameter WIDTH = 1
  ) (
    input logic clk,
    input logic rst_n,
    input logic ctrl,
    output logic [WIDTH-1:0] out,
    output enable
  );

  logic [WIDTH-1:0] w_counter_to_inv;
  logic w_loop_to_toggle;
  logic [WIDTH-1:0] w_inv_to_delay;

  counter #(
    .WIDTH (WIDTH)
  ) i_counter (
    .clk   (clk),
    .rst_n (rst_n),
    .ctrl  (ctrl),
    .count (w_counter_to_inv),
    .loop  (w_loop_to_toggle)
  );

  toggle #(
    .WIDTH (1)
  ) i_toggle (
    .clk   (clk),
    .rst_n (rst_n),
    .in    (w_loop_to_toggle),
    .out   (enable)
  );

  inv #(
    .WIDTH (WIDTH)
  ) i_inv (
    .in    (w_counter_to_inv),
    .out   (w_inv_to_delay)
  );

  delay #(
    .DELAY (DELAY),
    .WIDTH (WIDTH)
  ) i_delay (
    .clk   (clk),
    .rst_n (rst_n),
    .in    (w_inv_to_delay),
    .out   (out)
  );

endmodule : dgtop
