module inv #(
    parameter WIDTH = 1
  ) (
    input logic [WIDTH-1:0] in,
    output logic [WIDTH-1:0] out
  );

  assign out = ~in;

endmodule : inv
