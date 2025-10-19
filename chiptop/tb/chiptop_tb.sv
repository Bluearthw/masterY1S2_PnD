`timescale 10ps/1ps
module chiptop_tb;

  wire w_in;
  wire w_vdd;
  wire w_vcm;
  wire w_vss;

  logic clk;
  logic clk_cmp;
  logic rst_n;

  // logic clk_d;
  logic en;


  anatop_driver i_anatop_driver(.out(w_in));

  biasing i_biasing(
    .comp_ref (w_vcm),
    .vdd      (w_vdd),
    .vss      (w_vss)
  );

  mix_clk i_mix_clk(
    .oclk       (clk),
    .clk_cmp    (clk_cmp),
    .rst_n      (rst_n),
    // .clk_1600k (clk_d),
    .en         (en)
  );

  

  chiptop i_chiptop(
    .vin        (w_in),
    .vdd        (w_vdd),
    .vcm        (w_vcm),
    .vss        (w_vss),
    .rst_n      (rst_n),
    .clk        (clk),
    .clk_cmp    (clk_cmp),
    .en         (en)
    // .clk_80    (clk_80k),
    // .clk_6400  (clk_d)
  );

endmodule : chiptop_tb
