`timescale 1ns / 1ps

// 坦克控制模块
module tank #(
    parameter INIX,        // 初始X坐标
    parameter INIY,        // 初始Y坐标
    parameter PLAYER_INDEX
)(
    input wire clk, 
    input wire reset,
    input wire game_over,  // 视频使能信号
    input wire killed,      // 坦克被击中信号

    input wire up, 
    input wire down, 
    input wire left, 
    input wire right,
    input wire fire,

    output reg bullet_fire = 0,        // 子弹发射信号
    output reg [1:0] bullet_direction, // 子弹方向（与坦克一致）

    output reg [9:0] pos_x,       // 坦克X坐标
    output reg [9:0] pos_y,       // 坦克Y坐标

    output reg [31:0] tank_state       // 坦克状态信息
);

    // 参数定义
    parameter MOVE_TIME = 800000;
    parameter FIRE_TIME = 800000; // 发射子弹的时间间隔

    // 内部信号
    reg [2:0] rom_col, rom_row;        // 动画帧表地址
    reg [3:0] rom_col_next, rom_row_next; // 下一个动画帧表地址
    reg [1:0] tank_dir;                // 当前方向
    reg active = 1'b1;                 // 坦克是否存活
    reg [9:0] pos_x_next, pos_y_next;
    reg [1:0] tank_dir_next;
    reg bullet_fire_next;              // 下一个子弹发射状态
    reg [19:0] move_time_reg, move_time_next; // 移动时间计数器
    reg [19:0] fire_time_reg, fire_time_next; // 移动时间计数器

    logic [0:15][0:15] map = '{
        '{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},// 0
        '{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},// 1
        '{1,0,1,1,0,1,0,1,0,1,0,1,0,1,0,1},// 2
        '{1,0,1,0,0,0,0,0,0,0,0,1,0,1,0,1},// 3
        '{1,0,1,0,1,1,1,0,1,1,1,0,0,1,0,1},// 4
        '{1,0,1,0,0,0,0,0,0,0,0,0,0,1,0,1},// 5
        '{1,0,1,0,1,1,1,0,0,1,1,1,0,1,0,1},// 6
        '{1,0,1,0,0,0,0,0,0,0,0,0,0,1,0,1},// 7
        '{1,0,1,0,1,1,1,0,1,1,1,0,0,1,0,1},// 8
        '{1,0,1,0,0,0,0,0,0,0,0,0,0,1,0,1},// 9
        '{1,0,1,1,0,1,0,1,0,1,0,1,0,1,0,1},// 10
        '{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},// 11
        '{1,1,0,1,0,1,0,1,0,1,0,1,0,1,1,1},// 12
        '{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},// 13
        '{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},// 14
        '{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}// 15
    };

    // 坦克在地图中的位置索引
    wire [3:0] map_x_left = pos_x/32;              // X / 32
    wire [3:0] map_x_right = (pos_x + 31)/32;
    wire [3:0] map_y_up = pos_y/32;                // Y / 32
    wire [3:0] map_y_down = (pos_y + 31)/32;

    // 坦克状态打包
    assign tank_state = {
        1'b0,           // 补0 1
        2'(PLAYER_INDEX),   // 对象类型：坦克 2
        active,         // 是否存活 1
        pos_x,          // X坐标 10
        pos_y,          // Y坐标 10
        tank_dir,       // 方向 2
        rom_row,        // ROM行 3
        rom_col         // ROM列 3
    };

    // 初始化与状态更新
    always_ff @(posedge clk) begin
        if (reset) begin
            pos_x <= INIX;
            pos_y <= INIY;
            tank_dir <= 2'b00;
            active <= 1'b1;
            move_time_reg = 0;
            fire_time_reg = 0;
            rom_col <= 3'b000;
            rom_row <= 3'b000;

        end else begin
            pos_x <= pos_x_next;
            pos_y <= pos_y_next;
            tank_dir <= tank_dir_next;
            bullet_fire <= bullet_fire_next;
            bullet_direction <= tank_dir_next;
            
            move_time_reg <= move_time_next;
            fire_time_reg <= fire_time_next;

            rom_col <= rom_col_next;
            rom_row <= rom_row_next;

            if (killed)
                active <= 1'b0;
        end
    end

    always_comb begin
        pos_x_next = pos_x;
        pos_y_next = pos_y;
        tank_dir_next = tank_dir;
        bullet_fire_next = bullet_fire;
        move_time_next = move_time_reg;
        fire_time_next = fire_time_reg;
        rom_col_next = rom_col;
        rom_row_next = rom_row;

        if (left) begin
            tank_dir_next = 2'b00;
            rom_row_next = 3'b000;
            rom_col_next = 3'b000;

            if(move_time_reg > 0) begin
                move_time_next = move_time_reg - 1;
            end else if (move_time_reg == 0) begin
                if ((map_y_up == 0) ||
                    (map[map_x_left][(pos_y-1)/32] == 1) ||
                    (map[map_x_right][(pos_y-1)/32] == 1)) begin
                    pos_y_next = pos_y;
                end else begin
                    pos_y_next = pos_y - 1;
                    move_time_next = MOVE_TIME;
                end
            end
        end else if (right) begin
            tank_dir_next = 2'b01;
            rom_row_next = 3'b000;
            rom_col_next = 3'b001;
            if (move_time_reg > 0) begin
                move_time_next = move_time_reg - 1;
            end else if (move_time_reg == 0) begin
                if ((map_y_down == 15) ||
                    (map[map_x_left][(pos_y+32)/32] == 1) ||
                    (map[map_x_right][(pos_y+32)/32] == 1)) begin
                    pos_y_next = pos_y;
                end else begin
                    pos_y_next = pos_y + 1;
                    move_time_next = MOVE_TIME;
                end
            end
        end else if (up) begin
            tank_dir_next = 2'b10;
            rom_row_next = 3'b000;
            rom_col_next = 3'b010;
            if (move_time_reg > 0) begin
                move_time_next = move_time_reg - 1;
            end else if (move_time_reg == 0) begin
                if ((map_x_left == 0) ||
                    (map[(pos_x-1)/32][map_y_up] == 1) ||
                    (map[(pos_x-1)/32][map_y_down] == 1)) begin
                    pos_x_next = pos_x;
                end else begin
                    pos_x_next = pos_x - 1;
                    move_time_next = MOVE_TIME;
                end
            end
        end else if (down) begin
            tank_dir_next = 2'b11;
            rom_row_next = 3'b000;
            rom_col_next = 3'b011;
            if (move_time_reg > 0) begin
                move_time_next = move_time_reg - 1; 
            end else if (move_time_reg == 0) begin
                if ((map_x_right == 15) ||
                    (map[(pos_x+32)/32][map_y_up] == 1) ||
                    (map[(pos_x+32)/32][map_y_down] == 1)) begin
                    pos_x_next = pos_x;
                end else begin
                    pos_x_next = pos_x + 1;
                    move_time_next = MOVE_TIME;
                end
            end
        end
        else begin
            move_time_next = MOVE_TIME;
            fire_time_next = FIRE_TIME;
        end
    end        

endmodule