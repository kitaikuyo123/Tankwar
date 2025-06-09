`timescale 1ns / 1ps

module tb_tankwar();

    // ====== 输入信号声明 ======
    reg clk;
    reg reset;

    reg ps2_clk;
    reg ps2_data;

    // ====== 输出信号声明 ======
    wire hsync;
    wire vsync;
    wire [3:0] VGA_r, VGA_g, VGA_b;

    // ====== 中间信号监控 ======
    wire video_on;
    wire [9:0] x, y;
    wire [11:0] rgb;

    wire up1, down1, left1, right1, fire1;
    wire up2, down2, left2, right2, fire2;

    wire bg_pixel_on;
    wire [11:0] bg_color;

    wire tank1_pixel_on;
    wire tank2_pixel_on;
    wire bullet_pixel_on;
    wire [11:0] tank1_color;
    wire [11:0] tank2_color;
    wire [11:0] bullet_color;

    // ====== 实例化 DUT（被测模块） ======
    tankWar_top uut (
        .clk(clk),
        .reset(reset),

        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),

        .hsync(hsync),
        .vsync(vsync),
        .VGA_r(VGA_r),
        .VGA_g(VGA_g),
        .VGA_b(VGA_b)
    );

    // ====== 提取内部信号（需要修改顶层模块为可访问）=====
    // 假设顶层模块中将这些信号作为输出或添加调试端口
    // 如果无法直接导出，可在仿真时使用路径访问如：
    // assign video_on = uut.VGA.video_on;

    // ====== 时钟生成 ======
    parameter CLK_PERIOD = 10; // 10 ns → 100 MHz
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // ====== 复位控制 ======
    initial begin
        reset = 1;
        #100 reset = 0;
        #100000 $finish;
    end

    // ====== PS/2 键盘模拟 ======
    // 模拟发送一个 "W" 键按下（用于玩家2向上移动）
    // 注意：实际键码需根据 PS/2 协议模拟串行数据
    initial begin
        ps2_clk = 1;
        ps2_data = 1;

        #10000; // 等待系统稳定

        // 发送 Break Code (释放键)
        send_ps2_code(8'hF0);
        send_ps2_code(8'h1D); // W 的扫描码是 1D

        #10000;

        // 发送 Make Code (按下键)
        send_ps2_code(8'h1D);

        #10000;

        // 发送 Break Code
        send_ps2_code(8'hF0);
        send_ps2_code(8'h1D);

    end

    task send_ps2_code(input [7:0] data);
        integer i;
        begin
            ps2_data = 1; // 释放数据线
            ps2_clk = 1;

            #1000;

            ps2_data = 0; // Start bit
            @(negedge clk);

            for (i = 0; i < 8; i = i + 1) begin
                ps2_data = data[i];
                @(negedge clk);
            end

            // Parity bit (odd parity)
            ps2_data = ^data;
            @(negedge clk);

            // Stop bit
            ps2_data = 1;
            @(negedge clk);

            // Wait for clock high
            while (ps2_clk === 0) @(posedge ps2_clk);
        end
    endtask

    // ====== 信号监视器 ======
    initial begin
        $monitor("Time: %0t | x=%d y=%d | RGB=%h | VideoOn=%b", $time, x, y, rgb, video_on);
        $monitor("  BG: pixel_on=%b color=%h", bg_pixel_on, bg_color);
        $monitor("Tank1: pixel_on=%b color=%h", tank1_pixel_on, tank1_color);
        $monitor("Bullet: pixel_on=%b color=%h", bullet_pixel_on, bullet_color);
        $monitor("Inputs: up1=%b left1=%b right1=%b fire1=%b", up1, left1, right1, fire1);
    end

    // ====== 波形记录（可选） ======
    initial begin
        $dumpfile("tb_tankwar.vcd");
        $dumpvars(0, tb_tankwar);
    end

endmodule