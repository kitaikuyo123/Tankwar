`timescale 1ns / 1ns

module bullet_engine #(
  parameter OAM_WIDTH = 32,
  parameter OAM_DEPTH = 16,  // 支持最多 16 个子弹
  parameter TILE_WIDTH = 8,  // 子弹大小
  parameter TILE_HEIGHT = 8
) (
    input wire clk,
    input wire video_on,
    input wire [9:0] x, y,
    input wire [31:0] oam_data [15:0],
    output wire sprite_on,
    output wire [11:0] color
);

    reg [11:0] color_reg;
    reg [9:0] rom_x, rom_y;
    wire [11:0] bullet_data;

    integer i;
    reg display_flag = 0;

    // 定义宏用于访问 oam_data[i] 的各个字段
    `define OBJ_ENABLE(data)     (data[28])
    `define OBJ_POS_X(data)      (data[27:18])
    `define OBJ_POS_Y(data)      (data[17:8])
    `define SPRITE_ROW(data)     (data[5:3])
    `define SPRITE_COL(data)     (data[2:0])

    always @(posedge clk) begin
        if (video_on) begin
            display_flag <= 0;

            for (i = 0; i < OAM_DEPTH; i = i + 1) begin

                if (`OBJ_ENABLE(oam_data[i])) begin
                    if (x >= `OBJ_POS_X(oam_data[i]) &&
                        x <  `OBJ_POS_X(oam_data[i]) + TILE_WIDTH &&
                        y >= `OBJ_POS_Y(oam_data[i]) &&
                        y <  `OBJ_POS_Y(oam_data[i]) + TILE_HEIGHT) begin

                        // 计算 ROM 地址
                        rom_x <= `SPRITE_COL(oam_data[i]) * TILE_WIDTH + (x - `OBJ_POS_X(oam_data[i]));
                        rom_y <= `SPRITE_ROW(oam_data[i]) * TILE_HEIGHT + (y - `OBJ_POS_Y(oam_data[i]));

                        // 读取 ROM 数据
                        color_reg <= bullet_data;

                        display_flag <= 1;
                    end
                end
            end
        end
    end

    // 实例化 ROM
    bullet_rom bullet_rom (
        .clk(clk),
        .video_on(video_on),
        .x(rom_x),
        .y(rom_y),
        .color(bullet_data)
    );

    assign sprite_on = display_flag;
    assign color = color_reg;

endmodule