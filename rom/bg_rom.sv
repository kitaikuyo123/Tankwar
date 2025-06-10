`timescale 1ns / 1ps

module bg_rom(
  input wire clk,
  input wire video_on,
  input wire [9:0] x, y,
  output reg [11:0] color
);

wire [15:0] addr;
wire [11:0] data;

assign addr = y*256+x; // 计算ROM地址

background_rom bg_rom_inst (
  .clka(clk),
  .ena(video_on), // 仅在视频有效时读取
  .addra(addr),
  .douta(data)
);

always @(posedge clk)
  if (video_on) begin
    color <= data;
  end

endmodule