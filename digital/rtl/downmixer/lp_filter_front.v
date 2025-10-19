module lp_filter_front#(
    parameter TAPS        = 6,
    parameter DATA_WIDTH  = 16,
    parameter SYS_CLK_FREQ = 6400_000,
    parameter MIXING_FREQ  = 320_000,
    parameter DEMOD_FREQ   = 16_000,
    parameter SAMPLE_RATE  = 800 
)(
    input clk,
    input rst,
    input start,
    input signed [DATA_WIDTH-1:0] sample_in,
    output reg signed [DATA_WIDTH-1:0] sample_out
    );

//----------------------------------------------------------
// Clock division -> enable 
// SAMPLE_RATE  = 320kHz
// SAMPLE_DIV   = 64MHz / 320kHz = 20
//----------------------------------------------------------
localparam SAMPLE_DIV = SYS_CLK_FREQ / MIXING_FREQ;
reg [31:0] sample_counter = 0;
reg sample_en = 0;

always @(posedge clk or negedge rst) begin
    if(!rst) begin
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
    
        
    reg signed [DATA_WIDTH - 1:0] FIR [0:TAPS-1];
    
    reg signed [10:0] acc;
                      
    integer i;

    always @ (posedge clk) begin
        if (!rst) begin // initialize the filter
            for (i = 0; i <= TAPS; i = i + 1) FIR[i] <= 0; 
        end
        
        else if(start && sample_en) begin
            // shift the signal
            FIR[0] <= sample_in;
            for (i = 1; i <= TAPS; i = i + 1) FIR [i] <= FIR[i - 1];
            acc <=       FIR[0]  +
                         FIR[1]  +
                         FIR[2]  +
                         FIR[3]  +
                         FIR[4]  +
                         FIR[5]  ;
        end else
            for (i = 0; i <= TAPS; i = i + 1) FIR[i] <= FIR[i]; 
    end                
    always@(clk)
        sample_out <= acc>>3;
  
endmodule