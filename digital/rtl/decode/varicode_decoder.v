`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/21/2025 06:14:25 PM
// Design Name: 
// Module Name: varicode_decoder
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


module varicode_decoder#(
    parameter OSR = 8,
    parameter BR  = 100,
    parameter SYS_CLK_FREQ = 6400_000,
    parameter MIXING_FREQ  = 320_000,
    parameter DEMOD_FREQ   = 16_000,
    parameter SAMPLE_RATE  = 800   
)(
    input wire clk,
    input wire rst,
    input wire bit_in,               // 串行输入 0 或 1
    input wire bit_valid,            // 高电平表示当前 bit 有效
    output wire [7:0] char_out,  // 输出解码后的 ASCII 字符
    output reg char_valid       // 高电平表示 char_out 有效
    );

   //----------------------------------------------------------
// Clock division -> enable 
// SAMPLE_RATE  = 800
// SAMPLE_DIV   = 64MHz / 800 = 80_000
//----------------------------------------------------------
localparam SAMPLE_DIV = SYS_CLK_FREQ / SAMPLE_RATE;
reg [31:0] enable_counter;
reg sample_en;
//clock enable
always @(posedge clk or negedge rst) begin
    if(!rst) begin
        enable_counter <= 0;
        sample_en <= 0;
    end else begin
        if(enable_counter == SAMPLE_DIV-1) begin
            enable_counter <= 0;
            sample_en <= 1;
        end else begin
            enable_counter <= enable_counter + 1;
            sample_en <= 0;
        end
    end
end
//buffer
reg [15:0] shift_reg;   // TODO: there is a 4-bit margin, maybe change the width here later
reg [3:0] bit_count;     // 统计 shift_reg 中的有效位数
reg [1:0] zero_count;    // 连续 0 计数器
reg [1:0] previous_two;
reg [9:0] varicode;// temporary varicode buffer
//LUT
// output declaration of module varicode_lut
wire [7:0] ascii;

varicode_lut u_varicode_lut(
    .enable   	(char_valid),
    .varicode 	(varicode  ),
    .ascii    	(ascii  )
);


////////////////////////////////////////////////FSM////////////////////////////////////////////
localparam 
    IDLE        = 3'b000,
    RECV        = 3'b001,
    END_CHECK   = 3'b010,
    DECODE      = 3'b011,
    ERROR       = 3'b100;

reg [2:0] state;    
////////////////state transition/////////////////
always @(posedge clk or negedge rst) begin
    if (!rst) begin
      state<= IDLE;
    end else begin
        if(bit_valid&&sample_en)begin
            case (state)
            IDLE://wait for 00 sequence
                begin
                    if ((shift_reg[1:0]==2'b00)&&(bit_in!=0)) begin //when there is a 001 sequence a real word arrives, prevent consecutive 0s.
                        state<= RECV;
                    end else begin
                        state<= IDLE;
                    end
                end
            RECV:
                begin
                    if (bit_in==1) begin
                        state<= RECV;
                    end else begin
                        state<= END_CHECK;
                    end
                end
            END_CHECK:
                begin
                    if (bit_in==1) begin
                        state<= RECV;
                    end else begin
                        state<= DECODE;
                    end
                end       
            DECODE:
                begin
                    if (bit_in==1) begin
                        state<= RECV;
                    end else begin
                        state<= IDLE;
                    end
                end 
            default: 
                state<= IDLE;
            endcase
        end else begin
            state<= state;
        end
end
end
//////////////////datapath/////////////////
always @(posedge clk) begin
    if (!rst) begin
        shift_reg <= 16'b11111111_11111111;
    end else begin
        shift_reg <=(bit_valid&&sample_en)?{shift_reg[14:0],bit_in}:shift_reg;
    end
end
//TODO: consider when bitcount exceed 10, throw an exception
//buffer and output
always @(posedge clk) begin
    if (!rst) begin
        bit_count <= 0;
        varicode <= 10'b0;
        char_valid <= 0;
    end
    else begin
        if (bit_valid&&sample_en) begin
           case (state)
            IDLE:
            begin
                bit_count  <= 0;
                varicode   <= varicode;
                char_valid <= 0;
            end
                
            RECV:
            begin
                bit_count<= bit_count+1;
                varicode <= varicode;
                char_valid <= 0;
            end
            END_CHECK:
            begin
                bit_count<= bit_count+1;
                varicode <= varicode;
                char_valid <= 0;
            end       
            DECODE:
            begin 
                //FIXME: verify if there is a concurrency problem here
                case (bit_count-1)
                1: varicode <= {9'd0, shift_reg[2]};
                2: varicode <= {8'd0, shift_reg[3:2]};
                3: varicode <= {7'd0, shift_reg[4:2]};
                4: varicode <= {6'd0, shift_reg[5:2]};
                5: varicode <= {5'd0, shift_reg[6:2]};
                6: varicode <= {4'd0, shift_reg[7:2]};
                7: varicode <= {3'd0, shift_reg[8:2]};
                8: varicode <= {2'd0, shift_reg[9:2]};
                9: varicode <= {1'd0, shift_reg[10:2]};
                10: varicode <= shift_reg[11:2];
                default: varicode <= 10'd0;
                endcase
                bit_count <= 0; //reset
                char_valid <= 1;
            end
                
            default: 
            begin
                bit_count <= 0;
                shift_reg <= 15'b0;
                varicode <= 10'b0;
            end   
            endcase   
        end else begin
            bit_count<= bit_count;
            varicode <= varicode;
            char_valid <= char_valid;
        end
          
    end 
end
////////////////////output
assign char_out = ascii;  

endmodule

