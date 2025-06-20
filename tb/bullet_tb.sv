`timescale 1ns / 1ps

module tb_bullet_move_counter();

    // ===== 参数定义 =====
    parameter MAX_BULLETS = 8;
    parameter MOVE_TIME = 5; // 缩短MOVE_TIME用于仿真测试

    // ===== 信号声明 =====
    reg clk;
    reg reset;
    reg fire;
    reg [1:0] bullet_direction;

    reg [9:0] init_x = 10'd100;
    reg [9:0] init_y = 10'd100;
    reg [9:0] oppo_x = 10'd200;
    reg [9:0] oppo_y = 10'd200;

    wire hit;
    wire [31:0] bullet_state [0:MAX_BULLETS-1];

    // ===== 实例化被测模块 =====
    bullet #(
        .MAX_BULLETS(MAX_BULLETS)
    ) uut (
        .clk(clk),
        .reset(reset),
        .game_over(1'b0),

        .fire(fire),
        .bullet_direction(bullet_direction),

        .init_x(init_x),
        .init_y(init_y),
        .oppo_x(oppo_x),
        .oppo_y(oppo_y),

        .hit(hit),
        .bullet_state(bullet_state)
    );

    // ===== 时钟生成 =====
    parameter CLK_PERIOD = 10;
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // ===== 测试过程 =====
    initial begin
        // 初始化
        reset = 1;
        fire = 0;
        bullet_direction = 2'b00; // 向上
        #20;
        reset = 0;

        // 等待一会后开火
        #50;
        fire = 1;
        #100;
        fire = 0;

        // 等待子弹创建并开始移动
        #100;

        // 打印 move_counter 的变化（如果需要可添加 $monitor）
        $display("Starting move counter simulation...");

        // 观察 move_counter 变化（假设你通过修改 bullet.sv 添加了 debug 输出）
        // 如果没有输出接口，可通过波形查看 bullet_state 或使用 $monitor

        #200;

        // 更换方向再次发射
        bullet_direction = 2'b01; // 向下
        fire = 1;
        #100;
        fire = 0;

        #200;

        // 结束仿真
        $finish;
    end

    // ===== 波形记录 =====
    initial begin
        $dumpfile("tb_bullet_move_counter.vcd");
        $dumpvars(0, tb_bullet_move_counter);
    end

    // ===== 调试输出 =====
    initial begin
        $monitor("Time=%0t | fire=%b | dir=%b | bullet_state[0]=%h", 
                 $time, fire, bullet_direction, bullet_state[0]);
    end

endmodule