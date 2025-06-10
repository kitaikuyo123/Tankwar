// `timescale 1ns / 1ns
// module vgac(
//     input vga_clk,
//     input clrn,
//     input [11:0] d_in,
//     output reg [9:0] row_addr,
//     output reg [9:0] col_addr,
//     output reg rdn,
//     output reg [3:0] r,g,b,
//     output reg hs, vs
// );

//     reg [9:0] h_count;// 水平计数器
//     always @ (posedge vga_clk) begin
//         if (!clrn) begin
//             h_count <= 10'h0;
//         end else if (h_count == 10'd799) begin
//             h_count <= 10'h0;
//         end else begin
//             h_count <= h_count + 10'h1;
//         end
//     end

//     reg [9:0] v_count; // 垂直计数器
//     always @ (posedge vga_clk or negedge clrn) begin
//         if (!clrn) begin
//             v_count <= 10'h0;
//         end else if (h_count == 10'd799) begin
//             if (v_count == 10'd524) begin
//                 v_count <= 10'h0;
//             end else begin
//                 v_count <= v_count + 10'h1;
//             end
//         end
//     end

//     wire  [9:0] row    =  v_count - 10'd35;
//     wire  [9:0] col    =  h_count - 10'd144;
//     wire        h_sync = (h_count > 10'd95);
//     wire        v_sync = (v_count > 10'd1);
//     wire        read   = (h_count > 10'd142) &&
//                          (h_count < 10'd783) &&
//                          (v_count > 10'd34)  &&
//                          (v_count < 10'd515);

//     always @ (posedge vga_clk) begin
//         row_addr <=  row;
//         col_addr <=  col;
//         rdn      <= ~read;
//         hs       <=  h_sync;
//         vs       <=  v_sync;
//         r        <=  rdn ? 4'h0 : d_in[3:0];
//         g        <=  rdn ? 4'h0 : d_in[7:4];
//         b        <=  rdn ? 4'h0 : d_in[11:8];
//     end
// endmodule

`timescale 1ns / 1ps

module vgac(
    input vga_clk,
    input clrn,
    input [11:0] d_in,
    output reg [9:0] row_addr,
    output reg [9:0] col_addr,
    output reg rdn,
    output reg [3:0] r,
    output reg [3:0] g,
    output reg [3:0] b,
    output reg hs,
    output reg vs
);

    // ====== VGA 参数定义 (640x480 @ 60Hz) ======
    parameter H_TOTAL = 10'd800;  // 水平总像素
    parameter V_TOTAL = 10'd525;  // 垂直总行数
    parameter H_DISP  = 10'd640;  // 显示宽度
    parameter V_DISP  = 10'd480;  // 显示高度
    parameter H_FP    = 10'd16;   // 水平前肩
    parameter H_SYNC  = 10'd96;   // 水平同步脉冲
    parameter H_BP    = 10'd48;   // 水平后肩
    parameter V_FP    = 10'd10;   // 垂直前肩
    parameter V_SYNC  = 10'd2;    // 垂直同步脉冲
    parameter V_BP    = 10'd33;   // 垂直后肩

    // ====== 水平和垂直计数器 ======
    reg [9:0] h_count;
    reg [9:0] v_count;

    // 水平计数器：0 ~ 799
    always @(posedge vga_clk or negedge clrn) begin
        if (!clrn) begin
            h_count <= 10'h0;
        end else if (h_count == H_TOTAL - 1) begin
            h_count <= 10'h0;
        end else begin
            h_count <= h_count + 10'h1;
        end
    end

    // 垂直计数器：0 ~ 524
    always @(posedge vga_clk or negedge clrn) begin
        if (!clrn) begin
            v_count <= 10'h0;
        end else if (h_count == H_TOTAL - 1) begin
            if (v_count == V_TOTAL - 1) begin
                v_count <= 10'h0;
            end else begin
                v_count <= v_count + 10'h1;
            end
        end
    end

    // ====== 地址计算 ======
    assign col_addr = h_count - (H_FP + H_SYNC + H_BP);  // 起始于显示区左上角 x=0
    assign row_addr = v_count - (V_FP + V_SYNC + V_BP);  // 起始于显示区左上角 y=0

    // ====== 同步信号输出 ======
    assign hs = (h_count < H_FP + H_SYNC) ? 1'b0 : 1'b1; // 水平同步低电平
    assign vs = (v_count < V_FP + V_SYNC) ? 1'b0 : 1'b1; // 垂直同步低电平

    // ====== 视频有效区域判断 ======
    wire in_display_area = (h_count >= (H_FP + H_SYNC + H_BP)) &&
                           (h_count <  (H_FP + H_SYNC + H_BP + H_DISP)) &&
                           (v_count >= (V_FP + V_SYNC + V_BP)) &&
                           (v_count <  (V_FP + V_SYNC + V_BP + V_DISP));
    assign rdn = ~in_display_area;

    // ====== RGB 输出 ======
    always @(posedge vga_clk) begin
        if (in_display_area) begin
            r <= d_in[3:0];
            g <= d_in[7:4];
            b <= d_in[11:8];
        end else begin
            r <= 4'h0;
            g <= 4'h0;
            b <= 4'h0;
        end
    $monitor("Time=%0t | hcount=%d vcount=%d",
            $time, h_count, v_count );
    end


endmodule


// `timescale 1ns / 1ps

