//Verilog HDL for "PnD", "mix_level_detect" "functional"



///////////////
// now it can only lower the gain!
///////////////////
module mix_level_detect (
 input wire [7:0] digital_in,
 input wire clk,
 input wire rst_n, 
 output reg [2:0] vga_control
 );

reg[7:0] counter_low;
reg[7:0] counter_high;
reg[8:0] counter; //periodically clear, incase cumulative error
reg[1:0] dropFrom;
reg raiseFrom;
reg[2:0] vga_control_next = 0;
reg [3:0] state_current;
reg [3:0] state_next;
//0 idle
localparam IDLE      = 4'd0,
           LOW_COUNT = 4'd1,
           HIGH_COUNT = 4'd2,
           ADJUST_DOWN = 4'd3,
           ADJUST_UP = 4'd4;

always@(posedge clk)begin
// rest part////////////////////
	if(rst_n == 0)
	begin
		counter_high <= 0;
		counter_low <= 0;
		dropFrom <= 0;
		raiseFrom <= 0;
		vga_control <= 0;
		counter<= 0;
		// state_current <= 0;
	end
	else
	begin
		// counter_high <= counter_high;
		// counter_low <= counter_low;
		
		// state_current <= state_next;
		// vga_control <= vga_control_next;
		// counting flags////////////////											
		if(digital_in[7:3] == 6'b10000 )
		begin
			if(counter_low == 50)//16M clk, 20k 16M/20k = 800. so 800 clk per period. 100 sample per period
			begin //if gain is too low
				counter_low <= 0;

			end
			else
			begin
				counter_low <= counter_low + 1;
				
			end 
			counter_high <= 0;// not too high, so clear
		end
		else if(digital_in[7:5] == 3'b111 || digital_in[7:5] == 3'b000)// if MSB is high
		begin
			if(counter_high == 50)
			begin
				counter_high <= 0;
				
			end
			else
			begin

				counter_high <= counter_high + 1;
			end	
			counter_low <= 0;//high detect, clear
		end
		else begin 
			counter_high <= counter_high;
			counter_low <= counter_low;
			
		end

		
		
		if(counter_low == 50)//16M clk, 20k 16M/20k = 800. so 800 clk per period. 100 sample per period
		begin

			vga_control <= vga_control - 1;
			raiseFrom <= raiseFrom + 1;
		end
		else
		begin
			vga_control <= vga_control;
			raiseFrom <= raiseFrom;
			
		end 
		
		if(counter_high == 50)
		begin
			if (vga_control == 7)
			begin
				vga_control <= vga_control; //nothing more we can do 
				dropFrom <= dropFrom;
			end
			else
			begin 
				vga_control <= vga_control + 1;
				dropFrom <= dropFrom + 1;

			end
		end
		else
		begin
			vga_control <= vga_control;
			dropFrom <= dropFrom;
		end 

		if(counter == 300)
			counter <= counter;
		else
			counter <= counter +1;


	end		


	
	//if(dropFrom == 2)
end		
	
// reg low_flag;
// always@(*)begin

// case (state_current)
//         IDLE: begin
//             if (digital_in[7] == 0)
// 			begin 
// 				low_flag = 1;
//                 state_next = LOW_COUNT;
// 			end
//             else
// 			begin 
// 				low_flag = 0;
//                 state_next = HIGH_COUNT;
// 			end

//         end

//         LOW_COUNT: begin
//             if (digital_in[7] == 0) begin
//                 low_flag = 1;
//                 state_next = LOW_COUNT;
//             end 
// 			else begin
//                 low_flag = 0;
//                 state_next = LOW_COUNT;
//             end
//         end

      
//         default: begin 
// 			state_next = IDLE;
// 			low_flag = 0;
// 		end 
// endcase
// end

	





endmodule
