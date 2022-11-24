module dotoptact(input logic clk, input logic rst_n,
           // slave (CPU-facing)
           output logic slave_waitrequest,
           input logic [3:0] slave_address,
           input logic slave_read, output logic [31:0] slave_readdata,
           input logic slave_write, input logic [31:0] slave_writedata,

           // master (SDRAM-facing)
           input logic master_waitrequest,
           output logic [31:0] master_address,
           output logic master_read, input logic [31:0] master_readdata, input logic master_readdatavalid,
           output logic master_write, output logic [31:0] master_writedata);

           // master2 (SRAM-facing to bank0 and bank1)
           input logic master2_waitrequest,
           output logic [31:0] master2_address,
           output logic master2_read, input logic [31:0] master2_readdata, input logic master2_readdatavalid,
           output logic master2_write, output logic [31:0] master2_writedata);

    // your code here should start with the `dot` module, but add control for a second master port

endmodule: dotoptact
