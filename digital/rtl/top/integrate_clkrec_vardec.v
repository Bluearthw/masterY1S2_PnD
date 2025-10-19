`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/06/2025 05:52:51 PM
// Design Name: 
// Module Name: integrate_clkrec_vardec
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module integrate_clkrec_vardec#(
    parameter IN_WIDTH = 6,
    parameter OSR = 8
)(
    input  wire                       clk,//80k
    input  wire                       rst,
    input  wire                       enable,
    input  wire signed [IN_WIDTH-1:0] diff_phase_in,
    output wire [7:0] char_out,  // 输出解码后的 ASCII 字符
    output wire char_valid
    );

// output declaration of module clk_rec_zerox
wire symbol_sample_tick;
wire out_bit;

// output declaration of module varicode_decoder
wire [7:0] char_out_internal;
wire char_valid_internal;

clk_rec_zerox #(
    .IN_WIDTH 	(IN_WIDTH  ),
    .OSR      	(OSR  ))
u_clk_rec_zerox(
    .clk                	(clk                 ),
    .rst                	(rst                 ),
    .enable             	(enable              ),
    .diff_phase_in      	(diff_phase_in       ),
    .symbol_sample_tick 	(symbol_sample_tick  ),
    .out_bit            	(out_bit             )
);


varicode_decoder u_varicode_decoder(
    .clk        	(clk         ),
    .rst        	(rst         ),
    .bit_in     	(out_bit      ),
    .bit_valid  	(symbol_sample_tick   ),
    .char_out   	(char_out    ),
    .char_valid 	(char_valid  )
);
//assign output
assign char_out   = char_out_internal;
assign char_valid = char_valid_internal;

endmodule
