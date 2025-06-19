`timescale 1ns / 1ps

module game_engine#(
    parameter MAX_BULLETS = 8        // 最大子弹数量
)(
    input wire clk,
    input wire reset,

    // 控制信号
    input wire video_on,   // 视频使能
    input wire game_on,    // 游戏运行标志
    input wire up1,         // 玩家输入方向
    input wire down1,
    input wire left1,
    input wire right1,
    input wire fire1,       // 玩家开火

    input wire up2,         // 玩家输入方向
    input wire down2,
    input wire left2,
    input wire right2,
    input wire fire2,       // 玩家开火

    output reg [31:0] tank_ram_data,

    output reg [31:0] oppo_ram_data,

    output reg [31:0] bullet_ram_data [(MAX_BULLETS * 2)-1:0]
);

parameter TANK_SIZE = 32;      // 坦克大小（像素）
parameter BULLET_SIZE = 8;     // 子弹大小（像素）

logic game_over = 0;

// 玩家坦克
wire [9:0] tank_x, tank_y;
wire tank_bullet_fire;
wire [1:0] tank_bullet_dir;

// 敌方坦克
wire [9:0] oppo_x, oppo_y;
wire oppo_bullet_fire;
wire [1:0] oppo_bullet_dir;

// 玩家子弹
wire [31:0] bullet_player_state [0:MAX_BULLETS-1];

// 敌人子弹
wire [31:0] bullet_enemy_state [0:MAX_BULLETS-1];

// 碰撞检测结果
wire hit_player;
wire hit_opponent;

// 玩家坦克
tank #(.INIX(32), .INIY(32), .PLAYER_INDEX(0)) player (
    .clk(clk),
    .reset(reset),
    .killed(hit_player),
    .game_over(0),

    .up(up1),
    .down(down1),
    .left(left1),
    .right(right1),
    .fire(fire1),

    .bullet_fire(tank_bullet_fire),
    .bullet_direction(tank_bullet_dir),

    .pos_x(tank_x),
    .pos_y(tank_y),

    .tank_state(tank_ram_data)
);

tank  #(.INIX(160), .INIY(32), .PLAYER_INDEX(1)) enemy (
    .clk(clk),
    .reset(reset),
    .killed(hit_opponent),
    .game_over(0),

    .up(up2),
    .down(down2),
    .left(left2),
    .right(right2),
    .fire(fire2),

    .bullet_fire(oppo_bullet_fire),
    .bullet_direction(oppo_bullet_dir),

    .pos_x(oppo_x),
    .pos_y(oppo_y),

    .tank_state(oppo_ram_data)
);

// 玩家子弹
bullet player_bullets (
    .clk(clk),
    .reset(reset),
    .game_over(game_over),

    .fire(tank_bullet_fire),
    .bullet_direction(tank_bullet_dir),

    .init_x(tank_x),
    .init_y(tank_y),

    .oppo_x(oppo_x),
    .oppo_y(oppo_y),

    .hit(hit_opponent),

    .bullet_state(bullet_player_state)
);

// 敌人子弹
bullet enemy_bullets (
    .clk(clk),
    .reset(reset),
    .game_over(game_over),

    .fire(oppo_bullet_fire),
    .bullet_direction(oppo_bullet_dir),

    .init_x(oppo_x),
    .init_y(oppo_y),

    .oppo_x(tank_x),
    .oppo_y(tank_y),

    .hit(hit_player),

    .bullet_state(bullet_enemy_state)
);

generate
    genvar k;
    for (k = 0; k < MAX_BULLETS; k++) begin : map_player_bullets
        assign bullet_ram_data[k] = bullet_player_state[k];
    end
    for (k = 0; k < MAX_BULLETS; k++) begin : map_enemy_bullets
        assign bullet_ram_data[k + MAX_BULLETS] = bullet_enemy_state[k];
    end
endgenerate

always @(posedge clk) begin
    if (reset) begin
        game_over <= 0;
    end else begin
        if (hit_player || hit_opponent) begin
            game_over <= 1;
        end
    end
end


endmodule