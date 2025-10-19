module counter #(
    parameter WIDTH = 1
  ) (
    input logic clk,
    input logic rst_n,
    input logic ctrl,
    output logic [WIDTH-1:0] count,
    output logic loop
  );

  counter_core #(
    .WIDTH   (WIDTH)
  ) i_counter_core (
    .clk     (clk),
    .rst_n   (rst_n),
    .ctrl    (ctrl),
    .count   (count)
  );

  loop_detector #(
    .WIDTH (WIDTH)
  ) i_loop_detector (
    .count (count),
    .loop  (loop)
  );

endmodule : counter
