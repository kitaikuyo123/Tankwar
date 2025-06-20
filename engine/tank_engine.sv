`timescale 1ns / 1ns

module tank_engine (
    input wire clk,
    input wire video_on,
    input wire [9:0] x, y,
    input wire [31:0] oam_data, // 单个对象数据
    output wire sprite_on,
    output wire [11:0] color
);

    // 宏定义用于访问 oam_data 字段
    `define OBJ_TYPE     oam_data[30:29]
    `define OBJ_ENABLE   oam_data[28]
    `define OBJ_POS_X    oam_data[27:18]
    `define OBJ_POS_Y    oam_data[17:8]
    `define SPRITE_ROW   oam_data[5:3]
    `define SPRITE_COL   oam_data[2:0]

    reg [11:0] color_reg;
    reg [6:0] rom_x, rom_y;
    reg in_range;
    wire [11:0] tank_data;
    wire [11:0] oppo_data;

    // 实例化 ROM
    player1_rom player1_rom(.clk(clk), .video_on(video_on), .x(rom_x), .y(rom_y), .color(tank_data));
    player2_rom player2_rom(.clk(clk), .video_on(video_on), .x(rom_x), .y(rom_y), .color(oppo_data));

    always @(posedge clk) begin
        if (video_on && `OBJ_ENABLE) begin
            if (x >= `OBJ_POS_X && x < `OBJ_POS_X + 32 &&
                y >= `OBJ_POS_Y && y < `OBJ_POS_Y + 32) begin
                
                in_range <= 1;
                // 计算 ROM 地址
                rom_y <= `SPRITE_ROW * 32 + (y - `OBJ_POS_Y);
                rom_x <= `SPRITE_COL * 32 + (x - `OBJ_POS_X);

                // 根据类型选择颜色
                case(`OBJ_TYPE)
                    2'b00: color_reg <= tank_data;   // 玩家坦克
                    2'b01: color_reg <= oppo_data;   // 对手坦克
                    default: color_reg <= 12'h000;    // 默认黑色
                endcase
            end
            else begin
                in_range <= 0;
            end
        end
    end

    // 输出控制
    assign sprite_on = (color_reg == 12'h00f || !`OBJ_ENABLE || !in_range) ? 0 : 1;
    assign color = color_reg;

endmodule