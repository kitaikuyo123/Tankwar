// bullet_engine_tb.sv
`timescale 1ns / 1ns

module bullet_engine_tb;

    // 参数定义
    parameter CLK_PERIOD = 10; // 10 ns 周期，即100MHz时钟

    // 信号声明
    reg clk;
    reg video_on;
    reg [9:0] x;
    reg [9:0] y;
    reg [31:0] oam_data [15:0]; // OAM 存储 16 个子弹数据
    wire [2:0] oam_addr;        // 输出地址（只读）
    wire sprite_on;
    wire [11:0] color;

    // 实例化被测模块
    bullet_engine uut (
        .clk(clk),
        .video_on(video_on),
        .x(x),
        .y(y),
        .oam_data(oam_data),
        .oam_addr(oam_addr),
        .sprite_on(sprite_on),
        .color(color)
    );

    // 生成时钟信号
    always begin
        #5 clk = ~clk; // 每5ns翻转一次，得到10ns周期
    end

    // 测试过程
    initial begin
        integer i;

        // 初始化信号
        clk = 0;
        video_on = 0;
        x = 0;
        y = 0;

        // 清空 OAM 数据
        for (i = 0; i < 16; i = i + 1) begin
            oam_data[i] = 32'h0;
        end

        // 配置第一个子弹（启用，位置(100,100)，图像在第1行第2列）
        oam_data[0] = {
            1'b0,
            2'b01,
            1'b1,
            10'd100,  // X 坐标
            10'd100,  // Y 坐标
            2'b01,
            3'b000,
            3'b001
        };

        // 等待几个时钟周期后开启视频信号
        #20;
        video_on = 1;

        // 扫描屏幕中心区域（围绕子弹位置）
        for (y = 100; y < 108; y = y + 1) begin
            for (x = 100; x < 108; x = x + 1) begin
                #10; // 每个点等待一个时钟周期
                $display("x=%3d, y=%3d | sprite_on=%b, color=0x%h", x, y, sprite_on, color);
            end
        end

        // 关闭视频信号并结束仿真
        video_on = 0;
        #20 $finish;
    end

endmodule // bullet_engine_tb