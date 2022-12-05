module vga_avalon(input logic clk, input logic reset_n,
                  input logic [3:0] address,
                  input logic read, output logic [31:0] readdata,
                  input logic write, input logic [31:0] writedata,
                  output logic [7:0] vga_red, output logic [7:0] vga_grn, output logic [7:0] vga_blu,
                  output logic vga_hsync, output logic vga_vsync, output logic vga_clk);

    
    logic plot, VGA_BLANK, VGA_SYNC;
    logic [7:0] x;
    logic [6:0] y;
    logic [7:0] colour;
    logic [9:0] VGA_R, VGA_G, VGA_B;
    assign vga_red = VGA_R[9:2];
    assign vga_blu = VGA_B[9:2];
    assign vga_grn = VGA_G[9:2];

    vga_adapter #( .RESOLUTION("160x120"), .MONOCHROME("TRUE"), .BITS_PER_COLOUR_CHANNEL(8) )
	vga(.resetn(reset_n), .clock(clk), .colour(colour), .x(x), .y(y), .plot(plot), .VGA_R(VGA_R), 
    .VGA_G(VGA_B), .VGA_B(VGA_G), .VGA_HS(vga_hsync), .VGA_VS(vga_vsync), .VGA_CLK(vga_clk),
    .VGA_BLANK(VGA_BLANK), .VGA_SYNC(VGA_SYNC));

    assign x = writedata[23:16];
    assign y = writedata[30:24];
    assign colour = writedata[7:0];
    
    assign plot = write && address === 4'd0 ? (x < 160 && y < 120 && x >= 0 && y >= 0 ? 1'b1 : 1'b0) : 1'b0;
    

endmodule: vga_avalon
