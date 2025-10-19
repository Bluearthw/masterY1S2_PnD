
module mix_vga_control #(
    parameter INPUT_WIDTH = 3  
)(
    input wire clk,             
    // input wire rstn,
    output reg  [5:0] vga_control_out,     // 6-bit output
	input wire [INPUT_WIDTH - 1:0] vga_control_in // 3-bit input
);


always @(posedge clk) begin
    // if(rstn == 0)begin
        vga_control_out <= 5'b00000;
    // end
    // else begin 
        if (vga_control_in == 0)
        begin
            vga_control_out <= 5'b00000;
        end
        else
        begin
            vga_control_out <= (1 << vga_control_in) - 1;
        end
    // end
    


end				
endmodule

