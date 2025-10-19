module dds_cordic
    (
    input           clk,            //reference clock
    input           rstn ,          //resetn, low effective
    input           sweep_flag,     //initial phase
    input [15:0]     f_word ,        //frequency control word

    output wire signed [7:0]    sin_dout,           //data out, 10bit width
    output wire signed [7:0]    cos_dout          //data out, 10bit width
);
    
    wire                  finished;     
    reg [15:0]            phase_acc_r ;

    // FSM states
   
    parameter    IDLE = 3'd0;
    parameter    INIT= 3'd1;
    parameter    GEN = 3'd2;
    parameter    WAIT = 3'd3;
    parameter    DONE = 3'd4;
    parameter    REVERT = 3'd5;

    reg[2:0] state, next_state;

    // state transition
    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            state <=IDLE;
        end else begin
            state <= next_state;
        end
    end

   

    //Next state logic
    always @(*) begin
        case (state)
            IDLE:  next_state = GEN;
            INIT:  next_state = GEN;
            GEN:   next_state = WAIT;
            WAIT:  next_state = (finished)? DONE:WAIT; 
            DONE:  next_state = (sweep_flag)? INIT:GEN;
            //REVERT:next_state = WAIT;
            default: next_state = IDLE;
        endcase
    end

    //phase acculator
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            phase_acc_r    <= 'b0 ;
        end
        else if (state == INIT) begin
            phase_acc_r    <= 'b0 ;
        end
        else if (state == DONE) begin
                phase_acc_r <= phase_acc_r + f_word ;
        end
        else if (phase_acc_r > 'd36000) begin
                phase_acc_r <= phase_acc_r - 'd36000;
        end
        else begin
            phase_acc_r    <= phase_acc_r ;
        end
    end

   reg start;


    always @(*) begin
        case (state)
            IDLE:  start = 0;
            INIT:  start = 0;
            GEN:   start = 1;
            WAIT:  start = 1; 
            DONE:  start = 0;
            REVERT:start = 1;
            default: start = 0;
        endcase
    end


    //add cordic code here
    wire signed [7:0] sin_dout_temp;
    wire signed [7:0] cos_dout_temp;
    reg signed [7:0] r_sin_out;
    reg signed [7:0] r_cos_out;
 

    cordic u_cordic(
        .clk (clk),
        .rst_n(rstn),
        .angle(phase_acc_r),
        .start(start),
        .finished(finished),
        .Sin(sin_dout_temp),
        .Cos(cos_dout_temp)
    );


    //output registers
    always @(posedge clk) begin
        if(state == DONE) begin
            r_sin_out <= sin_dout_temp;
            r_cos_out <= cos_dout_temp;
        end
        else begin
            r_sin_out <= r_sin_out;
            r_cos_out <= r_cos_out;
        end

    end

   
    assign       sin_dout = -1*r_sin_out; 
    assign       cos_dout = r_cos_out; 
endmodule