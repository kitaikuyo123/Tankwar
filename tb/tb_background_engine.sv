`timescale 1ns / 1ps

module tb_background_engine;

    // ====== 信号声明 ======
    reg clk;
    reg video_on;
    reg [9:0] x;
    reg [9:0] y;

    wire pixel_on;
    wire [11:0] color;

    // ====== 实例化被测模块 ======
    background_engine uut (
        .clk(clk),
        .video_on(video_on),
        .x(x),
        .y(y),
        .pixel_on(pixel_on),
        .color(color)
    );

    // ====== 时钟生成 ======
    parameter CLK_PERIOD = 10; // 100 MHz
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // ====== 测试过程 ======
    initial begin
        // 初始状态
        video_on = 0;
        x = 0;
        y = 0;
        #20;

        // 启动视频区域
        video_on = 1;

        // 测试 1: (x=100, y=100) -> map[3][3] = 1 -> wall tile
        x = 100;
        y = 100;
        #20;

        // 测试 2: (x=50, y=50) -> map[1][1] = 0 -> road tile
        x = 50;
        y = 50;
        #20;

        // 测试 3: (x=200, y=200) -> map[6][6] = 0 -> road tile
        x = 200;
        y = 200;
        #20;

        // 测试 4: (x=300, y=300) -> map[9][9] = 1 -> wall tile
        x = 300;
        y = 300;
        #20;

        // 结束仿真
        $finish;
    end

    // ====== 波形记录 ======
    initial begin
        $dumpfile("tb_background_engine.vcd");
        $dumpvars(0, tb_background_engine);
    end

    // ====== 信号监视 ======
    initial begin
        $monitor("Time=%0t | x=%d y=%d | map_x=%d map_y=%d | rom_x=%d rom_y=%d | color=%h pixel_on=%b",
                 $time, x, y,
                 x[9:5], y[9:5],
                 uut.rom_x, uut.rom_y,
                 color, pixel_on);
    end

endmodule