`timescale 1ns / 1ps

module interpolate_filter(
    input resetn,
    input clk,
    input signed [14:0] data_in,   // 输入采样数据
    input signed [15:0] uk,        // 插值因子 u_k = kT_i/T_s - m_k
    output signed [17:0] data_out  // 插值滤波输出
);

    // 采样数据缓存
    reg signed [14:0] din_1, din_2, din_3, din_4, din_5, din_6;
    reg signed [15:0] u_1, u_2;

    // 插值滤波中间结果
    reg signed [17:0] f1, f2, f3;

    // 主时序逻辑：更新寄存器
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            din_1 <= 15'd0; din_2 <= 15'd0; din_3 <= 15'd0;
            din_4 <= 15'd0; din_5 <= 15'd0; din_6 <= 15'd0;
            u_1 <= 16'd0; u_2 <= 16'd0;
            f1 <= 18'd0; f2 <= 18'd0; f3 <= 18'd0;
        end else begin
            din_1 <= data_in;
            din_2 <= din_1;
            din_3 <= din_2;
            din_4 <= din_3;
            din_5 <= din_4;
            din_6 <= din_5;

            u_1 <= uk;
            u_2 <= u_1;

            // f1: 用于一阶插值
            f1 <= {{4{data_in[14]}}, data_in[14:1]}
                - {{4{din_1[14]}}, din_1[14:1]}
                - {{4{din_2[14]}}, din_2[14:1]}
                + {{4{din_3[14]}}, din_3[14:1]};

            // f2: 用于二阶插值
            f2 <= {{3{din_1[14]}}, din_1}
                + {{4{din_1[14]}}, din_1[14:1]}
                - {{4{data_in[14]}}, data_in[14:1]}
                - {{4{din_2[14]}}, din_2[14:1]}
                - {{4{din_3[14]}}, din_3[14:1]};

            // f3: 辅助项，延迟用
            f3 <= {{3{din_6[14]}}, din_6};
        end
    end

    // 组合乘法器
    wire signed [33:0] f1_u  = f1 * uk;
    wire signed [33:0] f2_u  = f2 * uk;
    wire signed [33:0] f1_u2 = f1_u * u_2;

    // 插值结果计算：取乘法高位并对齐
    wire signed [18:0] dt = f2_u[33:15] + f1_u2[33:15] + {f3, 1'b0};

    // 输出寄存器
    reg signed [17:0] dt_1;
    always @(posedge clk or negedge resetn) begin
        if (!resetn)
            dt_1 <= 18'd0;
        else
            dt_1 <= dt[17:0];
    end

    assign data_out = dt_1;

endmodule