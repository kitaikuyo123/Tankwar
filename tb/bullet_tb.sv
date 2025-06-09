// Testbench for bullet module
module tb_bullet;

    // Parameters
    parameter MAX_BULLETS = 8;

    // Inputs
    reg clk;
    reg reset;
    reg fire;
    reg [1:0] bullet_direction;
    reg [9:0] init_x, init_y; // 初始坐标
    reg [9:0] oppo_x, oppo_y; // 敌人坐标

    // Outputs
    wire hit;
    wire [2:0] bullet_addr [0:MAX_BULLETS-1];
    wire [31:0] bullet_state [0:MAX_BULLETS-1];

    // Instantiate the DUT (Device Under Test)
    bullet uut (
        .clk(clk),
        .reset(reset),
        .fire(fire),
        .bullet_direction(bullet_direction),
        .init_x(init_x),
        .init_y(init_y),
        .oppo_x(oppo_x),
        .oppo_y(oppo_y),
        .hit(hit),
        .bullet_addr(bullet_addr),
        .bullet_state(bullet_state)
    );

    // Clock generation
    always begin
        #5 clk = ~clk; // 10ns周期时钟
    end

    // Test process
    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        fire = 0;
        bullet_direction = 2'b00;
        init_x = 10'd32;
        init_y = 10'd128;
        oppo_x = 10'd32;
        oppo_y = 10'd64;

        #20; // 等待几个时钟周期
        reset = 0;

        // 第一次发射子弹
        fire = 1;
        bullet_direction = 2'b00; // 向上
        #10;
        fire = 0;

        // 等待一段时间后第二次发射
        #200;

        // // 第二次发射子弹
        // fire = 1;
        // bullet_direction = 2'b11; // 向右
        // #10;
        // fire = 0;

        // // 运行一段时间，观察输出
        // #1000;

        // 结束仿真
        $finish;
    end

    // $monitor("Time=%0t | CONDITION0 %0d | CONDITION1 %0d,%0d | CONDITION2 %0d,%0d | CONDITION3 %0d,%0d | CONDITION4 %0d,%0d",
    // $time,
    // active[i],
    // bullet_x_reg[i] + BULLET_SIZE, oppo_x,
    // bullet_x_reg[i], oppo_x + TANK_SIZE,
    // bullet_y_reg[i] + BULLET_SIZE, oppo_y,
    // bullet_y_reg[i], oppo_y + TANK_SIZE,
    // );

    // // Monitor 输出信号
    // initial begin
    //     $monitor("Time: %0t | Hit: %b | Bullet State[0]: %b", $time, hit, bullet_state[0]);
    // end

endmodule