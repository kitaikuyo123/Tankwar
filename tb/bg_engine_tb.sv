// background_engine_tb.sv
`timescale 1ns / 1ns

module background_engine_tb;

    // 定义参数
    parameter CLK_PERIOD = 10; // 10 ns 周期，即100MHz时钟

    // 声明信号
    reg clk;
    reg video_on;
    reg [9:0] x;
    reg [9:0] y;
    wire pixel_on;
    wire [11:0] color;

    // 实例化被测模块
    background_engine uut (
        .clk(clk),
        .video_on(video_on),
        .x(x),
        .y(y),
        .pixel_on(pixel_on),
        .color(color)
    );

    // 生成时钟信号
    always begin
        #5 clk = ~clk; // 每5ns翻转一次，得到10ns周期
    end

    // 测试过程
    initial begin
        // 初始化信号
        clk = 0;
        video_on = 0;
        x = 0;
        y = 0;

        // 等待几个时钟周期后开启视频信号
        #20;
        video_on = 1;

        // 扫描一些像素点进行测试
        for (x = 0; x < 640; x = x + 1) begin
            for (y = 0; y < 480; y = y + 1) begin
                #10; // 每个点等待一个时钟周期
                $display("x=%d, y=%d, pixel_on=%b, color=0x%h", x, y, pixel_on, color);
            end
        end

        // 关闭视频信号并结束仿真
        video_on = 0;
        #20 $finish;
    end

endmodule // background_engine_tb