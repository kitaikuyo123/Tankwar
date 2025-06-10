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

    output reg [2:0] tank_addr = 0,    // OAM地址索引
    output reg [31:0] tank_state       // 坦克状态信息
);

    // 参数定义
    parameter FIRE_COOLDOWN = 4;   // 开火冷却时间

    // 内部信号
    reg [2:0] rom_col, rom_row;        // 动画帧表地址
    reg [1:0] tank_dir;                // 当前方向
    reg active = 1'b1;                 // 坦克是否存活
    reg [9:0] pos_x_next, pos_y_next;
    reg [1:0] tank_dir_next;
    reg [9:0] fire_timer = 0;              // 定时器计数器
    reg can_fire = 0;   // 是否可以开火

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
        '{1,0,1,1,0,1,0,1,0,1,0,1,0,1,0,1},// 14
        '{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}// 15
    };

// logic [0:15][0:15] map = '{
//     '{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}, // 原 0~15 行的第0列
//     '{1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1},
//     '{1,0,1,1,1,1,1,1,1,1,1,0,0,0,1,1},
//     '{1,0,1,0,0,0,0,0,0,0,0,0,1,0,1,1},
//     '{1,0,0,0,1,1,1,1,1,1,1,0,0,0,0,1},
//     '{1,0,1,0,0,0,0,0,0,0,0,0,1,0,1,1},
//     '{1,0,0,0,1,1,1,1,1,1,1,0,0,0,0,1},
//     '{1,0,1,0,0,0,0,0,0,0,0,0,1,0,1,1},
//     '{1,0,0,0,1,1,0,0,1,1,1,0,0,0,0,1},
//     '{1,0,1,0,1,0,1,0,1,0,0,0,1,0,1,1},
//     '{1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,1},
//     '{1,0,1,1,1,1,1,1,1,1,0,0,1,0,1,1},
//     '{1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1},
//     '{1,0,1,0,1,0,1,0,1,0,0,0,0,0,0,1},
//     '{1,0,0,0,0,0,0,0,0,0,1,0,1,0,0,1},
//     '{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
// };

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
            fire_timer <= 0;
            can_fire <= 1'b1;
            active <= 1'b1;
        end else if(!game_over) begin
            pos_x <= pos_x_next;
            pos_y <= pos_y_next;
            tank_dir <= tank_dir_next;
            bullet_fire <= can_fire & fire;
            bullet_direction <= can_fire & tank_dir;
            if (fire & can_fire) begin
                fire_timer = FIRE_COOLDOWN; // 开火冷却时间
                can_fire = 1'b0; // 设置为不可开火状态
            end 
            if (fire_timer > 0) begin
                fire_timer <= fire_timer - 1; // 减少冷却时间
            end else begin
                can_fire <= 1'b1; // 冷却结束，可以再次开火
            end
            if (killed)
                active <= 1'b0;
        end else begin
            pos_x <= pos_x;     // 冻结 X 坐标
            pos_y <= pos_y;     // 冻结 Y 坐标
            tank_dir <= tank_dir; // 冻结方向
        end
    end

    // 坦克动画帧选择
    always_comb begin
        if (killed) begin
            rom_row = 3'b000;
            rom_col = 3'b000;
        end else begin
            case (tank_dir)
                2'b00: {rom_row, rom_col} = {3'b000, 3'b000}; // 向上
                2'b01: {rom_row, rom_col} = {3'b000, 3'b001}; // 向下
                2'b10: {rom_row, rom_col} = {3'b000, 3'b010}; // 向左
                2'b11: {rom_row, rom_col} = {3'b000, 3'b011}; // 向右
                default: {rom_row, rom_col} = {3'b000, 3'b000};
            endcase
        end
    end

    // 坦克移动与开火逻辑
    always_comb begin
        // 默认不移动
        pos_x_next = pos_x;
        pos_y_next = pos_y;
        tank_dir_next = tank_dir;


        if (active & !game_over) begin
            if (up) begin
                tank_dir_next = 2'b00;
                if ((map_y_up == 0) ||
                    (map[map_x_left][map_y_up-1] == 1) ||
                    (map[map_x_right][map_y_up-1] == 1)) begin
                    pos_y_next = pos_y;
                end else begin
                    pos_y_next = pos_y - 32;
                end
            end else if (down) begin
                tank_dir_next = 2'b01;
                if ((map_y_down == 15) ||
                    (map[map_x_left][map_y_down+1] == 1) ||
                    (map[map_x_right][map_y_down+1] == 1)) begin
                    pos_y_next = pos_y;
                end else begin
                    pos_y_next = pos_y + 32;
                end
            end else if (left) begin
                tank_dir_next = 2'b10;
                if ((map_x_left == 0) ||
                    (map[map_x_left-1][map_y_up] == 1) ||
                    (map[map_x_left-1][map_y_down] == 1)) begin
                    pos_x_next = pos_x;
                end else begin
                    pos_x_next = pos_x - 32;
                end
            end else if (right) begin
                tank_dir_next = 2'b11;
                if ((map_x_right == 15) ||
                    (map[map_x_right+1][map_y_up] == 1) ||
                    (map[map_x_right+1][map_y_down] == 1)) begin
                    pos_x_next = pos_x;
                end else begin
                    pos_x_next = pos_x + 32;
                end
            end


        end
        
    end

endmodule