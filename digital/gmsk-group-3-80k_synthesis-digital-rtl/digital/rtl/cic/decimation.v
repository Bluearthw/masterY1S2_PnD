module  decimation
    #(parameter NDEC = 40,
      parameter SYS_CLK_FREQ = 6400_000,
      parameter MIXING_FREQ  = 320_000,
      parameter DEMOD_FREQ   = 16_000,
      parameter SAMPLE_RATE  = 800 )
    (
     input                             clk,
     input                            rstn,
     input                              en,
     input  signed[NDEC-1:0]           din,
     output wire                     valid,
     output wire signed[NDEC-1:0]    dout);

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
            sample_en <= 1;
        end else begin
            sample_counter <= sample_counter + 1;
            sample_en <= 0;
        end
    end
end

   reg                  valid_r ;
   reg [8:0]            cnt ;
   reg [NDEC-1:0]       dout_r ;

   //counter
   always @(posedge clk or negedge rstn) begin
      if (!rstn) begin
         cnt <= 'b0;
      end else if (sample_en)begin
         if (en) begin
            if (cnt== 'd199) begin
               cnt <= 'b0 ;
            end
            else begin
               cnt <= cnt + 'd1 ;
            end
         end
      end else begin
          cnt <= cnt;
      end
   end

   //data, valids
   always @(posedge clk or negedge rstn) begin
      if (!rstn) begin
         valid_r        <= 'd0 ;
         dout_r         <= 'd0 ;
      end
      else if (sample_en) begin
         if (en) begin
            if (cnt== 'd199) begin
               valid_r     <= 1'd1;
               dout_r      <= din;
            end
            else begin
               dout_r      <= dout_r;
               valid_r     <= 1'b0;
            end
         end else begin
               dout_r      <= dout_r;
               valid_r     <= 1'b0 ;
         end
      end else begin
               dout_r      <= dout_r;
               valid_r     <= 1'b0 ;
      end
      
   end

   assign dout          = dout_r ;
   assign valid         = valid_r ;

endmodule
