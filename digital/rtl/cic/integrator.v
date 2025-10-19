//3 stages integrator
module integrator
    #(parameter NIN     = 16,
      parameter NOUT    = 40,
      parameter SYS_CLK_FREQ = 6400_000,
      parameter MIXING_FREQ  = 320_000,
      parameter DEMOD_FREQ   = 16_000,
      parameter SAMPLE_RATE  = 800 )
    (
      input               clk ,
      input               rstn ,
      input               en ,
      input  signed [NIN-1:0]     din ,
      output              valid ,
      output signed [NOUT-1:0]   dout) ;
      

   //----------------------------------------------------------
   // Clock division -> enable 
   // mixing rate  = 320kHz
   // SAMPLE_DIV = 64MHz / 320kHz = 20
   //----------------------------------------------------------
   localparam SAMPLE_DIV = SYS_CLK_FREQ / MIXING_FREQ;
   reg [31:0] sample_counter = 0;
   reg sample_en = 0;

   always @(posedge clk or negedge rstn) begin
      if(!rstn) begin
         sample_counter <= 0;
         sample_en <= 0;
      end else begin
         if(sample_counter == SAMPLE_DIV-1) begin
               sample_counter <= 0;
               sample_en <= 1;
         end else begin
               sample_counter <= sample_counter + 1;
               sample_en <= 0;
         end
      end
   end

   reg signed [NOUT-1:0]         int_d0  ;
   reg signed [NOUT-1:0]         int_d1  ;
  // reg [NOUT-1:0]         int_d2  ;
   wire signed [NIN-1:0]        sxtx;
   assign sxtx = {{(NOUT-NIN){1'b0}}, din} ;

   //data input enable delay
   reg [1:0]              en_r ;
   always @(posedge clk or negedge rstn) begin
      if (!rstn) begin
         en_r   <= 'b0 ;
      end
      else if(sample_en) begin
         en_r   <= {en_r[1:0], en};
      end else begin
         en_r  <= en_r;
      end
   end

   //integrator
   //stage1
   always @(posedge clk or negedge rstn) begin
      if (!rstn) begin
         int_d0        <= 'b0 ;
      end
      else if (sample_en&&en) begin
         int_d0        <= int_d0 + sxtx ;
      end
      else begin
         int_d0        <= int_d0;
      end
   end

   //stage2
   always @(posedge clk or negedge rstn) begin
      if (!rstn) begin
         int_d1        <= 'b0 ;
      end
      else if (sample_en&&en_r[0]) begin
         int_d1         <= int_d1 + int_d0 ;
      end else begin
         int_d1  <= int_d1;
      end
   end

//    //stage3
//    always @(posedge clk or negedge rstn) begin
//        if (!rstn) begin
//            int_d2        <= 'b0 ;
//        end
//        else if (en_r[1]) begin
//            int_d2        <= int_d2 + int_d1 ;
//        end
//    end
    assign dout  = int_d1 ;
    assign valid = en_r[1];

endmodule
