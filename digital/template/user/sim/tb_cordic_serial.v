`timescale 1ns / 1ps
// 生成 VCD 波形文件（适用于 GTKWave）
   
module tb_cordic_serial;
    // 定义输入信号
    reg signed [31:0] x;
    reg signed [31:0] y;
    reg clk;

    // 定义输出信号
    wire [31:0] phase;

   
    // 实例化被测模块（DUT）
    cordic_serial uut (
        .x(x),
        .y(y),
        .clk(clk),
        .phase(phase)
    );

    // 生成 10ns 时钟（100MHz）
    always #5 clk = ~clk;

    // 测试过程
    initial begin
        // 初始化信号
        clk = 0;
        x = 0;
        y = 0;

        // 开始测试
        $display("Starting CORDIC Test...");

        // 测试向量 1: 45 度 (x=y)
        #10;
        x = 32'd1000000;
        y = 32'd1000000;
        $display("Test 1: X = %d, Y = %d", x, y);

        // 测试向量 2: 0 度 (y=0)
        #300;
        x = 32'd1000000;
        y = 32'd0;
        $display("Test 2: X = %d, Y = %d", x, y);

        // 测试向量 3: -45 度 (x=-y)
        #300;
        x = 32'd1000000;
        y = -32'd1000000;
        $display("Test 3: X = %d, Y = %d", x, y);

        // 测试向量 4: 90 度 (x=0)
        #300;
        x = 32'd0;
        y = 32'd1000000;
        $display("Test 4: X = %d, Y = %d", x, y);

        // 测试向量 5: -90 度 (x=0, y<0)
        #300;
        x = 32'd0;
        y = -32'd1000000;
        $display("Test 5: X = %d, Y = %d", x, y);

        // 等待计算完成
        #500;
        $display("CORDIC Calculation Finished!");
        $display("Final Output Phase: %d", phase);

    end

     initial begin
        $dumpfile("waveform/cordic_serial_tb.vcd");
        $dumpvars(0, tb_cordic_serial);
        // 结束仿真
        #50000 $finish;
    end


endmodule
