`timescale 1ns / 1ps

module tankWar_top (
    input wire clk,
    input wire reset,

    input [14:0]SW,

    // 控制输入
    input ps2_clk,
    input ps2_data,

    // VGA控制
    output wire hsync,
    output wire vsync,
    output wire [3:0] VGA_r,VGA_g,VGA_b,
    // 音频输出
    output wire voice,

    output reg ps2_up1,
    output reg ps2_down1,
    output reg ps2_left1,
    output reg ps2_right1,
    output reg ps2_up2,
    output reg ps2_down2,
    output reg ps2_left2,
    output reg ps2_right2
);

//--------------------------------------------------------------
// 参数定义
//--------------------------------------------------------------
parameter MAX_BULLETS = 8;

//--------------------------------------------------------------
// 内部信号声明
//--------------------------------------------------------------
wire video_on;         // 视频是否在有效区�???
wire f_tick;           // 帧同步信�???
wire [9:0] x, y;       // 当前像素坐标

wire [31:0] tank_ram_data;

wire [31:0] oppo_ram_data;

wire [31:0] bullet_ram_data [(MAX_BULLETS * 2)-1:0];

wire bg_pixel_on;
wire [11:0] bg_color;

wire tank1_pixel_on;
wire tank2_pixel_on;
wire bullet_pixel_on;
wire [11:0] tank1_color;
wire [11:0] tank2_color;
wire [11:0] bullet_color;

wire up1;
wire down1;
wire left1;
wire right1;
wire fire1;
wire up2;
wire down2;
wire left2;
wire right2;
wire fire2;

wire beep; // 音频输出

wire game_on = 1'b1;

//--------------------------------------------------------------
// 时钟分频
//--------------------------------------------------------------
reg [31:0]clkdiv;
always@(posedge clk) begin
    clkdiv <= clkdiv + 1'b1;
end

//--------------------------------------------------------------
// 去抖动
//--------------------------------------------------------------
wire [14:0] SW_OK;
AntiJitter #(4) a0[14:0](.clk(clkdiv[15]), .I(SW), .O(SW_OK));
//--------------------------------------------------------------
// 音乐
//--------------------------------------------------------------
music audio_unit(.clk(clkdiv[0]), .speaker(beep));
assign voice = beep & SW_OK[2];

//--------------------------------------------------------------
// VGA同步模块
//--------------------------------------------------------------
reg [11:0] rgb; // VGA d_in;
wire rdn;

assign video_on = ~rdn;

vgac VGA(
    .vga_clk(clkdiv[1]),
    .clrn(SW_OK[0]),
    .d_in(rgb),
    .row_addr(x),
    .col_addr(y),
    .rdn(rdn),
    .r(VGA_r),
    .g(VGA_g),
    .b(VGA_b),
    .hs(hsync),
    .vs(vsync)
);

//--------------------------------------------------------------
// PS/2模块
//--------------------------------------------------------------
PS2 ps2 (
    .clk(clk), 
    .rst(SW_OK[1]), 
    .ps2_clk(ps2_clk), 
    .ps2_data(ps2_data), 
    .up(up1),
    .down(down1),
    .left(left1),
    .right(right1),
    .space(fire1),
    .w(up2),
    .s(down2),
    .a(left2),
    .d(right2),
    .enter(fire2)
);

//--------------------------------------------------------------
// 背景引擎
//--------------------------------------------------------------
background_engine background (
    .clk(clk),
    .video_on(video_on),
    .x(x),
    .y(y),
    .pixel_on(bg_pixel_on),
    .color(bg_color)
);

//--------------------------------------------------------------
// 游戏引擎
//--------------------------------------------------------------
game_engine game (
    .clk(clk),
    .reset(reset),
    .video_on(video_on),
    .game_on(game_on),

    // 玩家1输入
    .up1(up1),
    .down1(down1),
    .left1(left1),
    .right1(right1),
    .fire1(fire1),

    // 玩家2输入
    .up2(up2),
    .down2(down2),
    .left2(left2),
    .right2(right2),
    .fire2(fire2),

    // RAM 输出连接
    .tank_ram_data(tank_ram_data),

    .oppo_ram_data(oppo_ram_data),

    .bullet_ram_data(bullet_ram_data)
);

//--------------------------------------------------------------
// 对象引擎（坦�???1、坦�???2、子弹）
//--------------------------------------------------------------
tank_engine tank1 (
    .clk(clk),
    .video_on(video_on),
    .x(x),
    .y(y),
    .oam_data(tank_ram_data),
    .sprite_on(tank1_pixel_on),
    .color(tank1_color)
);

tank_engine tank2 (
    .clk(clk),
    .video_on(video_on),
    .x(x),
    .y(y),
    .oam_data(oppo_ram_data),
    .sprite_on(tank2_pixel_on),
    .color(tank2_color)
);

bullet_engine #(.TILE_WIDTH(8),.TILE_HEIGHT(8)) bullet (
    .clk(clk),
    .video_on(video_on),
    .x(x),
    .y(y),
    .oam_data(bullet_ram_data),
    .sprite_on(bullet_pixel_on),
    .color(bullet_color)
);
//--------------------------------------------------------------
// 显示合成�???
//--------------------------------------------------------------
// �???终输出RGB的�?�择
always_comb begin
    if (!video_on) begin
        rgb = 12'h000; // 黑屏
    end else if (bullet_pixel_on) begin
        rgb = bullet_color;
    end else if (tank1_pixel_on) begin
        rgb = tank1_color;
    end else if (tank2_pixel_on) begin
        rgb = tank2_color;
    end else if (bg_pixel_on) begin
        rgb = bg_color;
    end else begin
        rgb = 12'h000;
    end
end

always @(posedge clk) begin
    ps2_up1 <= fire1;  
    ps2_left1 <= fire1; 
    ps2_right1 <= fire1; 
    ps2_down1 <= fire1; 
    ps2_up2 <= fire2;   
    ps2_left2 <= fire2; 
    ps2_right2 <= fire2; 
    ps2_down2 <= fire2; 
end

endmodule