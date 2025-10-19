module toggle #(
    parameter WIDTH = 1
  ) (
    input logic clk,
    input logic rst_n,
    input logic [WIDTH-1:0] in,
    output logic [WIDTH-1:0] out
  );

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      out <= 0;
    end else if (in) begin
      out <= ~out;
    end
  end

endmodule : toggle
