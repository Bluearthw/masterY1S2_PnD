module hamming_filter#(
    parameter TAPS        = 16,
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
    
    // FILTER COEFFICIENTS
    // 31 + 1 = 32 taps 
    parameter h0  = 16'sd173;
    parameter h1  = 16'sd288;
    parameter h2  = 16'sd548;
    parameter h3  = 16'sd1001;
    parameter h4  = 16'sd1691;
    parameter h5  = 16'sd2633;
    parameter h6  = 16'sd3787;
    parameter h7  = 16'sd5053;
    parameter h8  = 16'sd5053;
    parameter h9  = 16'sd3787;
    parameter h10 = 16'sd2633;
    parameter h11 = 16'sd1691;
    parameter h12 = 16'sd1001;
    parameter h13 = 16'sd548;
    parameter h14 = 16'sd288;
    parameter h15 = 16'sd173;
    
    
    reg signed [DATA_WIDTH - 1:0] FIR [0:TAPS-1];
    
    reg signed [33:0] acc;
                      
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
            acc <=      h0   * FIR[0]  +
                        h1   * FIR[1]  +
                        h2   * FIR[2]  +
                        h3   * FIR[3]  +
                        h4   * FIR[4]  +
                        h5   * FIR[5]  +
                        h6   * FIR[6]  +
                        h7   * FIR[7]  +
                        h8   * FIR[8]  +
                        h9   * FIR[9]  +
                        h10  * FIR[10]  +
                        h11  * FIR[11]  +
                        h12  * FIR[12]  +
                        h13  * FIR[13]  +
                        h14  * FIR[14]  +
                        h15  * FIR[15];
        end else begin
            for (i = 0; i < TAPS; i = i + 1) FIR[i] <= FIR[i]; 
            acc <= acc;
        end
    end                
    
    assign sample_out = acc[32:17];
  
endmodule
