module wordcopy(input logic clk, input logic rst_n,
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

    // your code here

    //Step 1: Access destination address and store in register slave_address == 4??
    //Step 2: Access source address, store in register and set the master address to equal this slave_address == 8?
    //Step 3: Access number of words, store in register and wait for slave_write to go high
    //Step 4: Make it so slave_waitrequest is high in order to complete current memory copy request
    //Step 5: Once slave_write goes high begin copy by reading from store address and waiting until master_waitrequest goes low till we move onto the next step
    //Step 6: Ensure that value retrieved is valid before moving on (ensures that there is no incorrect values being added to the memory copy)
    //Step 7: Set master_write to go high and then set master_writedata to be the retrieved store value at address and wait until master_waitrequest goes low before continuing
    //Step 8: Once master_waitrequest is low, the memory copy for one word has been completed. Repeat this cycle until the word count has been met. Increment the destination
    //        and source addresses by 4 in order to result in an incrememnt of 4 bytes (a word)
    //Step 9: Once the copy of a request is complete, deassert the slave_waitrequest and allow the cpu to read offset 0 in order to end the request

    enum{RESET, TRANSFER, SEND_READ, SEND_WRITE, NEXT_WORD, DONE} state;

    logic [31:0] store, destination, n_words, word_cnt;

    always@(posedge clk)
        if (!rst_n) begin
            destination <= 32'b0;
            store <= 32'b0;
            n_words <= 32'b0;
            word_cnt <= 32'b0;
        end else begin
        // Enable writing to each word separately
            if (slave_address === 4'd4) destination <= slave_writedata;
            if (slave_address === 4'd8) store <= slave_writedata;
            if (slave_address === 4'd12) n_words <= slave_writedata;
        end

    always @(posedge clk) begin

        if(!rst_n) begin
            state <= RESET;
        end
        else begin
            case(state)

                RESET:  begin 
                    state <= TRANSFER;
                    slave_waitrequest <= 1'b0;
                end
                TRANSFER:   if(!store && !destination && !n_words)
                                state <= TRANSFER;
                            else if(slave_write) begin
                                state <= SEND_READ;
                                master_read <= 1'b1;
                                slave_waitrequest <= 1'b1;
                            end
                SEND_READ: if(!master_waitrequest && master_readdatavalid) begin
                                state <= SEND_WRITE;
                                master_writedata <= master_readdata;
                                master_write <= 1'b1;
                                master_read <= 1'b0;                
                            end
                SEND_WRITE: if(!master_waitrequest) begin
                                state <= NEXT_WORD;
                                master_write <= 1'b0;
                            end
                NEXT_WORD:  if(word_cnt >= n_words)
                                state <= DONE;
                            else if(!master_waitrequest) begin
                                state <= SEND_READ;
                                master_read <= 1'b1;                
                                destination <= destination + 32'd4;
                                store <= store + 32'd4;
                            end
            endcase
        end
    end
endmodule: wordcopy