// `timescale 1ns / 1ns

// module tank_engine #(
//   parameter OAM_WIDTH = 32, 
//   parameter OAM_DEPTH = 8,
//   parameter TILE_WIDTH = 32, //设为该对象的真实大小
//   parameter TILE_HEIGHT = 32,
//   parameter OAM_CACHE_DEPTH = 8
// ) (
//     input wire clk,
//     input wire video_on,
//     input wire [9:0] x, y,
//     input wire [31:0] oam_data,
//     output reg [2:0] oam_addr=0,
//     output wire sprite_on,
//     output wire [11:0] color
// );

//     reg [11:0] color_reg;
//     reg [6:0] rom_x, rom_y;
//     wire [11:0] tank_data;
//     wire [11:0] oppo_data;
//     wire [11:0] bullet_data;

//     integer i;
//     reg [OAM_WIDTH - 1:0] oam_cache [OAM_CACHE_DEPTH - 1:0];
//     reg [3:0] len;
//     reg [7:0] in_range, display_something;

//     reg obj_type = oam_cache[i][30:29];
//     `define OBJ_TYPE oam_cache[i][30:29]
//     `define OBJ_ENABLE oam_cache[i][28:28]
//     `define OBJ_POS_X oam_cache[i][27:18]
//     `define OBJ_POS_Y oam_cache[i][17:8]
//     `define OBJ_DIR oam_cache[i][7:6]
//     `define SPRITE_ROW oam_cache[i][5:3]
//     `define SPRITE_COL oam_cache[i][2:0]

//     //根据当前像素位置(x, y)和OAM数据(对象所在坐标OBJ_POS_X, OBJ_POS_Y)，计算出需要以ROM哪一个像素的颜色进行渲染
//     always @ (posedge clk) begin
//         oam_addr <= oam_addr + 1;
//         oam_cache[oam_addr] <= oam_data;
//         for (i = 0; i < OAM_CACHE_DEPTH; i = i + 1) begin
//         if (`OBJ_ENABLE)// 如果对象启用
//             if (x >= `OBJ_POS_X & x < `OBJ_POS_X + TILE_WIDTH & y >= `OBJ_POS_Y & y < `OBJ_POS_Y + TILE_HEIGHT) begin
                
//                 // 方向信息包括在SPRITE_ROW，SPRITE_COL中
//                 // 计算ROM地址
//                 rom_x <= `SPRITE_COL * TILE_WIDTH + (x - `OBJ_POS_X);
//                 rom_y <= `SPRITE_ROW * TILE_HEIGHT + (y - `OBJ_POS_Y);
                
//                 // 在每一个rom中都通过ROM地址获取颜色值，只选择对应类型
//                 // 我为什么要这样做来着？
//                 // 应该是方便复用
//                 case(obj_type)
//                     2'b00: color_reg <= tank_data;   // 坦克
//                     2'b01: color_reg <= oppo_data;   // 对手坦克
//                     default: color_reg <= 12'h000;    // 透明色
//                 endcase

//                 in_range[i] <= 1;
//                 //未处理重叠，后渲染覆盖
                
//             end else in_range[i] <= 0;
//         end 
//          $monitor("Time=%0t | x=%3d y=%3d | type=%b en=%b pos_x=%3d pos_y=%3d row=%b col=%b | rom_x=%2d rom_y=%2d | color=0x%h | in_range=%b | sprite_on=%b",
//                  $time,
//                  x, y,
//                  `OBJ_TYPE, `OBJ_ENABLE, `OBJ_POS_X, `OBJ_POS_Y, `SPRITE_ROW, `SPRITE_COL,
//                  rom_x, rom_y,
//                  color_reg,
//                  in_range[0],
//                  sprite_on);
//     end
    
//     player1_rom player1_rom(.clk(clk), .video_on(video_on), .x(rom_x), .y(rom_y), .color(tank_data));
//     player2_rom player2_rom(.clk(clk), .video_on(video_on), .x(rom_x), .y(rom_y), .color(oppo_data));

//     assign sprite_on = (color_reg == 12'h00f //透明色，需要设置为具体值
//                         | ~(|in_range) //没有在任何对象范围内
//                          ) ? 0 : 1;
//     assign color = color_reg;

// endmodule 

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
                rom_x <= `SPRITE_COL * 32 + (x - `OBJ_POS_X);
                rom_y <= `SPRITE_ROW * 32 + (y - `OBJ_POS_Y);

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