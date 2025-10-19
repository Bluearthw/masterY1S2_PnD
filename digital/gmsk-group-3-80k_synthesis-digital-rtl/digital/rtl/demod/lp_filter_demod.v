module lp_filter_demod#(
    parameter TAPS        = 4,
    parameter DATA_WIDTH  = 7,
    parameter SYS_CLK_FREQ = 6400_000,
    parameter MIXING_FREQ  = 320_000,
    parameter DEMOD_FREQ   = 16_000,
    parameter SAMPLE_RATE  = 800 
)(
    input clk,
    input rst,
    input start,
    input signed [DATA_WIDTH-1:0] sample_in,
    output wire signed [DATA_WIDTH-1:0] sample_out
    );

//----------------------------------------------------------
// Clock division -> enable 
// SAMPLE_RATE  = 800Hz
// SAMPLE_DIV   = 64MHz / 800Hz = 80_000
//----------------------------------------------------------
localparam SAMPLE_DIV = SYS_CLK_FREQ / SAMPLE_RATE;
reg [31:0] sample_counter;
reg sample_en;

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
            for (i = 0; i < TAPS; i = i + 1) FIR[i] <= 0; 
             acc <= 0;
        end
        
        else if(start && sample_en) begin
            // shift the signal
            FIR[0] <= sample_in;
            for (i = 1; i < TAPS; i = i + 1) FIR [i] <= FIR[i - 1];
            acc <=       FIR[0]  +
                         FIR[1]  +
                         FIR[2]  +
                         FIR[3];
        end else begin
            for (i = 0; i < TAPS; i = i + 1) FIR[i] <= FIR[i]; 
            acc <= acc;
        end
    end                

    assign sample_out = acc[8:3];
  
endmodule