  module bit_sync #(
    parameter SPS_2 = 2,   // 上采样率（采样速率与数据速率之比）的一半，
    parameter IN_WIDTH = 8
    )
    (
    input resetn,
    input clk,
    input signed [14:0] data_in,  //采样数据
    output data_out,    //位同步后0、1bit
    output sync         //位同步脉冲
    );
  reg signed [14:0] din;
always @(posedge clk or negedge resetn) begin
    if(!resetn) begin
        din <= 15'd0;
    end
    else begin
        din <= data_in;
    end
end
  wire signed [15:0] uk,wk;
  wire signed [17:0] data_interpolate;
  wire strobe;
  wire [17:0] dout;
  wire bit_sync;
  interpolate_filter u1(
    .resetn(resetn),
    .clk(clk),
    .data_in(din),   // 采样数据，采样频率同clk频率
    .uk(uk),           //分数间隔
    .data_out(data_interpolate)      //插值滤波输出，输出速率同clk频率
    );
  ted_loop_filter #(
    .SPS_2(SPS_2)   // 上采样率（采样速率与数据速率之比）的一半，
    )
    u2 (
    .resetn(resetn),
    .clk(clk),
    .strobe(strobe),
    .data_in(data_interpolate),   //插值滤波器输出得插值数据
    .data_out(dout), //最佳采样时刻得插值数据，用于判决0、1
    .wk(wk),       //环路滤波器输出定时误差信号，15 bit小数位
    .sync(bit_sync)      //位同步信号
    );
  nco u3(
    .resetn(resetn),
    .clk(clk),
    .wk(wk),    //环路滤波器输出定时误差信号，15 bit小数位
    .uk(uk),   //NCO输出的插值间隔小数，15 bit小数位
    .strobe(strobe)       //NCO输出的插值计算选通信号，高电平有效
    );
  reg bit_dout;
  reg bit_sync_1;
  reg bit_sync_2;
always @(posedge clk or negedge resetn) begin
    if(!resetn) begin
        bit_dout <= 1'b0;
        bit_sync_1 <= 1'b0;
        bit_sync_2 <= 1'b0;
    end
    else begin
        bit_sync_1 <= bit_sync;
        if(bit_sync & (!bit_sync_1)) begin
            bit_dout <= dout[17];
            bit_sync_2 <= 1'b1;
        end
        else begin
            bit_dout <= bit_dout;
            bit_sync_2 <= 1'b0;
        end
    end
end
assign data_out = bit_dout;
assign sync = bit_sync_2; //上升沿
endmodule
