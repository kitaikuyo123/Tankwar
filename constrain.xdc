# ---------------------
# ��ʱ�ӣ�100 MHz��
# ---------------------
set_property PACKAGE_PIN AC18 [get_ports clk]
set_property IOSTANDARD LVCMOS18 [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]
# set_property -dict {PACKAGE_PIN AC18  IOSTANDARD LVCMOS18} [get_ports {clk}];

# ---------------------
# ��λ�źţ�ʹ�� BTN_Y[0]��
# ---------------------
# set_property PACKAGE_PIN V18 [get_ports reset]
# set_property IOSTANDARD LVCMOS18 [get_ports reset]
# set_property PULLUP true [get_ports reset]
set_property PACKAGE_PIN AF10 [get_ports reset]
set_property IOSTANDARD LVCMOS15 [get_ports reset]

# ---------------------
# VGA ����ź�
# ---------------------
## VGA
set_property -dict {PACKAGE_PIN T20   IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {VGA_b[0]}];
set_property -dict {PACKAGE_PIN R20   IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {VGA_b[1]}];
set_property -dict {PACKAGE_PIN T22   IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {VGA_b[2]}];
set_property -dict {PACKAGE_PIN T23   IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {VGA_b[3]}];
set_property -dict {PACKAGE_PIN R22   IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {VGA_g[0]}];
set_property -dict {PACKAGE_PIN R23   IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {VGA_g[1]}];
set_property -dict {PACKAGE_PIN T24   IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {VGA_g[2]}];
set_property -dict {PACKAGE_PIN T25   IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {VGA_g[3]}];
set_property -dict {PACKAGE_PIN N21   IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {VGA_r[0]}];
set_property -dict {PACKAGE_PIN N22   IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {VGA_r[1]}];
set_property -dict {PACKAGE_PIN R21   IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {VGA_r[2]}];
set_property -dict {PACKAGE_PIN P21   IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {VGA_r[3]}];
set_property -dict {PACKAGE_PIN M22   IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {hsync}];
set_property -dict {PACKAGE_PIN M21   IOSTANDARD LVCMOS33 SLEW FAST} [get_ports {vsync}];


# ---------------------
# PS/2 �ӿ�
# ---------------------
set_property PACKAGE_PIN N18 [get_ports ps2_clk]
set_property PACKAGE_PIN M19 [get_ports ps2_data]
set_property IOSTANDARD LVCMOS33 [get_ports {ps2_clk ps2_data}]


set_property PACKAGE_PIN AF24 [get_ports {ps2_up1}]
set_property IOSTANDARD LVCMOS33 [get_ports {ps2_up1}]
set_property PACKAGE_PIN AE21 [get_ports {ps2_down1}]
set_property IOSTANDARD LVCMOS33 [get_ports {ps2_down1}]
set_property PACKAGE_PIN Y22 [get_ports {ps2_left1}]
set_property IOSTANDARD LVCMOS33 [get_ports {ps2_left1}]
set_property PACKAGE_PIN Y23 [get_ports {ps2_right1}]
set_property IOSTANDARD LVCMOS33 [get_ports {ps2_right1}]

set_property PACKAGE_PIN AA23 [get_ports {ps2_up2}]
set_property IOSTANDARD LVCMOS33 [get_ports {ps2_up2}]
set_property PACKAGE_PIN Y25 [get_ports {ps2_down2}]
set_property IOSTANDARD LVCMOS33 [get_ports {ps2_down2}]
set_property PACKAGE_PIN AB25 [get_ports {ps2_left2}]
set_property IOSTANDARD LVCMOS33 [get_ports {ps2_left2}]
set_property PACKAGE_PIN W23 [get_ports {ps2_right2}]
set_property IOSTANDARD LVCMOS33 [get_ports {ps2_right2}]

# ---------------------
# ��������
# ---------------------
# buzzer
set_property PACKAGE_PIN AF25 [get_ports voice]
set_property IOSTANDARD LVCMOS33 [get_ports voice]


