`timescale 1ps / 1ps

module tb_vga_avalon();

// Your testbench goes here.
	logic clk, reset_n, read, write, vga_hsync, vga_vsync, vga_clk;
	logic [3:0] address;
	logic [31:0] readdata, writedata;
	logic [7:0] vga_red, vga_grn, vga_blu;
	
	vga_avalon dut(.*);
	
	initial forever
		#5 clk = ~clk;
		
	//always #5 clk = ~clk;
	
	initial begin
		#10;
		reset_n = 0;
		#10;
		reset_n = 1;
		#20;
        address = 4'd0;
		writedata = 32'h6432007F;//y=50,x=100,colour = 127,
		write = 1;
        #10;
		$display("y = 50, x = 100, colour = 127, write = 1", $time);
		assert(dut.plot == 1)
			else $error ("plot should be 1");
		#20;
		writedata = 32'h41A00078;//y=65, x=160, colour =120,//out of bound
		write = 1;
        #10;
		$display("y = 65, x = 160, colour = 120, write = 1", $time);
		assert(dut.plot == 0)
			else $error ("plot should be 0, x out of bound");
		#20;
		writedata = 32'h641000FF;//y=100,x=25,colour = 255
		write = 1;
        #10;
		$display("y = 100, x = 25, colour = 255, write = 1", $time);
		assert(dut.plot === 1'b1)
			else $error ("plot should be 1");
		#20;
		writedata = 32'h33650096;//y=51,x=101,colour=150//write = 0
		write = 0;//nothing should be printed
        #10;
		$display("y = 51, x = 101, colour = 150, write = 0", $time);
		assert(dut.plot == 0)
			else $error ("plot should be 0, write = 0");		
		#20;
		writedata = 32'h14410032;//y=20,x=65,colour =50
		write = 1;
        #10;
		$display("y = 20, x = 65, colour = 50, write = 1", $time);
		assert(dut.plot == 1)
			else $error ("plot should be 1");
		#20;
		writedata = 32'h798200E8;//y=121,x=130, colour = 232//out of bound
		write = 1;
        #10;
		$display("y = 121, x = 130, colour = 232, write = 1", $time);
		assert(dut.plot == 0)
			else $error ("plot should be 0, y out of bound");
		#20;
		$display("TB_FIN");
		$stop();
	end
	
endmodule: tb_vga_avalon
