`timescale 1ps / 1ps

module tb_rtl_wordcopy();

logic clk, rst_n;
// slave (CPU-facing)
logic slave_waitrequest, slave_read, slave_write;
logic [3:0] slave_address;
logic [31:0] slave_readdata, slave_writedata;
// master (SDRAM-facing)
logic [31:0] master_address, master_writedata, master_readdata;
logic master_read, master_readdatavalid, master_write, master_waitrequest;

wordcopy wc(.*);
dnn_accel_system_sdram_controller_test_component_ram_module sdram(master_writedata, master_address, master_read, 
                                                                    master_address, clk, master_write, master_readdata);

initial forever begin
    clk = 1; #5;
    clk = 0; #5;
end

initial begin

    $readmemh("test00.memh", sdram.mem_array);

    // rst_n = 1'b0; #10; rst_n = 1'b1; #10;

    // assert(!slave_waitrequest)
    //     else $error("%m Failed: slave_waitrequest no deasserted, CPU stalling");
    
    // slave_address = 4'd4;
    // slave_writedata = 32'd5;
    // #10;
    // assert(wc.destination === 32'd5)
    // else $error("%m Failed: Destination value incorrect");

    // slave_address = 4'd8;
    // slave_writedata = 32'd1;
    // #10;
    // assert(wc.store === 32'd1)
    // else $error("%m Failed: Store value incorrect");

    // slave_address = 4'd12;
    // slave_writedata = 32'd4;
    // #10;
    // assert(wc.n_words === 32'd4)
    // else $error("%m Failed: # of words incorrect");

    // slave_address = 32'b0;
    // slave_write = 1'b1;
    // #10;

    // master_waitrequest = 1'b0;
    // master_readdatavalid = 1'b1;
    // #600;

    $stop;

end


endmodule: tb_rtl_wordcopy
