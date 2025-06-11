`timescale 1ns / 1ps

module clk_divider_4 (
    input      clk_in,
    input      reset,
    output reg clk_out
);

reg [1:0] count;

always @(posedge clk_in or negedge reset) begin
    if (!reset) begin
        count   <= 2'b00;
        clk_out <= 1'b0;
    end else begin
        count <= count + 1'b1;
        if (count == 2'b11) begin
            clk_out <= ~clk_out;  // 翻转输出时钟
            count   <= 2'b00;     // 重置计数器
        end
    end
end

endmodule