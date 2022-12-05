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

    enum{RESET, TRANSFER, SEND_READ, SEND_WRITE, NEXT_WORD, WAIT, FINISH, DONE} state;

    logic [31:0] store, destination, n_words;

    always @(posedge clk) begin

        if(!rst_n) begin
            state <= RESET;
        end
        else begin
            case(state)
                RESET:  begin 
                    state <= TRANSFER;
                    destination <= 32'b0;
                    store <= 32'b0;//source address
                    n_words <= 32'b0;
                    slave_waitrequest <= 1'b0;//no longer waiting, can take requests from CPU
                    master_read <= 1'b0;
                    master_write <= 1'b0;
                    slave_readdata <= 32'b0;
                end
                TRANSFER:   if(slave_write) begin//if store and destination and n_word is 0 do this loop// this should be OR instead of AND?//any non-zero value will make this condition false
                                state <= TRANSFER;
                                if (slave_address === 2'd1) //if slaveaddress = 4, put slave_writedata to destination, stay in TRANSFER, but since destination now has a value that is not 0 (probably), the above loop cannot happen again
                                    destination <= slave_writedata;
                                else if (slave_address === 2'd2) 
                                    store <= slave_writedata;
                                else if (slave_address === 2'd3) 
                                    n_words <= slave_writedata;
                                else if(slave_address === 2'd0) begin//slave_address == 0 and cpu tells wordcopy to write, what does slave_read do?
                                    state <= WAIT;
                                    master_read <= 1'b1;//ready to read from memory
                                    slave_waitrequest <= 1'b1;//slave asks CPU to wait, it cannot take any requests from CPU
							    	master_address <= store; //is this missing from here?
                                end//also does there have to be wait state when reading from Memory?? not sure
                            end
                WAIT:       state <= n_words > 0 ? SEND_READ : DONE;
                SEND_READ:  if(!master_waitrequest && master_readdatavalid) begin//master_waitrequest has to be 0 to make sure Memory is not occupied, the readdata has to be 1 to be valid
                                state <= SEND_WRITE;
                                master_writedata <= master_readdata;//the readdata from address store is put to master_writedata,
                                master_write <= 1'b1; //tell Memory to write
                                master_read <= 1'b0;           //no longer reading  
								master_address <= destination; //is this missing from here?
                            end
                SEND_WRITE: if(!master_waitrequest) begin//Memory is no longer requesting wait
                                state <= NEXT_WORD;
                                master_write <= 1'b0;// no longer writing
                            end
                NEXT_WORD:  if(n_words === 32'b1) begin
                                state <= DONE;//have to be able to take in multiple requests, Done state goes to Transfer?
                                slave_waitrequest <= 1'b0;//tell CPU that the function has finished, no longer has to wait
                            end
                            else begin//there are more words to copy
                                state <= WAIT;
                                master_read <= 1'b1;
                                destination <= destination + 32'd4;
                                n_words <= n_words - 1'b1;
                                store <= store + 32'd4;
								//since it is telling Memory to read it needs an address
								master_address <= store + 32'd4; 
                            end
                DONE: if(slave_read && slave_address === 32'b0) begin
                        state <= RESET;
                        slave_readdata <= 32'd100;
                        end
            endcase
        end
    end
endmodule: wordcopy