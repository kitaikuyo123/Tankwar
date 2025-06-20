`timescale 1ns / 1ps

module tb_game_engine#(
    parameter MAX_BULLETS = 8        // 最大子弹数量
);

    // 参数定义
    parameter CLK_PERIOD = 10;  // 10 ns 周期 (100 MHz)

    // 信号声明
    logic clk;
    logic reset;

    // 控制信号
    logic video_on;
    logic game_on;

    // 玩家1控制
    logic up1, down1, left1, right1, fire1;

    // 玩家2控制（可作为敌人控制）
    logic up2, down2, left2, right2, fire2;

    // RAM 输出
    logic [2:0] tank_ram_addr;
    logic [31:0] tank_ram_data;

    logic [2:0] oppo_ram_addr;
    logic [31:0] oppo_ram_data;

    logic [2:0] bullet_ram_addr [(MAX_BULLETS * 2)-1:0];
    logic [31:0] bullet_ram_data [(MAX_BULLETS * 2)-1:0];

    // 实例化被测模块
    game_engine #(
        .MAX_BULLETS(8)
    ) uut (
        .clk(clk),
        .reset(reset),

        .video_on(video_on),
        .game_on(game_on),

        .up1(up1),
        .down1(down1),
        .left1(left1),
        .right1(right1),
        .fire1(fire1),

        .up2(up2),
        .down2(down2),
        .left2(left2),
        .right2(right2),
        .fire2(fire2),

        .tank_ram_data(tank_ram_data),

        .oppo_ram_data(oppo_ram_data),

        .bullet_ram_data(bullet_ram_data)
    );

    // 生成时钟
    always begin
        #5 clk = ~clk;
    end

    // 测试过程
    initial begin
        // 初始化输入信号
        clk = 0;
        reset = 1;
        video_on = 1;
        game_on = 1;

        up1 = 0;
        down1 = 0;
        left1 = 0;
        right1 = 0;
        fire1 = 0;

        up2 = 0;
        down2 = 0;
        left2 = 0;
        right2 = 0;
        fire2 = 0;

        #20 reset = 0;  // 释放复位

        $monitor("Time=%0t | Player Pos: %0d,%0d | Enemy Pos: %0d,%0d | Bullet Pos: %0d,%0d | Player active: %b | Enemy active: %b | Bullet active: %b",
                $time,
                tank_ram_data[27:18], tank_ram_data[17:8],
                oppo_ram_data[27:18], oppo_ram_data[17:8],
                bullet_ram_data[0][27:18], bullet_ram_data[0][17:8],
                tank_ram_data[28],
                oppo_ram_data[28],
                bullet_ram_data[0][28]
                );

        // 移动玩家坦克
        down1 = 1;
        #60;
        down1 = 0;
        up1=1;
        #10;
        up1=0;

        // right1 = 1;
        // #40;
        // right1 = 0;

        // 玩家开火
        fire1 = 1;
        #1000;
        fire1 = 0;

        // // 移动敌人坦克
        // down2 = 1;
        // #50;
        // down2 = 0;

        // right2 = 1;
        // #20;
        // right2 = 0;

        // up2 = 1;
        // #50;
        // up2 = 0;

        // // 敌人开火
        // fire2 = 1;
        // #10;
        // fire2 = 0;

        // 结束仿真
        #300;
        $display("Test completed.");
        $finish;
    end

endmodule