module CLock_divider(
					input CLK_50MHZ,
					output reg CLK_OUT
						  );
			parameter n = 50000;	
			reg [31:0] count;
			always @(posedge CLK_50MHZ)
			begin
				count = count + 1;
				if (count == n)
				begin
					CLK_OUT = 1;
					count = 0;
				end
				else
					CLK_OUT = 0;
			end					  		
endmodule
