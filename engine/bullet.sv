`timescale 1ns / 1ps

module bullet #(
    parameter MAX_BULLETS = 8        // 最大子弹数量
)(
    input wire clk,
    input wire reset,
    input wire game_over,             // 游戏结束信号

    input wire fire,                  // 发射信号
    input wire [1:0] bullet_direction, // 子弹方向

    input wire [9:0] init_x, init_y, // 初始坐标
    input wire [9:0] oppo_x, oppo_y, // 敌人坐标

    output wire hit,                  // 是否击中敌人

    output wire [31:0] bullet_state [0:MAX_BULLETS-1] // 子弹状态信息
);

parameter BULLET_SPEED = 2;       // 移动速度控制
parameter TANK_SIZE = 32;         // 坦克大小（像素）
parameter BULLET_SIZE = 8;        // 子弹大小（像素）
parameter WALL = 1'b1;
parameter EMPTY = 1'b0;


function automatic [4:0] to_map_x(input [9:0] xy);
    return xy[9:5];  // X / 32
endfunction

function automatic [4:0] to_map_y(input [9:0] xy);
    return xy[9:5];  // Y / 32
endfunction

reg [9:0] bullet_x_reg [0:MAX_BULLETS-1]; // 子弹X坐标
reg [9:0] bullet_y_reg [0:MAX_BULLETS-1]; // 子弹Y坐标
reg [1:0] dir_reg [0:MAX_BULLETS-1];      // 方向
reg active [0:MAX_BULLETS-1];             // 是否活跃
reg [7:0] move_counter [0:MAX_BULLETS-1];// 移动计数器
reg hit_wall [0:MAX_BULLETS-1]; // 每颗子弹是否击中墙壁 // 是否击中墙壁

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

reg [2:0] rom_row [0:MAX_BULLETS-1]; // ROM行地址
reg [2:0] rom_col [0:MAX_BULLETS-1]; // ROM列地址

// 碰撞检测输出
reg [MAX_BULLETS-1:0] collision; // 每颗子弹是否击中敌人
assign hit = |collision; // 任意子弹击中敌人即为真

// 子弹地址 & 状态输出
generate
    genvar k;
    for (k = 0; k < MAX_BULLETS; k++) begin : bullet_outputs
        assign bullet_state[k] = {
            1'b0,           // 补0 1
            2'b01,           // 对象类型：子弹
            active[k],
            bullet_x_reg[k],
            bullet_y_reg[k],
            dir_reg[k],
            rom_row[k],
            rom_col[k]
        };
    end
endgenerate

always @(posedge clk) begin
    if (reset) begin
        for (int i = 0; i < MAX_BULLETS; i++) begin
            bullet_x_reg[i] <= 0;
            bullet_y_reg[i] <= 0;
            dir_reg[i] <= 0;
            active[i] <= 0;
            move_counter[i] <= 0;
        end
    end else begin
        // 发射新子弹
        if (fire) begin
            for (int i = 0; i < MAX_BULLETS; i++) begin
                if (!active[i]) begin
                    bullet_x_reg[i] <= init_x;
                    bullet_y_reg[i] <= init_y;
                    dir_reg[i] <= bullet_direction;
                    case (bullet_direction)
                        2'b00: begin // 上
                            rom_row[i] <= 3'b000;
                            rom_col[i] <= 3'b000;
                        end
                        2'b01: begin // 下
                            rom_row[i] <= 3'b000;
                            rom_col[i] <= 3'b001;
                        end
                        2'b10: begin // 左
                            rom_row[i] <= 3'b000;
                            rom_col[i] <= 3'b010;
                        end
                        2'b11: begin // 右
                            rom_row[i] <= 3'b000;
                            rom_col[i] <= 3'b011;
                        end
                        default: begin
                            rom_row[i] <= 3'b000;
                            rom_col[i] <= 3'b000;
                        end
                    endcase
                    active[i] <= 1;
                    move_counter[i] <= 0;
                    break;
                end
            end
        end

        // 更新所有子弹
        if(!game_over) begin
            for (int i = 0; i < MAX_BULLETS; i++) begin
                if (active[i]) begin
                    if (move_counter[i] >= BULLET_SPEED) begin
                        move_counter[i] <= 0;

                        case (dir_reg[i])
                            2'b00: bullet_y_reg[i] <= bullet_y_reg[i] - 32; // 上
                            2'b01: bullet_y_reg[i] <= bullet_y_reg[i] + 32; // 下
                            2'b10: bullet_x_reg[i] <= bullet_x_reg[i] - 32; // 左
                            2'b11: bullet_x_reg[i] <= bullet_x_reg[i] + 32; // 右
                        endcase
                    end else begin
                        move_counter[i] <= move_counter[i] + 1;
                    end

                    // 边界检测：子弹出界则消失
                    if ((bullet_x_reg[i] < 0) || (bullet_x_reg[i] >= 480) ||
                        (bullet_y_reg[i] < 0) || (bullet_y_reg[i] >= 480)) begin
                        active[i] <= 1'b0;
                    end

                    // 碰撞检测：是否击中敌人坦克
                    collision[i] <= (
                        active[i] &&
                        (bullet_x_reg[i] + BULLET_SIZE > oppo_x) &&
                        (bullet_x_reg[i] < oppo_x + TANK_SIZE) &&
                        (bullet_y_reg[i] + BULLET_SIZE > oppo_y) &&
                        (bullet_y_reg[i] < oppo_y + TANK_SIZE)
                    );



                    // 碰撞检测：是否击中墙壁
                    hit_wall[i] = (map[to_map_x(bullet_x_reg[i])][to_map_y(bullet_y_reg[i])] == WALL);

                    if (hit_wall[i]) begin
                        active[i] <= 1'b0; // 子弹碰到墙，清除  
                    end

                    if (collision[i]) begin
                        active[i] <= 1'b0;
                    end
                end
            end
        end
    end
end
endmodule