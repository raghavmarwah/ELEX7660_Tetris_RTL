create_clock -name {FPGA_CLK1_50} -period 20.000 [get_ports {FPGA_CLK1_50}]

set_max_skew -to [get_ports {lcd_scl lcd_cs lcd_rs lcd_sda}] 10

set_false_path -from * -to [get_ports lcd_rst]
