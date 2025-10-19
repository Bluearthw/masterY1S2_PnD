module clk_rec_zerox #(
    parameter IN_WIDTH = 6,
    parameter MAIN_CLK = 6400_000,
    parameter OSR = 8,
    parameter SYS_CLK_FREQ = 6400_000,
    parameter MIXING_FREQ  = 320_000,
    parameter DEMOD_FREQ   = 16_000,
    parameter SAMPLE_RATE  = 800 
)(
    input  wire                       clk,
    input  wire                       rst,
    input  wire                       enable,
    input  wire signed [IN_WIDTH-1:0] diff_phase_in, // phase difference input

    output reg symbol_sample_tick,  // pulse when midpoint reached
    output reg out_bit
);


    //----------------------------------------------------------
// Clock division -> enable 
// SAMPLE_RATE  = 800
// SAMPLE_DIV   = 64MHz / 800 = 80_000
//----------------------------------------------------------
localparam SAMPLE_DIV = SYS_CLK_FREQ / SAMPLE_RATE;
reg [31:0] enable_counter;
reg sample_en ;

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
    // Delay registers for zero crossing detection
    reg signed [IN_WIDTH-1:0] sample_previous;//, sample_d2;
    reg [OSR-1:0] sample_counter;

    /////////////////////// Detect zero crossing///////////////////////////////////
    // reg zero_cross;
    // assign zero_cross = (diff_phase_in[IN_WIDTH-1] != sample_previous[IN_WIDTH-1]);
    //buffer update
    reg sample_valid; //valid bit for buffer
    always@(posedge clk)begin
        if (!rst) begin
        sample_previous <= 0;
        sample_valid <= 0;  
    end else begin
        if(sample_en)begin   
            sample_previous <= diff_phase_in;
            sample_valid <= 1;  
        end else begin
            sample_previous <= sample_previous;
            sample_valid <= sample_valid;  
        end
    end
    end
    ////////////////////////////////////////////////FSM////////////////////////////////////////////
    localparam 
        IDLE        = 2'b00,
        SP_cross    = 2'b01,
        SP_wait     = 2'b10,
        SP_out      = 2'b11;

    reg [1:0] state,next_state;   
    //sync transition
    always@(posedge clk)
     state <= (!rst) ? IDLE : next_state; 
    ///////////////////////state transition/////////////////////////////
    always @(posedge clk) begin
        if (!rst) begin
            next_state <= IDLE;
        end else begin
            if (sample_en) begin
                case (state)
                IDLE: begin
                    if (enable&&sample_valid&&(diff_phase_in[IN_WIDTH-1] != sample_previous[IN_WIDTH-1])) begin
                        next_state <= SP_cross;
                    end
                    else begin
                        next_state <= IDLE;
                    end
                end
                SP_cross:begin
                        next_state <= SP_wait;
                end
                SP_wait:begin
                    next_state <= (sample_counter==OSR-1)?SP_out:SP_wait;
                end

                SP_out:begin
                    next_state <= SP_wait;
                end

                default:begin
                    next_state <= IDLE;
                end 
                endcase     
            end
            else begin
                next_state <= next_state;
            end
            
            
        end
    end
    ///////////////////////data update/////////////////////////////
    always @(posedge clk) begin
        if (!rst) begin
            sample_counter <= OSR>>1;//OSR/2
        end else begin
            if (sample_en) begin
                case (state)
                IDLE: begin
                    if (enable) begin
                        sample_counter <= (sample_counter==OSR)?1:sample_counter+1;//make sure when zerox doesnt come, still take sample
                        
                    end
                    else begin
                        sample_counter <= sample_counter;
                    end
                    
                end 
                SP_cross:begin
                    sample_counter <= (OSR>>1)+1;//next cycle should be OSR/2+1
                end
                SP_wait: begin
                    sample_counter <= sample_counter+1;
                end
                SP_out: begin
                    sample_counter <= 1;
                end
                default: begin
                    sample_counter <= OSR>>1;
                end
                endcase
            end
            else begin
                sample_counter <= sample_counter;       
            end
            
            
        end
    end
    always @(posedge clk) begin
        if (!rst) begin
           out_bit <= 'b0;
           symbol_sample_tick <= 0;
        end
        else begin
            if (sample_en) begin
                symbol_sample_tick <= (sample_counter==OSR-1)?1:0;
                out_bit <= (symbol_sample_tick) ? (((diff_phase_in+sample_previous)>>>1)>0):out_bit;
                //only update sample the midpoint when tick =1    
            end
            else begin
                symbol_sample_tick <= symbol_sample_tick;
                out_bit <= out_bit;
            end
           
        end
    end
endmodule
