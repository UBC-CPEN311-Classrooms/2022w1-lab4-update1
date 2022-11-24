module dotopt(input logic clk, input logic rst_n,
           // slave (CPU-facing)
           output logic slave_waitrequest,
           input logic [3:0] slave_address,
           input logic slave_read, output logic [31:0] slave_readdata,
           input logic slave_write, input logic [31:0] slave_writedata,

           // master_* (SDRAM-facing): weights (anb biases for task7)
           input logic master_waitrequest,
           output logic [31:0] master_address,
           output logic master_read, input logic [31:0] master_readdata, input logic master_readdatavalid,
           output logic master_write, output logic [31:0] master_writedata,

           // master2_* (SRAM-facing to bank0 and bank1): input activations (and output activations for task7)
           input logic master2_waitrequest,
           output logic [31:0] master2_address,
           output logic master2_read, input logic [31:0] master2_readdata, input logic master2_readdatavalid,
           output logic master2_write, output logic [31:0] master2_writedata);

    // your code: you may wish to start by copying code from your "dot" module, and then add control for master2_* port

endmodule: dotopt
