`timescale 1ns / 1ns
module vgac(
    input vga_clk,
    input clrn,
    input [11:0] d_in,
    output reg [9:0] row_addr,
    output reg [9:0] col_addr,
    output reg rdn,
    output reg [3:0] r,g,b,
    output reg hs, vs
);

    reg [9:0] h_count;// 水平计数器
    always @ (posedge vga_clk) begin
        if (!clrn) begin
            h_count <= 10'h0;
        end else if (h_count == 10'd799) begin
            h_count <= 10'h0;
        end else begin
            h_count <= h_count + 10'h1;
        end
    end

    reg [9:0] v_count; // 垂直计数器
    always @ (posedge vga_clk or negedge clrn) begin
        if (!clrn) begin
            v_count <= 10'h0;
        end else if (h_count == 10'd799) begin
            if (v_count == 10'd524) begin
                v_count <= 10'h0;
            end else begin
                v_count <= v_count + 10'h1;
            end
        end
    end

    wire  [9:0] row    =  v_count - 10'd35;
    wire  [9:0] col    =  h_count - 10'd144;
    wire        h_sync = (h_count > 10'd95);
    wire        v_sync = (v_count > 10'd1);
    wire        read   = (h_count > 10'd142) &&
                         (h_count < 10'd783) &&
                         (v_count > 10'd34)  &&
                         (v_count < 10'd515);

    always @ (posedge vga_clk) begin
        row_addr <=  row;
        col_addr <=  col;
        rdn      <= ~read;
        hs       <=  h_sync;
        vs       <=  v_sync;
        r        <=  rdn ? 4'h0 : d_in[3:0];
        g        <=  rdn ? 4'h0 : d_in[7:4];
        b        <=  rdn ? 4'h0 : d_in[11:8];
    end
endmodule