// This example demonstrates the simplest kind of test procedure.
// Instantiate the DUT, drive a test sequence on the DUT-inputs and monitor the outputs.
// It is quick to set up but does not provide much flexibility, nor automation.

module delay_tb;

  // Testbench signals
  logic clk;
  logic rst_n;
  logic [1:0] in;
  logic [1:0] out;

  // Instantiate the DUT
  delay #(
    .DELAY (3),
    .WIDTH (2)
  ) dut (
    .clk   (clk),
    .rst_n (rst_n),
    .in    (in),
    .out   (out)
  );

  // Clock generation (period = 10 time units)
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Test sequence
  initial begin
    // Initialize inputs
    rst_n = 1;
    in = 0;

    // Apply reset
    #6 rst_n = 0;
    #2 rst_n = 1;

    // Apply input pattern
    #2 in = 2'b11;
    #10 in = 2'b10;
    #10 in = 2'b01;
    #10 in = 2'b00;
    #10 in = 2'b01;

    // Finish simulation
    #50 $finish;
  end

  // Monitor outputs
  initial $monitor("Time: %0t | rst_n: %b | in: %b | out: %b", $time, rst_n, in, out);

endmodule
