`timescale 1ns / 1ps

module tb_vgac_background();

    // ====== 信号声明 ======
    reg vga_clk;
    reg clrn;

    wire [9:0] x, y;         // vgac 输出的地址
    wire rdn;                // 显示区域使能
    wire video_on = ~rdn;    // 视频有效标志
    wire [11:0] bg_color;    // 背景引擎输出的颜色
    wire [11:0] rgb;         // 作为 d_in 输入给 VGA 控制器

    // ====== 实例化被测模块 ======
    vgac uut (
        .vga_clk(vga_clk),
        .clrn(clrn),
        .d_in(rgb),
        .row_addr(x),
        .col_addr(y),
        .rdn(rdn),
        .r(), .g(), .b(),    // 不关心模拟输出
        .hs(), .vs()
    );

    background_engine background (
        .clk(vga_clk),
        .video_on(video_on),
        .x(x),
        .y(y),
        .pixel_on(),         // 不使用 pixel_on
        .color(bg_color)
    );

    // 将背景颜色赋值给 rgb
    assign rgb = video_on ? bg_color : 12'h000;

    // ====== 时钟生成 ======
    parameter CLK_PERIOD = 40; // 25 MHz
    initial begin
        vga_clk = 0;
        forever #(CLK_PERIOD/2) vga_clk = ~vga_clk;
    end

    // ====== 复位控制 ======
    initial begin
        clrn = 0;
        #100 clrn = 1;
        #1_000_000 $finish;
    end

    // ====== 波形记录 ======
    initial begin
        $dumpfile("tb_vgac_background.vcd");
        $dumpvars(0, tb_vgac_background);
    end

    // ====== 信号监视 ======
    initial begin
        $monitor("Time=%0t | x=%0d y=%0d | video_on=%b | color=%h",
                 $time, x, y, video_on, bg_color);
    end

endmodule