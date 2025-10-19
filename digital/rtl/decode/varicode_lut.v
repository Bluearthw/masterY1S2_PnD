module varicode_lut (
    input enable,
    input [9:0] varicode, 
    output reg [7:0] ascii  
);
    always @(*) begin
        if(enable==1) begin
        case(varicode)
            10'b1:          ascii = 8'h20;
            10'b111111111:  ascii = 8'h21; 
            10'b101011111:  ascii = 8'h22; 
            10'b111110101:  ascii = 8'h23; 
            10'b111011011:  ascii = 8'h24; 
            10'b1011010101: ascii = 8'h25; 
            10'b1010111011: ascii = 8'h26; 
            10'b101111111:  ascii = 8'h27; 
            10'b11111011:   ascii = 8'h28; 
            10'b11110111:   ascii = 8'h29; 
            10'b101101111:  ascii = 8'h2a; 
            10'b111011111:  ascii = 8'h2b; 
            10'b1110101:    ascii = 8'h2c; 
            10'b110101:     ascii = 8'h2d; 
            10'b1010111:    ascii = 8'h2e; 
            10'b110101111:  ascii = 8'h2f; 
            10'b10110111:   ascii = 8'h30; 
            10'b10111101:   ascii = 8'h31; 
            10'b11101101:   ascii = 8'h32; 
            10'b11111111:   ascii = 8'h33; 
            10'b101110111:  ascii = 8'h34; 
            10'b101011011:  ascii = 8'h35; 
            10'b101101011:  ascii = 8'h36; 
            10'b110101101:  ascii = 8'h37; 
            10'b110101011:  ascii = 8'h38; 
            10'b110110111:  ascii = 8'h39; 
            10'b11110101:   ascii = 8'h3a; 
            10'b110111101:  ascii = 8'h3b; 
            10'b111101101:  ascii = 8'h3c; 
            10'b1010101:    ascii = 8'h3d;
            10'b111010111:  ascii = 8'h3e;
            10'b1010101111: ascii = 8'h3f;
            10'b1010111101: ascii = 8'h40;
            10'b1111101:    ascii = 8'h41;
            10'b11101011:   ascii = 8'h42;
            10'b10101101:   ascii = 8'h43;
            10'b10110101:   ascii = 8'h44;
            10'b1110111:    ascii = 8'h45;
            10'b11011011:   ascii = 8'h46;
            10'b11111101:   ascii = 8'h47;
            10'b101010101:  ascii = 8'h48;
            10'b1111111:    ascii = 8'h49;
            10'b111111101:  ascii = 8'h4a;
            10'b101111101:  ascii = 8'h4b;
            10'b11010111:   ascii = 8'h4c;
            10'b10111011:   ascii = 8'h4d;
            10'b11011101:   ascii = 8'h4e;
            10'b10101011:   ascii = 8'h4f;
            10'b11010101:   ascii = 8'h50;
            10'b111011101:  ascii = 8'h51;
            10'b10101111:   ascii = 8'h52;
            10'b1101111:    ascii = 8'h53;
            10'b1101101:    ascii = 8'h54;
            10'b101010111:  ascii = 8'h55;
            10'b110110101:  ascii = 8'h56;
            10'b101011101:  ascii = 8'h57;
            10'b101110101:  ascii = 8'h58;
            10'b101111011:  ascii = 8'h59;
            10'b1010101101: ascii = 8'h5a;
            10'b111110111:  ascii = 8'h5b;
            10'b111101111:  ascii = 8'h5c;
            10'b111111011:  ascii = 8'h5d;
            10'b1010111111: ascii = 8'h5e;
            10'b101101101:  ascii = 8'h5f;
            10'b1011011111: ascii = 8'h60;
            10'b1011:       ascii = 8'h61;
            10'b1011111:    ascii = 8'h62;
            10'b101111:     ascii = 8'h63;
            10'b101101:     ascii = 8'h64;
            10'b11:         ascii = 8'h65;
            10'b111101:     ascii = 8'h66;
            10'b1011011:    ascii = 8'h67;
            10'b101011:     ascii = 8'h68;
            10'b1101:       ascii = 8'h69;
            10'b111101011:  ascii = 8'h6a;
            10'b10111111:   ascii = 8'h6b;
            10'b11011:      ascii = 8'h6c;
            10'b111011:     ascii = 8'h6d;
            10'b1111:       ascii = 8'h6e;
            10'b111:        ascii = 8'h6f;
            10'b111111:     ascii = 8'h70;
            10'b110111111:  ascii = 8'h71;
            10'b10101:      ascii = 8'h72;
            10'b10111:      ascii = 8'h73;
            10'b101:        ascii = 8'h74;
            10'b110111:     ascii = 8'h75;
            10'b1111011:    ascii = 8'h76;
            10'b1101011:    ascii = 8'h77;
            10'b11011111:   ascii = 8'h78;
            10'b1011101:    ascii = 8'h79;
            10'b111010101:  ascii = 8'h7a;
            10'b1010110111: ascii = 8'h7b;
            10'b110111011:  ascii = 8'h7c;
            10'b1010110101: ascii = 8'h7d;
            10'b1011010111: ascii = 8'h7e;
            10'b1110110101: ascii = 8'h7f;
            default:        ascii = 8'h00;   
        endcase
        end
        else begin
            ascii = 8'h00;//NUL
        end
    end
endmodule