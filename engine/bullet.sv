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

    parameter MOVE_TIME = 80000000;
    parameter TANK_SIZE = 32;         // 坦克大小（像素）
    parameter BULLET_SIZE = 8;        // 子弹大小（像素）
    parameter WALL = 1'b1;
    parameter EMPTY = 1'b0;

    reg [9:0] bullet_x_reg [0:MAX_BULLETS-1]; // 子弹X坐标
    reg [9:0] bullet_y_reg [0:MAX_BULLETS-1]; // 子弹Y坐标
    reg [1:0] dir_reg [0:MAX_BULLETS-1];      // 方向
    reg active [0:MAX_BULLETS-1];             // 是否活跃
    reg [19:0] move_counter [0:MAX_BULLETS-1];// 移动计数器
    reg hit_wall [0:MAX_BULLETS-1]; // 每颗子弹是否击中墙壁 // 是否击中墙壁

    reg [9:0] bullet_x_next [0:MAX_BULLETS-1]; // 下一个X坐标
    reg [9:0] bullet_y_next [0:MAX_BULLETS-1]; // 下一个Y坐标
    reg [1:0] dir_next [0:MAX_BULLETS-1];      // 下一个方向
    reg active_next [0:MAX_BULLETS-1];         // 下一个活跃状态
    reg [19:0] move_counter_next [0:MAX_BULLETS-1]; // 下一个移动计数器
    reg hit_wall_next [0:MAX_BULLETS-1]; // 下一个是否击中墙壁
    reg [2:0] rom_row_next [0:MAX_BULLETS-1]; // 下一个ROM行地址
    reg [2:0] rom_col_next [0:MAX_BULLETS-1]; // 下一个ROM列地址
    reg [MAX_BULLETS-1:0] collision_next; // 下一个碰撞检测结果

    reg [19:0] create_bullet_counter = 0; // 创建子弹计数器
    reg [19:0] create_bullet_counter_next; // 下一个创建子弹计数器

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
                1'b0,           // 补0 
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
                move_counter[i] <= MOVE_TIME;
                hit_wall[i] <= 0;
                rom_row[i] <= 0;
                rom_col[i] <= 0;
                collision[i] <= 0;
                create_bullet_counter <= 800000;
            end
        end else begin
            for (int i = 0; i < MAX_BULLETS; i++) begin
                bullet_x_reg[i] <= bullet_x_next[i];
                bullet_y_reg[i] <= bullet_y_next[i];
                dir_reg[i] <= dir_next[i];
                active[i] <= active_next[i];
                move_counter[i] <= move_counter_next[i];
                hit_wall[i] <= hit_wall_next[i];
                rom_row[i] <= rom_row_next[i];
                rom_col[i] <= rom_col_next[i];
                collision[i] <= collision_next[i];
            end
        end
    end

    always_comb begin
        for (int i = 0; i < MAX_BULLETS; i++) begin
            bullet_x_next[i] = bullet_x_reg[i];
            bullet_y_next[i] = bullet_y_reg[i];
            dir_next[i] = dir_reg[i];
            active_next[i] = active[i];
            move_counter_next[i] = move_counter[i];
            hit_wall_next[i] = hit_wall[i];
            rom_row_next[i] = rom_row[i];
            rom_col_next[i] = rom_col[i];
            collision_next[i] = collision[i];
            create_bullet_counter_next = create_bullet_counter;
        end

        if (fire) begin
            if (create_bullet_counter > 0) begin
                create_bullet_counter_next = create_bullet_counter - 1;
            end else if (create_bullet_counter == 0) begin
                create_bullet_counter_next = 800000; // 重置计数器
                for (int i = 0; i < MAX_BULLETS; i++) begin
                    if (!active[i]) begin
                        dir_next[i] = bullet_direction;
                        active_next[i] = 1;
                        move_counter_next[i] = MOVE_TIME;
                        hit_wall_next[i] = 0;
                        collision_next[i] = 0;
                        case (bullet_direction)
                            2'b00: begin // 上
                                bullet_x_next[i] = init_x+12;
                                bullet_y_next[i] = init_y-8;
                                rom_row_next[i] = 3'b000;
                                rom_col_next[i] = 3'b001;
                            end
                            2'b01: begin // 下
                                bullet_x_next[i] = init_x+12;
                                bullet_y_next[i] = init_y+32;
                                rom_row_next[i] = 3'b000;
                                rom_col_next[i] = 3'b000;
                            end
                            2'b10: begin // 左
                                bullet_x_next[i] = init_x-8;
                                bullet_y_next[i] = init_y+12;
                                rom_row_next[i] = 3'b000;
                                rom_col_next[i] = 3'b011;
                            end
                            2'b11: begin // 右
                                bullet_x_next[i] = init_x+32;
                                bullet_y_next[i] = init_y+12;
                                rom_row_next[i] = 3'b000;
                                rom_col_next[i] = 3'b010;
                            end
                            default: begin
                                rom_row_next[i] = 3'b000;
                                rom_col_next[i] = 3'b000;
                            end
                        endcase
                        break;
                    end
                end
            end
        end

        /*
         碰到墙会消失
        */

        for (int i = 0; i < MAX_BULLETS; i++) begin
            if (active[i]) begin
                if (move_counter[i] > 0) begin
                    move_counter_next[i] = move_counter[i] - 1;
                end else if (move_counter[i] == 0) begin
                    move_counter_next[i] = MOVE_TIME;
                    case (dir_reg[i])
                        2'b10: begin 
                            if ((bullet_x_reg[i] > 0) && 
                                (map[(bullet_x_reg[i]-1)/32][bullet_y_reg[i]/32] != 1 )&&
                                (map[(bullet_x_reg[i]-1)/32][(bullet_y_reg[i] + 7)/32] != 1)) begin
                                bullet_x_next[i] = bullet_x_reg[i] - 1;
                            end else begin
                                active_next[i] = 1'b0; 
                            end
                        end
                        2'b11: begin 
                            if ((bullet_x_reg[i] < 16*32 - 1) && 
                                (map[(bullet_x_reg[i] + 8)/32][bullet_y_reg[i]/32] != 1) && 
                                (map[(bullet_x_reg[i] + 8)/32][(bullet_y_reg[i]+7)/32] != 1)) begin
                                bullet_x_next[i] = bullet_x_reg[i] + 1;
                            end else begin
                                active_next[i] = 1'b0;
                            end
                        end
                        2'b00: begin 
                            if ((bullet_y_reg[i] > 0) && 
                                (map[bullet_x_reg[i]/32][(bullet_y_reg[i] - 1)/32] != 1) &&
                                (map[(bullet_x_reg[i]+7)/32][(bullet_y_reg[i] - 1)/32] != 1)) begin
                                bullet_y_next[i] = bullet_y_reg[i] - 1;
                            end else begin
                                active_next[i] = 1'b0;
                            end
                        end
                        2'b01: begin 
                            if ((bullet_y_reg[i] < 16*32 - 1) && 
                                (map[bullet_x_reg[i]/32][(bullet_y_reg[i] + 8)/32] != 1) &&
                                (map[(bullet_x_reg[i]+7)/32][(bullet_y_reg[i] + 8)/32] != 1)) begin
                                bullet_y_next[i] = bullet_y_reg[i] + 1;
                            end else begin
                                active_next[i] = 1'b0;
                            end
                        end
                    endcase
                end
            end

            //     // 碰撞检测：是否击中对方坦克
            // collision[i] = (
            //     active[i] &&
            //     (bullet_x_next[i] + BULLET_SIZE > oppo_x) &&
            //     (bullet_x_next[i] < oppo_x + TANK_SIZE) &&
            //     (bullet_y_next[i] + BULLET_SIZE > oppo_y) &&
            //     (bullet_y_next[i] < oppo_y + TANK_SIZE)
            // );
        end


        // end
    end

endmodule