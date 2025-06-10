// tank_engine_tb.sv
`timescale 1ns / 1ns

module tank_engine_tb;

    // 参数定义
    parameter CLK_PERIOD = 10; // 10 ns 周期，即100MHz时钟

    // 信号声明
    reg clk;
    reg video_on;
    reg [9:0] x;
    reg [9:0] y;
    reg [31:0] oam_data;       // 输入 OAM 数据
    // wire [2:0] oam_addr;        // 输出地址（只读）
    wire sprite_on;
    wire [11:0] color;

    // 实例化被测模块
    tank_engine uut (
        .clk(clk),
        .video_on(video_on),
        .x(x),
        .y(y),
        .oam_data(oam_data),
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
        oam_data = 0;

        // 配置 OAM 数据：
        // 启用类型为 player1 的坦克，位于 (100, 100)，方向 0，SPRITE_ROW=0, SPRITE_COL=0
        oam_data = {
            1'b0,
            2'b00,            // OBJ_TYPE: 玩家坦克
            1'b1,             // OBJ_ENABLE: 启用
            10'd100,          // OBJ_POS_X: x=100
            10'd100,          // OBJ_POS_Y: y=100
            2'b00,            // OBJ_DIR: 方向 0
            3'b000,           // SPRITE_ROW: 第0行
            3'b000            // SPRITE_COL: 第0列
        };

        // 等待几个时钟周期后开启视频信号
        #20;
        video_on = 1;

        // 扫描坦克所在区域（32x32 范围）
        for (y = 100; y < 132; y = y + 1) begin
            for (x = 100; x < 132; x = x + 1) begin
                #10; // 每个点等待一个时钟周期
                $display("x=%3d, y=%3d | sprite_on=%b, color=0x%h", x, y, sprite_on, color);
            end
        end

        // 关闭视频信号并结束仿真
        video_on = 0;
        #20 $finish;
    end

endmodule // tank_engine_tb