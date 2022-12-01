module vga_avalon(input logic clk, input logic reset_n,
                  input logic [3:0] address,
                  input logic read, output logic [31:0] readdata,
                  input logic write, input logic [31:0] writedata,
                  output logic [7:0] vga_red, output logic [7:0] vga_grn, output logic [7:0] vga_blu,
                  output logic vga_hsync, output logic vga_vsync, output logic vga_clk);

    
    // your Avalon slave implementation goes here
	logic VGA_BLANK, VGA_SYNC;
	logic [6:0] y_coord;
	logic [7:0] x_coord;
	logic [7:0] brightness;
	
	assign y_coord = readdata[30:24];//or writedata?
	assign x_coord = readdata[23:16];
	assign brightness = readdata[7:0];

    vga_adapter #( .RESOLUTION("160x120"), .MONOCHROME("TRUE"), .BITS_PER_COLOUR_CHANNEL(8) )
	vga(.resetn(reset_n), .clock(clk), .x(x_coord), .y(y_coord), .colour(brightness), 
			.plot(write), .VGA_R(vga_red), .VGA_G(vga_grn), 
			.VGA_B(vga_blu), .VGA_HS(vga_hsync), .VGA_VS(vga_vsync), 
			.VGA_BLANK(VGA_BLANK), .VGA_SYNC(VGA_SYNC), .VGA_CLK(vga_clk));  /* connect ports */ );

    // NOTE: We will ignore the SYNC and BLANK signals.
    //       Either don't connect them or connect them to dangling wires.
    //       In addition, the VGA_{R,G,B} should be the low 8 bits of the VGA module outputs.



endmodule: vga_avalon
