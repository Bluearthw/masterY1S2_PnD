module loop_detector #(
    parameter WIDTH = 1,
    parameter CONSTANT = 0
  ) (
    input logic [WIDTH-1:0] count,
    output logic loop
  );

  assign loop = (count == CONSTANT);

endmodule : loop_detector
