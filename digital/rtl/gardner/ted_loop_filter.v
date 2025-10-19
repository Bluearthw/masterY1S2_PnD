`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/22/2025 06:23:18 PM
// Design Name: 
// Module Name: ted_loop_filter
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


module ted_loop_filter #(
    parameter SPS_2 = 4   // 上采样率（采样速率与数据速率之比）的一半，
    )(
    input resetn,
    input clk,
    input strobe,  //boolean-like
    input signed [17:0] data_in,   //插值滤波器输出得插值数据
    output signed [17:0] data_out, //最佳采样时刻得插值数据，用于判决0、1
    output signed [15:0] wk,       //环路滤波器输出定时误差信号，15 bit小数位
    output sync             //位同步信号
    );
reg [3:0] strobe_cnt;
reg sk;//best sample instant
always @(posedge clk or negedge resetn) begin
    if(!resetn) begin
        strobe_cnt <= 4'd0;
        sk <= 1'b0;
    end
    else begin
        if(strobe) begin
            strobe_cnt <= (strobe_cnt >= SPS_2-1'b1)?4'd0:(strobe_cnt+1'b1);
            sk <= (strobe_cnt >= SPS_2-1'b1)?(1'b1):1'b0;  // sk翻转周期位符号周期，作为位定时时钟输出
        end
    end
end
assign sync = sk;
reg signed [17:0] din_1,din_2,din_3;
reg signed [17:0] dout;
reg signed [17:0] err,err_1;
reg signed [15:0] w;
always @(posedge clk or negedge resetn) begin
    if(!resetn) begin
        din_1 <= 18'd0;
        din_2 <= 18'd0;
        din_3 <= 18'd0;
        dout <= 18'd0;
        err <= 18'd0;
        err_1 <= 18'd0;
        w <= 16'b0100000000000000;
    end
    else begin
        if((strobe_cnt==0 || strobe_cnt==SPS_2-1) && strobe) begin
            din_1 <= data_in;
            din_2 <= din_1;
            din_3 <= din_2;
            err <= (!din_1[17] && din_3[17])?{din_2[17:1],1'b0}:((din_1[17] && !din_3[17])?(-{din_2[17:1],1'b0}):18'd0);
            //误差的简单实现 使用符号做过0判决 而不是真的计算误差
            //两个三目运算符 级联 别晕
            //注意d2被右移一位
            if(sk) begin
                dout <= din_1;
                err_1 <= err;
                //PI controller:w(ms+1)=w(ms)+c1*(err(ms)-err(ms-1))+c2*err(ms), c1 (p)= 2^(-8)， (I)c2≈0
                w <= w+{{6{err[17]}},err[17:8]}-{{6{err_1[17]}},err_1[17:8]};
            end
        end
    end
end
assign wk = w;
assign data_out = dout;  
endmodule
