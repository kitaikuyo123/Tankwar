`timescale 1ns / 1ps

module tank_tb;

    // 定义常量
    parameter CLK_PERIOD = 10; // 10 ns时钟周期，即100MHz

    // 声明信号
    logic clk;
    logic reset;
    logic killed;
    logic up, down, left, right, fire;

    wire bullet_fire;
    wire [1:0] bullet_direction;
    wire [9:0] pos_x;
    wire [9:0] pos_y;
    wire [2:0] tank_addr;
    wire [31:0] tank_state;

    // 实例化被测模块
    tank uut (
        .clk(clk),
        .reset(reset),
        .killed(killed),
        .up(up),
        .down(down),
        .left(left),
        .right(right),
        .fire(fire),
        .bullet_fire(bullet_fire),
        .bullet_direction(bullet_direction),
        .pos_x(pos_x),
        .pos_y(pos_y),
        .tank_addr(tank_addr),
        .tank_state(tank_state)
    );

    // 生成时钟
    always begin
        #5 clk = ~clk;
    end

    // 初始测试过程
    initial begin
        // 初始化所有输入信号
        clk = 0;
        reset = 1;
        killed = 0;
        up = 0;
        down = 0;
        left = 0;
        right = 0;
        fire = 0;

        // 复位
        #10 reset = 0;

        // 等待一段时间
        #20;

        // 向上移动
        up = 1;
        #40;
        up = 0;

        // 向下移动
        down = 1;
        #50;
        down = 0;

        // 向左移动
        left = 1;
        #40;
        left = 0;

        // 向右移动
        right = 1;
        #40;
        right = 0;

        // 开火
        fire = 1;
        #50;
        fire = 0;

        // 再次等待
        #100;

        // 击毁坦克
        killed = 1;
        #20;

        // 结束仿真
        $finish;
    end

    // 监控信号变化（可选）
    initial begin
        $monitor("Time=%0t | pos_x=%d | pos_y=%d | bullet_fire=%b | tank_state=0x%h",
                 $time, pos_x, pos_y, bullet_fire, tank_state);
    end

endmodule