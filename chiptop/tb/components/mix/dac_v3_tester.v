module dac_v3_tester (
    input clk, 
    input cmp, 
    output o_vin_ctrl, 
    output [7:0] o_vref_ctrl, 
	output [7:0] o_readout,
    output done
);

	/* 
		if ( ref_ctrl==0 & vin_ctrl==0 )
		 { out = vref+;}
		if ( ref_ctrl==1 & vin_ctrl==0 )
 		{ out = vref-;}
		if ( vin_ctrl==1 )
 		{ out = vin;}
	*/

    reg [7:0] vref_ctrl_cur = 8'b11111111; // Start with all bits high
    reg [7:0] vref_ctrl_nxt;
    reg vin_ctrl_cur = 1;
    reg vin_ctrl_nxt;
	reg [7:0] r_readout;

    reg [3:0] state_cur = 0;
    reg [3:0] state_nxt;

    reg [2:0] cnt_cur = 3'd7;
    reg [2:0] cnt_nxt;

    reg trial_bit = 0;

    always @(posedge clk) begin
        state_cur <= state_nxt;
        cnt_cur <= cnt_nxt;
        vref_ctrl_cur <= vref_ctrl_nxt;
        vin_ctrl_cur <= vin_ctrl_nxt;
		r_readout <= (state_cur == 4'd0) ? ~vref_ctrl_cur : r_readout;
    end

    always @(*) begin
        // Defaults
        state_nxt = state_cur;
        cnt_nxt = cnt_cur;
        vref_ctrl_nxt = vref_ctrl_cur;
        vin_ctrl_nxt = vin_ctrl_cur;

        case(state_cur)
            4'd0: begin // Sample VIN
				//enable vin
                vin_ctrl_nxt = 1;
				//vref-
                vref_ctrl_nxt = 8'b11111111; // Default high
				//init count, subtract and compare only after one compare is done
                cnt_nxt = 3'd7;
                state_nxt = 4'd1;
            end

            4'd1: begin //first compare
				//disconnect vin
                vin_ctrl_nxt = 0;
				//compare msb
                vref_ctrl_nxt = vref_ctrl_cur & ~(8'd1 << cnt_cur); // MSB
                state_nxt = 4'd2;
				cnt_nxt = cnt_cur;
            end

            4'd2: begin //repeate compare
    				//compare and set next bit            
				if (cmp == 1) begin
                    // Input > DAC
                    vref_ctrl_nxt = ( vref_ctrl_cur | (8'd1 << cnt_cur) ) & ~(8'd1 << cnt_cur-1);
                end else begin
                    // Input <= DAC 
                    vref_ctrl_nxt = ( vref_ctrl_cur & ~(8'd1 << cnt_cur) ) & ~(8'd1 << cnt_cur-1);
                end

                if (cnt_cur == 0) begin
                    //state_nxt = 4'd3; // Done
					 vin_ctrl_nxt = 1; // Optional: return to sampling
                		state_nxt = 4'd0; // Restart
                end else begin
                    cnt_nxt = cnt_cur - 1;
                    state_nxt = 4'd2; // Next bit
                end
            end

           /* 4'd3: begin
                vin_ctrl_nxt = 1; // Optional: return to sampling
                state_nxt = 4'd0; // Restart
            end
			*/

            default: begin
                state_nxt = 4'd0;
                vref_ctrl_nxt = 8'b11111111;
                vin_ctrl_nxt = 1;
                cnt_nxt = 3'd7;
            end
        endcase
    end

    assign o_vref_ctrl = vref_ctrl_cur;
    assign o_vin_ctrl = vin_ctrl_cur;
    assign done = (state_cur == 4'd0);
	assign o_readout = r_readout;

endmodule
