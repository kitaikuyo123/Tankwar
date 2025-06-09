module PS2(
	input clk, rst,
	input ps2_clk, ps2_data,
	output reg up, down, left, right,	// 新增下键
	output reg w, a, s, d, space,		// 新增W/A/S/D和空格
	output reg enter
	);

// ---------------------- 信号定义 ----------------------
reg ps2_clk_falg0, ps2_clk_falg1, ps2_clk_falg2;
wire negedge_ps2_clk = !ps2_clk_falg1 & ps2_clk_falg2; // PS2时钟下降沿检测
reg negedge_ps2_clk_shift; // 同步到系统时钟的下降沿信号

reg [9:0] data;			// 扩展数据帧（{data_expand, data_break, temp_data[7:0]}）
reg data_break, data_done, data_expand;
reg [7:0] temp_data;	// 暂存8位数据
reg [3:0] num;			// 数据接收计数器（0~10）


// ---------------------- 时钟同步与边沿检测 ----------------------
// 三级寄存器同步PS2时钟（防亚稳态）
always@(posedge clk or posedge rst)begin
	if(rst)begin
		ps2_clk_falg0 <= 1'b0;
		ps2_clk_falg1 <= 1'b0;
		ps2_clk_falg2 <= 1'b0;
	end
	else begin
		ps2_clk_falg0 <= ps2_clk;
		ps2_clk_falg1 <= ps2_clk_falg0;
		ps2_clk_falg2 <= ps2_clk_falg1;
	end
end

// 同步下降沿信号到系统时钟域
always@(posedge clk)begin
	negedge_ps2_clk_shift <= negedge_ps2_clk; // 延迟一拍避免毛刺
end


// ---------------------- 数据接收计数器 ----------------------
always@(posedge clk or posedge rst)begin
	if(rst)
		num <= 4'd0;
	else if (num == 4'd11) // 11位数据接收完成后复位
		num <= 4'd0;
	else if (negedge_ps2_clk) // 每个PS2时钟下降沿递增
		num <= num + 1'b1;
end


// ---------------------- 串行数据转并行（提取8位数据） ----------------------
always@(posedge clk or posedge rst)begin
	if(rst)
		temp_data <= 8'd0;
	else if (negedge_ps2_clk_shift) begin // 在系统时钟上升沿采样数据
		case(num)
			4'd2 : temp_data[0] <= ps2_data; // 第2位对应数据位0（LSB）
			4'd3 : temp_data[1] <= ps2_data;
			4'd4 : temp_data[2] <= ps2_data;
			4'd5 : temp_data[3] <= ps2_data;
			4'd6 : temp_data[4] <= ps2_data;
			4'd7 : temp_data[5] <= ps2_data;
			4'd8 : temp_data[6] <= ps2_data;
			4'd9 : temp_data[7] <= ps2_data; // 第9位对应数据位7（MSB）
			default: temp_data <= temp_data;
		endcase
	end
end


// ---------------------- 数据帧解析（处理扩展键和断码） ----------------------
always@(posedge clk or posedge rst)begin
	if(rst)begin
		data_break  <= 1'b0;
		data        <= 10'd0;
		data_done   <= 1'b0;
		data_expand <= 1'b0;
	end
	else if(num == 4'd11) begin // 一帧数据接收完成（num从10跳转到0时触发）
		if(temp_data == 8'hE0) begin 		 // 扩展键前缀（如方向键）
			data_expand <= 1'b1; 			 // 标记下一包为扩展键
		end
		else if(temp_data == 8'hF0) begin 	 // 断码（按键释放）
			data_break <= 1'b1; 			 // 标记为释放事件
		end
		else begin 						 // 普通按键或组合键
			// 组合标志位和数据：{data_expand, data_break, temp_data[7:0]}
			data <= {data_expand, data_break, temp_data}; 
			data_done <= 1'b1; 				 // 数据有效标志
			// 重置标志位
			data_expand <= 1'b0;
			data_break  <= 1'b0;
		end
	end
end


// ---------------------- 按键状态映射（新增下键、W/A/S/D、空格） ----------------------
always @(posedge clk) begin
	// 初始化所有按键状态（避免锁存）
	up    <= 0;
	down  <= 0;
	left  <= 0;
	right <= 0;
	w     <= 0;
	a     <= 0;
	s     <= 0;
	d     <= 0;
	space <= 0;
	enter <= 0;

	// 按键状态更新逻辑
	case (data)
		// ---------------------- 方向键 ----------------------
		// 上键（扩展键，0xE0 + 0x75）
		10'h275: up    <= 1;	// 按下（{1,0,0x75}）
		10'h375: up    <= 0;	// 释放（{1,1,0x75}）
		// 下键（新增，扩展键，0xE0 + 0x72）
		10'h272: down  <= 1;	// 按下（{1,0,0x72}）
		10'h372: down  <= 0;	// 释放（{1,1,0x72}）
		// 左键（0xE0 + 0x6B）
		10'h26B: left  <= 1;	// 按下
		10'h36B: left  <= 0;	// 释放
		// 右键（0xE0 + 0x74）
		10'h274: right <= 1;	// 按下
		10'h374: right <= 0;	// 释放

		// ---------------------- W/A/S/D键 ----------------------
		// W键（通码0x1D，断码0xF0 0x1D）
		10'h01D: w <= 1;	// 按下（{0,0,0x1D}）
		10'h11D: w <= 0;	// 释放（{0,1,0x1D}）
		// A键（通码0x1C，断码0xF0 0x1C）
		10'h01C: a <= 1;	// 按下（注意：原Enter键通码也是0x1C，需确认键盘映射）
		10'h11C: a <= 0;	// 释放
		// S键（通码0x1B，断码0xF0 0x1B）
		10'h01B: s <= 1;	
		10'h11B: s <= 0;
		// D键（通码0x23，断码0xF0 0x23）
		10'h023: d <= 1;	
		10'h123: d <= 0;

		// ---------------------- 空格键 ----------------------
		// 空格键（通码0x29，断码0xF0 0x29）
		10'h029: space <= 1;	
		10'h129: space <= 0;

		// ---------------------- Enter键（保留原逻辑） ----------------------
		10'h05A: enter <= 1;	// 按下（原代码中Enter键通码为0x1C，此处可能存在冲突，需根据实际键盘调整）
		10'h15A: enter <= 0;	// 释放（{0,1,0x1C}，注意与A键断码冲突）
	endcase
end

endmodule