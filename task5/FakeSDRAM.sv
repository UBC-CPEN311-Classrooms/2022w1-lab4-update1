module fake_sdram(input logic clk, input logic rst_n,
                output logic waitrequest,
                input logic [31:0] address,
                input logic read, output logic [31:0] readdata, output logic readdatavalid,
                input logic write, input logic [31:0] writedata);

        sdram sd(address, clk, writedata, write ? write : (read) ? 1'b0 : 1'b0, readdata);

        assign readdatavalid = read;
        assign waitrequest = 1'b0;

endmodule: fake_sdram
