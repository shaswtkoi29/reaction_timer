module LFSR(
	input CLK_50MHZ,
	output reg [11:0] random_num
				);	
	initial
		begin
		random_num = 12'b111111111111;
		end		
	always @(posedge CLK_50MHZ) begin
		if (random_num == 0) begin
			random_num <= 12'b111111111111;
		end
		else begin
			random_num <= {random_num[10], 
								random_num[9],
								random_num[8],
								random_num[7],
								random_num[6],
								random_num[5],
								random_num[4],
								random_num[3],
								random_num[2],
								random_num[1],
								random_num[0],
								random_num[8] ^ random_num[3]
								};
		end
	end
	
endmodule
