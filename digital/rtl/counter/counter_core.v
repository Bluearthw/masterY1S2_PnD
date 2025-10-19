module counter_core #(
    parameter WIDTH = 1
  ) (
    input wire clk,
    input wire rst_n,
    input wire ctrl,
    output reg [WIDTH-1:0] count
  );

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      count <= 0;
    end else begin
      if (ctrl) begin
        count <= count + 1;
      end else begin
        count <= count - 1;
      end
    end
  end

endmodule
