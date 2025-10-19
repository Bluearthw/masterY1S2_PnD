// In this example we can choose between two sequences depending on
// an argument value supplied in the xrun-call (+test_sequence=<nb>).
// Although still lacking in modularity and automation, this allows
// the reuse of a single testbench. You can also split the test-sequences
// into different files and decide which sequence you want to run by
// collecting that specific file, thereby creating a similar effect.

module counter_tb;

  // Testbench parameters
  parameter WIDTH = 4;

  // DUT I/O signals
  logic clk;
  logic rst_n;
  logic ctrl;
  logic [WIDTH-1:0] count;
  logic loop;

  // DUT instantiation
  counter #(
    .WIDTH (WIDTH)
  ) i_counter (
    .clk   (clk),
    .rst_n (rst_n),
    .ctrl  (ctrl),
    .count (count),
    .loop  (loop)
  );

  // Clock generation (period = 10 time units)
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    string test_sequence;

    // Reset generation
    rst_n = 0;
    #5 rst_n = 1;

    // Select test based on the argument value
    if ($value$plusargs("test_sequence=%s", test_sequence)) begin
      if (test_sequence == "1") begin
        $display("Selected Test Sequence 1...");
        test_sequence_1();
      end else if (test_sequence == "2") begin
        $display("Selected Test Sequence 2...");
        test_sequence_2();
      end else begin
        $fatal(0, "Test sequence %s not recognised.", test_sequence);
      end
    end else begin
      $fatal(0, "No Test Sequence selected, you must specify a test sequence using \"+test_sequence=<int>\"");
    end

    // Drain time and finish simulation
    #20 $finish;
  end

  task test_sequence_1;
    ctrl = 0;
    repeat (20) @(clk) ctrl = 1;
    repeat (6)  @(clk) ctrl = 0;
    repeat (10) @(clk) rst_n = 1;
    repeat (2) @(clk) rst_n = 1;
  endtask

  task test_sequence_2;
    ctrl = 0;
    fork
      #100 ctrl = 1;
      #130 ctrl = 0;
      #197 ctrl = 1;
      #17  ctrl = 0;
    join
  endtask

endmodule
