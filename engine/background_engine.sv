`timescale 1ns / 1ns
module background_engine(
    input wire clk,
    input wire video_on,
    input wire [9:0] x, y,
    output wire pixel_on,
    output wire [11:0] color
);
    reg [13:0] rom_addr;
    reg [6:0] rom_x, rom_y;
    wire [11:0] rom_data;
    parameter TILE_WIDTH = 32;
    parameter TILE_HEIGHT = 32;
    parameter TILE_COLS = 640 / TILE_WIDTH;
    parameter TILE_ROWS = 480 / TILE_HEIGHT;
    parameter WALL_COL = 3'b000;
    parameter WALL_ROW = 3'b011;
    parameter ROAD_COL = 3'b111;
    parameter ROAD_ROW = 3'b010;


    logic [0:15][0:15] map = '{
      '{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
      '{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
      '{1,0,1,1,0,1,0,1,0,1,0,1,0,1,0,1},
      '{1,0,1,0,0,0,0,0,0,0,0,1,0,1,0,1},
      '{1,0,1,0,1,1,1,0,1,1,1,0,0,1,0,1},
      '{1,0,1,0,0,0,0,0,0,0,0,0,0,1,0,1},
      '{1,0,1,0,1,1,1,0,0,1,1,1,0,1,0,1},
      '{1,0,1,0,0,0,0,0,0,0,0,0,0,1,0,1},
      '{1,0,1,0,1,1,1,0,1,1,1,0,0,1,0,1},
      '{1,0,1,0,0,0,0,0,0,0,0,0,0,1,0,1},
      '{1,0,1,1,0,1,0,1,0,1,0,1,0,1,0,1},
      '{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
      '{1,1,0,1,0,1,0,1,0,1,0,1,0,1,1,1},
      '{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
      '{1,0,1,1,0,1,0,1,0,1,0,1,0,1,0,1},
      '{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
    };

    //如果mapx和mapy在范围内，则取map的值
    //如果为1，col = 1，row = 1
    //如果为0，col = 0，row = 0
    wire [3:0] map_x = x[9:5];
    wire [3:0] map_y = y[9:5];

    bg_rom bg_rom(.clk(clk), .video_on(video_on), .x(rom_x), .y(rom_y), .color(rom_data));

    always @ (posedge clk) begin 
      if(map[map_y][map_x] == 1) begin
        rom_x = WALL_COL * TILE_WIDTH + x[4:0];
        rom_y = WALL_ROW * TILE_HEIGHT + y[4:0];
      end
      else if(map[map_y][map_x] == 0) begin
        rom_x = ROAD_COL * TILE_WIDTH + x[4:0];
        rom_y = ROAD_ROW * TILE_HEIGHT + y[4:0];
      end
      else begin
        rom_x = 0;
        rom_y = 0;
      end
    end

    assign pixel_on = ~(rom_data == 12'h00f); //透明色
    assign color = (rom_data == 12'h00f) ? 12'b0 : rom_data;

endmodule // background_engine
