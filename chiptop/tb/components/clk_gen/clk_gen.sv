module clk_gen (
  output logic clk,
  output logic rst_n
  );

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  assign w_clk = clk;

  initial begin
    rst_n = 0;
    #1 rst_n = 1;
  end

endmodule : clk_gen
