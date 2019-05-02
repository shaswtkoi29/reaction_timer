module BCD_counter(
						input clk_1khz,
						input [1:0]Enable,
					   output reg[3:0]BCD0,
						output reg[3:0]BCD1,
					   output reg[3:0]BCD2,
					   output reg[3:0]BCD3
						);
	
	reg initiate;
	always @(posedge Enable)
	begin
		if (Enable == 2'b10)
			initiate = 1;
		else
			initiate = 0;
	end
	
	always @(posedge clk_1khz)
	begin 
		if (Enable== 2'b00 || Enable== 2'b01)
		begin
			BCD0 <= 0;
			BCD1 <= 0;
			BCD2 <= 0;
			BCD3 <= 0;
		end
		else if (initiate == 0)
		begin
			if (BCD0 == 4'b1001)
			begin
				BCD0 <= 0;
				if (BCD1 == 4'b1001)
				begin 
					BCD1 <= 0;
					if (BCD2 == 4'b1001)
					begin
						BCD2 <= 0;
						if (BCD3 == 4'b1001)
							BCD3 <= 0;
						else
							BCD3 = BCD3 + 1;
					end
					else
						BCD2 = BCD2 + 1;
				end
				else
					BCD1 = BCD1 + 1;
			end
			else
				BCD0 <= BCD0 + 1;
		end
	end
	
endmodule