// module vgac(
//     input vga_clk,        // 像素时钟 (通常为 148.5 MHz 或 74.25 MHz)
//     input clrn,           // 复位信号 (低电平有效)
//     input [11:0] d_in,    // 输入的 RGB 数据 (12-bit)
//     output reg [10:0] row_addr,  // 行地址 (0 ~ 1079)
//     output reg [10:0] col_addr,  // 列地址 (0 ~ 1919)
//     output reg rdn,       // 读使能低电平 (0=允许读取像素数据)
//     output reg [3:0] r,   // 红色输出 (4-bit)
//     output reg [3:0] g,   // 绿色输出 (4-bit)
//     output reg [3:0] b,   // 蓝色输出 (4-bit)
//     output reg hs,        // 水平同步信号
//     output reg vs         // 垂直同步信号
// );

//     // ====== VGA 参数定义 (1920x1080 @ 60Hz) ======
//     parameter H_TOTAL = 12'd2200;  // 水平总周期
//     parameter V_TOTAL = 11'd1125;  // 垂直总行数
//     parameter H_DISP  = 11'd1920;  // 显示宽度
//     parameter V_DISP  = 11'd1080;  // 显示高度
//     parameter H_FP    = 11'd148;   // 水平前肩
//     parameter H_SYNC  = 11'd44;    // 水平同步脉冲
//     parameter H_BP    = 11'd88;    // 水平后肩
//     parameter V_FP    = 11'd36;    // 垂直前肩
//     parameter V_SYNC  = 11'd5;     // 垂直同步脉冲
//     parameter V_BP    = 11'd4;     // 垂直后肩

//     // ====== 水平和垂直计数器 ======
//     reg [11:0] h_count;  // 12位计数器，最大值为4095
//     reg [10:0] v_count;  // 11位计数器，最大值为2047

//     // 水平计数器：0 ~ 2199
//     always @(posedge vga_clk or negedge clrn) begin
//         if (!clrn) begin
//             h_count <= 12'h0;
//         end else if (h_count == H_TOTAL - 1) begin
//             h_count <= 12'h0;
//         end else begin
//             h_count <= h_count + 12'h1;
//         end
//     end

//     // 垂直计数器：0 ~ 1124
//     always @(posedge vga_clk or negedge clrn) begin
//         if (!clrn) begin
//             v_count <= 11'h0;
//         end else if ((h_count == H_TOTAL - 1) && (v_count == V_TOTAL - 1)) begin
//             v_count <= 11'h0;
//         end else if (h_count == H_TOTAL - 1) begin
//             v_count <= v_count + 11'h1;
//         end
//     end

//     // ====== 地址计算 ======
//     always @(posedge vga_clk or negedge clrn) begin
//         if (!clrn) begin
//             col_addr <= 11'h0;
//             row_addr <= 11'h0;
//         end else begin
//             if (h_count >= (H_FP + H_SYNC + H_BP) && h_count < (H_FP + H_SYNC + H_BP + H_DISP) &&
//                 v_count >= (V_FP + V_SYNC + V_BP) && v_count < (V_FP + V_SYNC + V_BP + V_DISP)) begin
//                 col_addr <= h_count - (H_FP + H_SYNC + H_BP);
//                 row_addr <= v_count - (V_FP + V_SYNC + V_BP);
//             end else begin
//                 col_addr <= 11'h0;
//                 row_addr <= 11'h0;
//             end
//         end
//     end

//     // ====== 同步信号输出 ======
//     always @(posedge vga_clk or negedge clrn) begin
//         if (!clrn) begin
//             hs <= 1'b1;
//             vs <= 1'b1;
//         end else begin
//             hs <= (h_count < H_FP + H_SYNC) ? 1'b0 : 1'b1;
//             vs <= (v_count < V_FP + V_SYNC) ? 1'b0 : 1'b1;
//         end
//     end

//     // ====== 视频有效区域判断 ======
//     wire in_display_area = (h_count >= (H_FP + H_SYNC + H_BP)) &&
//                            (h_count <  (H_FP + H_SYNC + H_BP + H_DISP)) &&
//                            (v_count >= (V_FP + V_SYNC + V_BP)) &&
//                            (v_count <  (V_FP + V_SYNC + V_BP + V_DISP));

//     // ====== 读使能信号 ======
//     always @(posedge vga_clk or negedge clrn) begin
//         if (!clrn) begin
//             rdn <= 1'b1;
//         end else begin
//             rdn <= ~in_display_area;
//         end
//     end

//     // ====== RGB 输出 ======
//     always @(posedge vga_clk) begin
//         if (in_display_area) begin
//             r <= d_in[3:0];
//             g <= d_in[7:4];
//             b <= d_in[11:8];
//         end else begin
//             r <= 4'h0;
//             g <= 4'h0;
//             b <= 4'h0;
//         end
//     end

// endmodule