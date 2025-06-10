`timescale 1ns / 1ps

module bullet_rom(
  input wire clk,
  input wire video_on,
  input wire [9:0] x, y,
  output reg [11:0] color
);

wire [8:0] addr;
wire [11:0] data;

assign addr = y*8+ x; // 计算ROM地址

bull_rom bullet_rom_inst (
  .clka(clk),
  .ena(video_on), 
  .addra(addr),
  .douta(data)
);

always @(posedge clk)
  if (video_on) begin
    color <= data;
  end

endmodule