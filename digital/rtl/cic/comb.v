module comb
    #(parameter NIN  = 40,
      parameter NOUT = 16,
      parameter SYS_CLK_FREQ = 6400_000,
      parameter MIXING_FREQ  = 320_000,
      parameter DEMOD_FREQ   = 16_000,
      parameter SAMPLE_RATE  = 800 )
    (
     input                             clk,
     input                            rstn,
     input                              en,
     input  signed[NIN-1:0]            din,
     output wire                     valid,
     output wire signed[NOUT-1:0]    dout);



   //----------------------------------------------------------
   // Clock division -> enable 
   // mixing rate  = 320kHz
   // SAMPLE_DIV = 64MHz / 320kHz = 20
   //----------------------------------------------------------
   localparam SAMPLE_DIV = SYS_CLK_FREQ / MIXING_FREQ;
   reg [31:0] sample_counter;
   reg sample_en;

   always @(posedge clk or negedge rstn) begin
      if(!rstn) begin
         sample_counter <= 0;
         sample_en <= 0;
      end else begin
         if(sample_counter == SAMPLE_DIV-1) begin
               sample_counter <= 0;
               sample_en <= 0;
         end else if(sample_counter == 0) begin
               sample_counter <= 1;
               sample_en <= 0;
         end else begin
               sample_counter <= sample_counter + 1;
               sample_en <= 0;
         end
      end
   end

   //en delay
   reg [3:0]                 en_r ;
   always @(posedge clk or negedge rstn) begin
      if (!rstn) begin
         en_r <= 'b0 ;
      end
      else if (en) begin
         en_r <= {en_r[2:0], en} ;
      end else begin
         en_r <= en_r;
      end

   end


    reg  signed [NIN-1:0]            d1, d1_d, d2, d2_d ;
   //stage 1, as fir filter, shift and add(sub), no need for multiplier
   always @(posedge clk or negedge rstn) begin
      if (!rstn)        d1     <= 'b0 ;
      else if (en)      d1     <= din ;
      else              d1 <= d1;
   end
   always @(posedge clk or negedge rstn) begin
      if (!rstn)        d1_d   <= 'b0 ;
      else if (en)      d1_d   <= d1 ;
      else              d1_d <= d1_d;
   end
   wire signed [NIN-1:0]      s1_out;
   assign s1_out = d1 - d1_d ;

   //stage 2
   always @(posedge clk or negedge rstn) begin
      if (!rstn)        d2     <= 'b0 ;
      else if (en)      d2     <= s1_out ;
      else              d2 <= d2;
   end
   always @(posedge clk or negedge rstn) begin
      if (!rstn)        d2_d   <= 'b0 ;
      else if (en)      d2_d   <= d2 ;
      else              d2_d <= d2_d;
   end
   wire signed [NIN-1:0]      s2_out;
   assign s2_out = d2 - d2_d ;

  
    //tap the output data for better display
    reg [NOUT-1:0]       dout_r ;
    reg                  valid_r ;
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            dout_r         <= 'b0 ;
            valid_r        <= 'b0 ;
        end
        else if (en) begin
            dout_r         <= s2_out[30:15] ;
            valid_r        <= 1'b1 ;
        end
        else begin
            dout_r         <= dout_r ;
            valid_r        <= 1'b0 ;
        end
    end
  
   assign       dout    = dout_r;
   assign       valid   = valid_r ;

endmodule
