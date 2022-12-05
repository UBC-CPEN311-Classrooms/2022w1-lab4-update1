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

    // your code here
	//1. GET the weight matrix byte address, input activations vector byte address, and input activations vector length
	//2. GET the weight value at weight address
	//3. GET the input value at input activation address
	//4. MULTIPLY the weight value and input value with Q16.16
	//5. CALCULATE the total sum
	//6. REPEAT 2. to 5. until i reaches vector_length
	//7. FINISHED once the last vector-vector is calculated and summed
	//should it be ready to take another order?
	//only doing vector-vector dot product
	
	enum {RESET, GET_VALUES, WAIT, FIND_WEIGHT_VALUE, FOUND_WEIGHT_VALUE, FOUND_VECTOR_VALUE, CALCULATE, CALCULATESUM, DONE} state;
	
	logic [31:0] weight_address, vector_address, vector_length;//in Q16.16 fixed point
	logic signed [31:0] weight_value, vector_value;//will hold the values from weight address and vector address
	logic signed [63:0] calculated_value;
	logic signed [31:0] sum;//sum of dot product

	assign slave_readdata = (slave_read && slave_address == 32'd0 && !slave_waitrequest) ? sum : slave_readdata;
	
	always @(posedge clk) begin
		if(!rst_n) begin
			state <= RESET;
		end
		else begin
			case(state) 
				RESET: begin
							slave_waitrequest <= 1'b0;//no longer waiting
							state <= GET_VALUES;
							sum <= 32'b0;
							weight_address <= 32'd0;
							vector_address <= 32'd0;
							vector_length <= 32'd0;

							master_read <= 1'b0;
							master2_read <= 1'b0;
							master_write <= 1'b0;
							master2_write <= 1'b0;

							calculated_value <= 64'b0;

							//added
							weight_value <= 32'b0;
							vector_value <= 32'b0;

							master_address <= 32'b0;
							master2_address <= 32'b0;
							
					   end
				GET_VALUES: begin
								if(slave_write == 1'b1)begin			
									if(slave_address === 4'd2) //not sure what word_offset exatly means
										weight_address <= slave_writedata;
									else if(slave_address === 4'd3) //change these to real value
										vector_address <= slave_writedata;
									else if(slave_address === 4'd5)
										vector_length <= slave_writedata;
									else if(slave_address === 4'd0) begin//start accelerator, also change word_offset
										slave_waitrequest <= 1'b1;
										state <= WAIT;
									end
								end	
							end
				WAIT: state <= (vector_length > 0) ? FIND_WEIGHT_VALUE : DONE;//added
				FIND_WEIGHT_VALUE: begin
										master_address <= weight_address;//find the data at weight_address
										master_read <= 1'b1;
										state <= FOUND_WEIGHT_VALUE;//doesn't need WAIT state skip???
									end
				FOUND_WEIGHT_VALUE: if(master_readdatavalid && !master_waitrequest) begin
										weight_value <= master_readdata;
										master_read <= 1'b0;
                                        master2_address <= vector_address;
                                        master2_read <= 1'b1;
										state <= FOUND_VECTOR_VALUE;
									end
				FOUND_VECTOR_VALUE: begin
								if(master2_readdatavalid && !master2_waitrequest) begin
									vector_value <= master2_readdata;
									state <= CALCULATE;
									master2_read <= 1'b0;
								end
							end
				CALCULATE: begin
							calculated_value <= (weight_value * vector_value);//in signed Q16.16
							state <= CALCULATESUM;//should calculation be done in 64 bits
						   end
				CALCULATESUM: begin
								sum <= sum + calculated_value[47:16];//multiplying two 32 bits result in 64 bit
								if(vector_length !== 32'b1) begin
									weight_address <= weight_address + 32'd4;
									vector_address <= vector_address + 32'd4;
									vector_length <= vector_length - 32'b1;
									state <= FIND_WEIGHT_VALUE;
								end
								else begin
									state <= DONE;
									slave_waitrequest <= 1'b0;
								end
						   end
				DONE: begin
						if(slave_read && slave_address == 32'd0) begin
							state <= RESET;//ready to receive addresses and length again or not needed?
						end
					  end
			endcase
		end
	end

endmodule: dotopt
