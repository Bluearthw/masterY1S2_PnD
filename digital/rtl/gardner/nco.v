module nco(
    input resetn,
    input clk,
    input signed [15:0] wk,    //环路滤波器输出定时误差信号，15 bit小数位
    output signed [15:0] uk,   //NCO输出的插值间隔小数，15 bit小数位
    output strobe       //NCO输出的插值计算选通信号，高电平有效
    );
//每隔Ts， nco递减wk，wk越大减的速率越快，下溢出输出一个strobe
reg signed [16:0] nkt;
reg signed [16:0] ut;
reg str;
always @(posedge clk or negedge resetn) begin
    if(!resetn) begin
        nkt <= 17'b00110000000000000;   //0.75
        ut <= 17'b00100000000000000;    //0.5
        str <= 1'b0;
    end
    else begin
        if(nkt < {wk[15],wk}) begin // 负值+1，相当于mod(1);
            nkt <= 17'b01000000000000000+nkt-{wk[15],wk};
            ut <= {nkt[14:0],1'b0}; //取出nkt减去wk之前的值，乘以2作为u值输出
            str <= 1'b1; //underflow, enable
        end
        else begin
            nkt <= nkt-{wk[15],wk};
            str <= 1'b0;
        end
    end
end
assign uk = ut;
assign strobe = str;
endmodule
