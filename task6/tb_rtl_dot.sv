module tb_rtl_dot();

logic clk, rst_n;
// slave (CPU-facing)
logic slave_waitrequest, slave_read, slave_write;
logic [3:0] slave_address;
logic [31:0] slave_readdata, slave_writedata;
// master (SDRAM-facing)
logic [31:0] master_address, master_writedata, master_readdata;
logic master_read, master_readdatavalid, master_write, master_waitrequest;

dot dut(.*);

initial begin

    fp = 32'b1_1000000000000000;
    sp = 32'b1_1100000000000000;
    #10;
    sum = fp + sp;

end
endmodule: tb_rtl_dot
