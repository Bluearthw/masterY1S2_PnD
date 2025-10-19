`timescale 1ps/1ps

module top_test;
    parameter CIC_NIN  = 16;
    parameter CIC_NMAX = 40;
    parameter CIC_NOUT = 16;
    parameter DEMOD_OUT = 6;
    parameter CLOCK_REC_OSR = 8;
    parameter SYS_CLK_FREQ = 1600_000;
    parameter MIXING_FREQ  = 160_000;
    parameter DEMOD_FREQ   = 80000;
    parameter SAMPLE_RATE  = 800;
    parameter SWEEP_SAMPLE_ACCUM_NUM = 32; 
    parameter TAPS =12;
    reg clk_6400k;
    reg clk_320k;
    reg clk_16k;
    reg clk_800;
    reg rstn;
    reg en;
    reg signed [7:0]    adc_in;
    // output declaration of module top
    wire [7:0] char_out;
    wire char_valid;
    
    

//==========================================
//200kHz clk generating

   localparam  time T3200k_HALF    =    4*78125; //16k *
   localparam  time T160k_HALF     =  2*1562500; //5us period . 2.5us half-period
   localparam  time T16k_HALF      = 2*31250000;
   localparam  time T800_HALF      = T16k_HALF*20;
   initial begin
      clk_6400k = 1'b0 ;
      forever begin
         # T3200k_HALF clk_6400k = ~clk_6400k ;
      end

   end

   initial begin
      clk_320k = 1'b0 ;
      forever begin
         # T160k_HALF clk_320k = ~clk_320k ;
      end
   end

   initial begin
      clk_16k = 1'b0 ;
      forever begin
         # T16k_HALF clk_16k = ~clk_16k ;
      end
   end

      initial begin
      clk_800 = 1'b1 ;
      forever begin
         # T800_HALF clk_800 = ~clk_800 ;
      end
   end

//============================
//  reset and finish
   initial begin
      rstn = 1'b0 ;
      en  = 1'b0;
      # 2000;
      rstn = 1'b1;
      # 30000000;
      en = 1'b1;

   end

//=======================================
// read cos data into register
   parameter    SIN_DATA_NUM = 1606500 ;
   reg          signed [8-1:0] stimulus [0: SIN_DATA_NUM-1] ;
   integer      i ;
   string infile;
   string outfile;
   int outfile_fd;

   initial begin
      if (!$value$plusargs("input_file=%s", infile)) begin
         $display("ERROR: input_file not provided via +input_file=...");
         $finish;
      end
      if (!$value$plusargs("output_file=%s", outfile)) begin
        $display("ERROR: +output_file=<file> not provided.");
        $finish;
      end
      outfile_fd = $fopen(outfile, "w");
        if (!outfile_fd) begin
            $display("ERROR: Failed to open file %s", outfile);
            $finish;
        end
      $readmemb(infile, stimulus);
      $display("First value read: %h", stimulus[0]);

   end

   initial begin
      
      i         = 0 ;
      adc_in         = 0 ;

      
      forever begin
         @(negedge clk_320k) begin
            adc_in         = stimulus[i] ;
            if (i == SIN_DATA_NUM-1) begin
               i = 0 ;
                $display("Finish testing");
               $finish;
            end
            else begin
               i = i + 1 ;
            end
         end
      end
   end


   

    reg char_valid_d;
    always @(posedge clk_6400k) begin
        char_valid_d <= char_valid;  // store previous value

        if (char_valid && !char_valid_d) begin  // detect rising edge
            // $write("%s", char_out);
            // $fwrite(outfile, "%s", char_out);
            $write("%c", char_out);
            $fwrite(outfile_fd, "%c", char_out);
        end
    end


  
  
  top #(
    .CIC_NIN                	(16        ),
    .CIC_NMAX               	(40        ),
    .CIC_NOUT               	(16        ),
    .DEMOD_OUT              	(7         ),
    .CLOCK_REC_OSR          	(CLOCK_REC_OSR        ),
    .SYS_CLK_FREQ           	(SYS_CLK_FREQ  ),
    .MIXING_FREQ            	(MIXING_FREQ   ),
    .DEMOD_FREQ             	(DEMOD_FREQ    ),
    .SAMPLE_RATE            	(SAMPLE_RATE       ),
    .SWEEP_SAMPLE_ACCUM_NUM 	(32        ),
    .TAPS                     (TAPS))
  u_top(
    .clk        	(clk_6400k         ),
    .rst        	(rstn              ),
    .en         	(en                ),
    .adc_in     	(adc_in            ),
    .char_out   	(char_out          ),
    .char_valid 	(char_valid        )
  );
  

initial begin
      $dumpfile("top_test.vcd");
      $dumpvars(0, top_test);
end

// Close file at end of sim
  final begin
    $fclose(outfile_fd);
  end


endmodule // test

