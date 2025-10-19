module chiptop_tb;

  wire w_in;
  wire w_vdd;
  wire w_vss;
  wire w_comp_ref;

  logic clk;
  logic rst_n;
  logic [3:0] out;


  anatop_driver i_anatop_driver(.out(w_in));

  biasing i_biasing(
    .comp_ref (w_comp_ref),
    .vdd      (w_vdd),
    .vss      (w_vss)
  );

  clk_gen i_clk_gen (
    .clk      (clk),
    .rst_n    (rst_n)
  );

  chiptop i_chiptop (
    .in       (w_in),
    .vdd      (w_vdd),
    .vss      (w_vss),
    .comp_ref (w_comp_ref),
    .clk      (clk),
    .rst_n    (rst_n),
    .out      (out)
  );

endmodule : chiptop_tb
