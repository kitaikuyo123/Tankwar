`timescale 1ns / 1ps

module tb_vgac();

    // ====== 信号声明 ======
    reg vga_clk;
    reg clrn;

    reg [11:0] d_in;
    wire [9:0] row_addr, col_addr;
    wire rdn;
    wire hsync, vsync;
    wire [3:0] r, g, b;

    // ====== 实例化被测模块 ======
    vgac uut (
        .vga_clk(vga_clk),
        .clrn(clrn),
        .d_in(d_in),
        .row_addr(row_addr),
        .col_addr(col_addr),
        .rdn(rdn),
        .r(r),
        .g(g),
        .b(b),
        .hs(hsync),
        .vs(vsync)
    );

    // ====== 时钟生成 ======
    parameter CLK_PERIOD = 40; // 25 MHz (假设为 VGA 640x480@60Hz 所需频率)
    initial begin
        vga_clk = 0;
        forever #(CLK_PERIOD/2) vga_clk = ~vga_clk;
    end

    // ====== 复位控制 ======
    initial begin
        clrn = 0;
        #100 clrn = 1;
      #200000;
    end

    // ====== 输入驱动 ======
    initial begin
        d_in = 12'hFFF; // 白色像素值用于测试显示合成
    end

    // ====== 波形记录 ======
    initial begin
        $dumpfile("tb_vgac.vcd");
        $dumpvars(0, tb_vgac);
    end

    // ====== 信号监视 ======
    initial begin
        $monitor("Time=%0t | x=%d y=%d | rdn=%b | HSync=%b VSync=%b",
                 $time, row_addr, col_addr, rdn, hsync, vsync);
    end

endmodule