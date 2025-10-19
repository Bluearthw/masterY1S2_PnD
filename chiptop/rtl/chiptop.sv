module chiptop (
    input wire in,
    input wire vdd,
    input wire vss,
    input wire comp_ref,
    input logic clk,
    input logic rst_n,
    output logic [3:0] out
  );

  wire w_ctrl;
  wire w_enable;

  anatop i_anatop (
    // INPUTS
    .IN              (in),
    .CAP_BANK_ENABLE (w_enable),
    .COMP_CLK        (clk),
    // OUTPUTS
    .OUT             (w_ctrl),
    // BIASING
    .COMP_REF        (comp_ref),
    .VDD             (vdd),
    .VSS             (vss)
  );

  dgtop #(
    .DELAY  (2),
    .WIDTH  (4)
  ) i_dgtop (
    .clk    (clk),
    .rst_n  (rst_n),
    .ctrl   (w_ctrl),
    .out    (out),
    .enable (w_enable)
  );

endmodule : chiptop