#  7-Segment Display
 set_property PACKAGE_PIN AD21 [get_ports {AN[0]}]
 set_property PACKAGE_PIN AC21 [get_ports {AN[1]}]
 set_property PACKAGE_PIN AB21 [get_ports {AN[2]}]
 set_property PACKAGE_PIN AC22 [get_ports {AN[3]}]
 set_property IOSTANDARD LVCMOS33 [get_ports {AN[*]}]

 set_property PACKAGE_PIN AB22 [get_ports {SEGMENT[0]}]
 set_property PACKAGE_PIN AD24 [get_ports {SEGMENT[1]}]
 set_property PACKAGE_PIN AD23 [get_ports {SEGMENT[2]}]
 set_property PACKAGE_PIN Y21 [get_ports {SEGMENT[3]}]
 set_property PACKAGE_PIN W20 [get_ports {SEGMENT[4]}]
 set_property PACKAGE_PIN AC24 [get_ports {SEGMENT[5]}]
 set_property PACKAGE_PIN AC23 [get_ports {SEGMENT[6]}]
 set_property PACKAGE_PIN AA22 [get_ports {SEGMENT[7]}]
 set_property IOSTANDARD LVCMOS33 [get_ports {SEGMENT[*]}]

#  LED ����
 set_property PACKAGE_PIN N26 [get_ports ledclk]
 set_property PACKAGE_PIN N24 [get_ports ledclrn]
 set_property PACKAGE_PIN M26 [get_ports ledsout]
 set_property PACKAGE_PIN P18 [get_ports LEDEN]
 set_property IOSTANDARD LVCMOS33 [get_ports {ledclk ledclrn ledsout LEDEN}]

#  ����
 set_property PACKAGE_PIN V19 [get_ports {BTN_Y[1]}]
 set_property PACKAGE_PIN V14 [get_ports {BTN_Y[2]}]
 set_property PACKAGE_PIN W14 [get_ports {BTN_Y[3]}]
 set_property IOSTANDARD LVCMOS18 [get_ports {BTN_Y[*]}]


set_property PACKAGE_PIN AA10 [get_ports {SW[0]}]
set_property PACKAGE_PIN AB10 [get_ports {SW[1]}]
set_property PACKAGE_PIN AA13 [get_ports {SW[2]}]
set_property PACKAGE_PIN AA12 [get_ports {SW[3]}]
set_property PACKAGE_PIN Y13 [get_ports {SW[4]}]
set_property PACKAGE_PIN Y12 [get_ports {SW[5]}]
set_property PACKAGE_PIN AD11 [get_ports {SW[6]}]
set_property PACKAGE_PIN AD10 [get_ports {SW[7]}]
set_property PACKAGE_PIN AE10 [get_ports {SW[8]}]
set_property PACKAGE_PIN AE12 [get_ports {SW[9]}]
set_property PACKAGE_PIN AF12 [get_ports {SW[10]}]
set_property PACKAGE_PIN AE8 [get_ports {SW[11]}]
set_property PACKAGE_PIN AF8 [get_ports {SW[12]}]
set_property PACKAGE_PIN AE13 [get_ports {SW[13]}]
set_property PACKAGE_PIN AF13 [get_ports {SW[14]}]
set_property PACKAGE_PIN AF10 [get_ports {SW[15]}]
set_property IOSTANDARD LVCMOS15 [get_ports {SW[0]}]
set_property IOSTANDARD LVCMOS15 [get_ports {SW[1]}]
set_property IOSTANDARD LVCMOS15 [get_ports {SW[2]}]
set_property IOSTANDARD LVCMOS15 [get_ports {SW[3]}]
set_property IOSTANDARD LVCMOS15 [get_ports {SW[4]}]
set_property IOSTANDARD LVCMOS15 [get_ports {SW[5]}]
set_property IOSTANDARD LVCMOS15 [get_ports {SW[6]}]
set_property IOSTANDARD LVCMOS15 [get_ports {SW[7]}]
set_property IOSTANDARD LVCMOS15 [get_ports {SW[8]}]
set_property IOSTANDARD LVCMOS15 [get_ports {SW[9]}]
set_property IOSTANDARD LVCMOS15 [get_ports {SW[10]}]
set_property IOSTANDARD LVCMOS15 [get_ports {SW[11]}]
set_property IOSTANDARD LVCMOS15 [get_ports {SW[12]}]
set_property IOSTANDARD LVCMOS15 [get_ports {SW[13]}]
set_property IOSTANDARD LVCMOS15 [get_ports {SW[14]}]
set_property IOSTANDARD LVCMOS15 [get_ports {SW[15]}]