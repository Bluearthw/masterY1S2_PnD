`timescale 1ns / 1ps

module demod_gmsk #(
      parameter SYS_CLK_FREQ = 6400_000,
      parameter MIXING_FREQ  = 320_000,
      parameter DEMOD_FREQ   = 16_000,
      parameter SAMPLE_RATE  = 800,
      parameter TAPS         = 4 
)(
    input  signed [15:0] I,     
    input  signed [15:0] Q,    
    input         start,
    input         resetn,     
    input         clk,        // 800*20 = 16kHz
    output reg  [8:0] phase,  // CORDIC output phase
    output wire signed  [6:0] freq // 
);

//----------------------------------------------------------
// Clock division -> enable 
// SAMPLE_RATE  = 800
// SAMPLE_DIV   = 64MHz / 800 = 80_000
//----------------------------------------------------------
localparam SAMPLE_DIV = SYS_CLK_FREQ / SAMPLE_RATE;
reg [31:0] sample_counter;
reg sample_en;

always @(posedge clk or negedge resetn) begin
    if(!resetn) begin
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

wire       cordic_valid;
wire       one_start;
wire [8:0] cordic_phase;


reg  [8:0]  prev_phase = 0;
reg  signed [6:0]  freq_origin = 0;


always @(posedge clk) begin
    if (!resetn) begin
        phase             <= 0;
        freq_origin       <= 0;
        prev_phase        <= 0;
    end 
    else if (sample_en && start ) begin
        phase               <= cordic_phase;

        if (({cordic_phase[8],cordic_phase[7]}=='b00) &&  (prev_phase[8]==1)) begin
            freq_origin     <= (cordic_phase - prev_phase) + 360;
        end 
        else if ((cordic_phase[8] == 1) &&({prev_phase[8],prev_phase[7]}=='b00)) begin
            freq_origin     <= (cordic_phase - prev_phase) - 360;
        end 
        else begin
            freq_origin     <= cordic_phase - prev_phase;
        end

        prev_phase          <= cordic_phase;
    end else begin
        freq_origin       <= freq_origin;
        prev_phase        <= prev_phase;
        phase             <= phase;
    end
end


cordic_vector#(
    .SYS_CLK_FREQ 	(SYS_CLK_FREQ  ),
    .MIXING_FREQ  	(MIXING_FREQ   ),
    .DEMOD_FREQ   	(DEMOD_FREQ    ),
    .SAMPLE_RATE  	(SAMPLE_RATE   ))
 u_cordic_vector(
    .clk      	(clk       ),
    .rst_n    	(resetn     ),
    .x        	(I         ),
    .y        	(Q         ),
    .start    	(start     ),
    .angle    	(cordic_phase  ),
    .finished 	(cordic_valid  )
);

assign freq = freq_origin;

// lp_filter_demod #(
//     .TAPS         	(TAPS      ),
//     .DATA_WIDTH   	(6         ),
//     .SYS_CLK_FREQ 	(SYS_CLK_FREQ  ),
//     .MIXING_FREQ  	(MIXING_FREQ   ),
//     .DEMOD_FREQ   	(DEMOD_FREQ    ),
//     .SAMPLE_RATE  	(SAMPLE_RATE       ))
// u_lp_filter_demod(
//     .clk        	(clk         ),
//     .rst        	(resetn         ),
//     .start      	(start       ),
//     .sample_in  	(freq_origin   ),
//     .sample_out 	(freq  )
// );




endmodule
