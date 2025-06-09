# ---------------------
# 主时钟（100 MHz）
# ---------------------
set_property PACKAGE_PIN AC18 [get_ports clk]
set_property IOSTANDARD LVCMOS18 [get_ports clk]
create_clock -period 10.000 -name clk [get_ports "clk"]

# ---------------------
# 复位信号（使用 BTN_Y[0]）
# ---------------------
set_property PACKAGE_PIN V18 [get_ports reset]
set_property IOSTANDARD LVCMOS18 [get_ports reset]
set_property PULLUP true [get_ports reset]

# ---------------------
# VGA 输出信号
# ---------------------

# 蓝色通道 (4 bits)
set_property PACKAGE_PIN T20 [get_ports {VGA_b[0]}]
set_property PACKAGE_PIN R20 [get_ports {VGA_b[1]}]
set_property PACKAGE_PIN T22 [get_ports {VGA_b[2]}]
set_property PACKAGE_PIN T23 [get_ports {VGA_b[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_b[*]}]

# 绿色通道 (4 bits)
set_property PACKAGE_PIN R22 [get_ports {VGA_g[0]}]
set_property PACKAGE_PIN R23 [get_ports {VGA_g[1]}]
set_property PACKAGE_PIN T24 [get_ports {VGA_g[2]}]
set_property PACKAGE_PIN T25 [get_ports {VGA_g[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_g[*]}]

# 红色通道 (4 bits)
set_property PACKAGE_PIN N21 [get_ports {VGA_r[0]}]
set_property PACKAGE_PIN N22 [get_ports {VGA_r[1]}]
set_property PACKAGE_PIN R21 [get_ports {VGA_r[2]}]
set_property PACKAGE_PIN P21 [get_ports {VGA_r[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_r[*]}]

# 同步信号
set_property PACKAGE_PIN M22 [get_ports hsync]
set_property PACKAGE_PIN M21 [get_ports vsync]
set_property IOSTANDARD LVCMOS33 [get_ports {hsync vsync}]

# ---------------------
# PS/2 接口
# ---------------------
set_property PACKAGE_PIN N18 [get_ports ps2_clk]
set_property PACKAGE_PIN M19 [get_ports ps2_data]
set_property IOSTANDARD LVCMOS33 [get_ports {ps2_clk ps2_data}]

# ---------------------
# 其他外设
# ---------------------

# 7-Segment Display
# set_property PACKAGE_PIN AD21 [get_ports {AN[0]}]
# set_property PACKAGE_PIN AC21 [get_ports {AN[1]}]
# set_property PACKAGE_PIN AB21 [get_ports {AN[2]}]
# set_property PACKAGE_PIN AC22 [get_ports {AN[3]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {AN[*]}]

# set_property PACKAGE_PIN AB22 [get_ports {SEGMENT[0]}]
# set_property PACKAGE_PIN AD24 [get_ports {SEGMENT[1]}]
# set_property PACKAGE_PIN AD23 [get_ports {SEGMENT[2]}]
# set_property PACKAGE_PIN Y21 [get_ports {SEGMENT[3]}]
# set_property PACKAGE_PIN W20 [get_ports {SEGMENT[4]}]
# set_property PACKAGE_PIN AC24 [get_ports {SEGMENT[5]}]
# set_property PACKAGE_PIN AC23 [get_ports {SEGMENT[6]}]
# set_property PACKAGE_PIN AA22 [get_ports {SEGMENT[7]}]
# set_property IOSTANDARD LVCMOS33 [get_ports {SEGMENT[*]}]

# LED 控制
# set_property PACKAGE_PIN N26 [get_ports ledclk]
# set_property PACKAGE_PIN N24 [get_ports ledclrn]
# set_property PACKAGE_PIN M26 [get_ports ledsout]
# set_property PACKAGE_PIN P18 [get_ports LEDEN]
# set_property IOSTANDARD LVCMOS33 [get_ports {ledclk ledclrn ledsout LEDEN}]

# 开关
# set_property PACKAGE_PIN AA10 [get_ports {SW[0]}]
# set_property PACKAGE_PIN AB10 [get_ports {SW[1]}]
# ... 可按需添加 SW[2:15]

# 按键
# set_property PACKAGE_PIN V19 [get_ports {BTN_Y[1]}]
# set_property PACKAGE_PIN V14 [get_ports {BTN_Y[2]}]
# set_property PACKAGE_PIN W14 [get_ports {BTN_Y[3]}]
# set_property IOSTANDARD LVCMOS18 [get_ports {BTN_Y[*]}]