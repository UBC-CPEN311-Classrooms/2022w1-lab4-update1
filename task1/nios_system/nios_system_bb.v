
module nios_system (
	clk_clk,
	reset_reset_n,
	switches_export,
	leds_export);	

	input		clk_clk;
	input		reset_reset_n;
	input	[7:0]	switches_export;
	output	[7:0]	leds_export;
endmodule
