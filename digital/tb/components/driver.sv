module driver #(
    parameter WIDTH = 1
  ) (
    input logic clk,
    input logic rst_n,
    output logic [WIDTH-1:0] out,
    output bit eof
  );

  string file_path;
  int fd;
  int err_code;
  string data;
  int errno;
  string err_str;
  int code;

  // Open file at the start of simulation
  initial begin
    file_path = read_file_path();
    fd = open_file(file_path);
  end

  // Sequenctial logic to drive the output
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      out <= 0;
      eof <= 0;
      rewind_file(fd);
    end else if (!$feof(fd)) begin
      //if ($fgets(data, fd) == 0) begin
      //  $error(0, "[%t] ERROR: Something went wrong while reading", $time);
      //  errno = $ferror(fd, err_str);
      //  $display("err=%d: %s,%s", errno, err_str, data);
      //  $fatal();
      //end else begin
        void'($fgets(data, fd));
        out <= data.atoi();
      //end
    end else begin
      eof <= 1;
    end
  end

  // Close the file at the end of the simulation
  final close_file(fd);

  // Read the file-path from the command line (+driver_file=<path-to-file>)
  function string read_file_path;
    string file_path;
    if (!$value$plusargs("driver_file=%s", file_path)) begin
      $fatal(0, "ERROR: No input file specified! Use +file=<path>");
    end
    return file_path;
  endfunction : read_file_path

  // Function to open and attain the file descriptor of the file at a given path
  function int open_file(string file_path);
    fd = $fopen(file_path, "r");
    if (fd == 0) begin
      $fatal(0, "ERROR: Failed to open file: %s", file_path);
    end else begin
      $display("INFO: Succesfully opened file: %s", file_path);
    end
    return fd;
  endfunction : open_file

  // Function to point the file descriptor to the start of the file again
  function void rewind_file(int fd);
    void'($rewind(fd));
  endfunction : rewind_file

  // Function to close the given file
  function void close_file(int fd);
    if (fd) begin
      $fclose(fd);
      $display("INFO: File closed: %s", file_path);
    end
  endfunction : close_file

endmodule : driver
