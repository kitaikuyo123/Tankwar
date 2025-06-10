`timescale 1ns / 1ps

module tb_tankwar_game();

    // ====== 信号声明 ======
    reg clk;
    reg reset;

    // 控制输入
    reg up1, down1, left1, right1, fire1;
    reg up2, down2, left2, right2, fire2;

    // VGA输出
    wire [9:0] x, y;         // 当前像素坐标
    wire rdn;
    wire video_on = ~rdn;
    reg [11:0] rgb;         // 最终输出给 VGA 的 RGB
    wire [3:0] vga_r, vga_g, vga_b;

    // 内部连接信号
    wire [2:0] tank_ram_addr;
    wire [31:0] tank_ram_data;
    wire [2:0] oppo_ram_addr;
    wire [31:0] oppo_ram_data;
    wire [2:0] bullet_ram_addr [15:0];
    wire [31:0] bullet_ram_data [15:0];

    // ====== 实例化被测模块 ======

    // VGA控制器
    vgac uut_vga (
        .vga_clk(clk),
        .clrn(~reset),
        .d_in(rgb),
        .row_addr(x),
        .col_addr(y),
        .rdn(rdn),
        .r(vga_r),
        .g(vga_g),
        .b(vga_b),
        .hs(),
        .vs()
    );

    // 游戏引擎
    game_engine #(.MAX_BULLETS(8)) uut_game (
        .clk(clk),
        .reset(reset),
        .video_on(video_on),
        .game_on(1'b1),

        // 玩家1控制
        .up1(up1),
        .down1(down1),
        .left1(left1),
        .right1(right1),
        .fire1(fire1),

        // 玩家2控制
        .up2(up2),
        .down2(down2),
        .left2(left2),
        .right2(right2),
        .fire2(fire2),

        // RAM 接口
        .tank_ram_addr(tank_ram_addr),
        .tank_ram_data(tank_ram_data),
        .oppo_ram_addr(oppo_ram_addr),
        .oppo_ram_data(oppo_ram_data),
        .bullet_ram_addr(bullet_ram_addr),
        .bullet_ram_data(bullet_ram_data)
    );

    // 背景引擎
    wire bg_pixel_on;
    wire [11:0] bg_color;
    background_engine uut_background (
        .clk(clk),
        .video_on(video_on),
        .x(x),
        .y(y),
        .pixel_on(bg_pixel_on),
        .color(bg_color)
    );

    // 坦克引擎
    wire tank1_pixel_on;
    wire [11:0] tank1_color;
    tank_engine #(.TILE_WIDTH(32), .TILE_HEIGHT(32)) uut_tank1 (
        .clk(clk),
        .video_on(video_on),
        .x(x),
        .y(y),
        .oam_data(tank_ram_data),
        .oam_addr(tank_ram_addr),
        .sprite_on(tank1_pixel_on),
        .color(tank1_color)
    );

    // 对手坦克
    wire tank2_pixel_on;
    wire [11:0] tank2_color;
    tank_engine #(.TILE_WIDTH(32), .TILE_HEIGHT(32)) uut_tank2 (
        .clk(clk),
        .video_on(video_on),
        .x(x),
        .y(y),
        .oam_data(oppo_ram_data),
        .oam_addr(oppo_ram_addr),
        .sprite_on(tank2_pixel_on),
        .color(tank2_color)
    );

    // 子弹引擎
    wire bullet_pixel_on;
    wire [11:0] bullet_color;
    bullet_engine #(.TILE_WIDTH(8), .TILE_HEIGHT(6)) uut_bullet (
        .clk(clk),
        .video_on(video_on),
        .x(x),
        .y(y),
        .oam_data(bullet_ram_data),
        .oam_addr(),
        .sprite_on(bullet_pixel_on),
        .color(bullet_color)
    );

    // ====== 显示合成 ======
    always_comb begin
        if (!video_on) begin
            rgb = 12'h000; // 黑屏
        end else if (tank1_pixel_on) begin
            rgb = tank1_color;
        end else if (tank2_pixel_on) begin
            rgb = tank2_color;
        end else if (bullet_pixel_on) begin
            rgb = bullet_color;
        end else if (bg_pixel_on) begin
            rgb = bg_color;
        end else begin
            rgb = 12'h000;
        end
    end

    // ====== 时钟生成 ======
    parameter CLK_PERIOD = 10;
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // ====== 复位控制 ======
    initial begin
        reset = 0;
        #10 reset = 1;
        #100 reset = 0;

        // 模拟玩家操作
        up1 = 0; down1 = 0; left1 = 0; right1 = 0; fire1 = 0;
        up2 = 0; down2 = 0; left2 = 0; right2 = 0; fire2 = 0;

        #1000;
        // right1 = 1; #100; right1 = 0; // 向右移动
        // fire1 = 1; #10; fire1 = 0;    // 开火
        #500;
        // up2 = 1; #100; up2 = 0;      // 敌方坦克向上
        // fire2 = 1; #10; fire2 = 0;   // 敌方开火
        #200000 $finish;
    end

    // ====== 波形记录 ======
    initial begin
        $dumpfile("tb_tankwar_game.vcd");
        $dumpvars(0, tb_tankwar_game);
    end

    // ====== 信号监视 ======
    initial begin
        $monitor("Time=%0t | x=%0d y=%0d | video_on=%b | color=%h",
                 $time, x, y, video_on, rgb);
    end

endmodule