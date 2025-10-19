module delay #(
    parameter DELAY = 1,          // Number of clock cycles to delay
    parameter WIDTH = 1           // Bitwidth of in/outputs
  ) (
    input logic clk,              // Clock signal
    input wire rst_n,             // Asynchronous reset
    input logic [WIDTH-1:0] in,   // Input signal
    output logic [WIDTH-1:0] out  // Delayed output signal
  );

  // Internal shift register
  logic [WIDTH-1:0] shift_register [DELAY-1:0];

  // Sequential logic for the shift register
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      shift_register <= '{default: '0};
      out <= '0;
    end else begin
      shift_register[0] <= in;
      if (DELAY > 1) begin
        shift_register[DELAY-1:1] <= shift_register[DELAY-2:0];
      end
      out <= shift_register[DELAY-1];
    end
  end

endmodule
