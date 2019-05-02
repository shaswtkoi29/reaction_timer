
// ECEN2350 Project 2 - Spring 2019
// University of Colorado, Boulder
//
// Name: SHASWAT KOIRALA	
//


//////////////////////////
// Project2_top
//
// Do not remove inputs/ outputs that you don't use. However, any unused
// input/ outputs can remain unconnected in the pin planner.
//
module Project2_top(
						output	[7:0] HEX0,
						output	[7:0] HEX1,
						output	[7:0] HEX2,
						output	[7:0] HEX3,//used only to display in second can be replaced to display time in mili second
						output	[9:0] LEDR,
						input		[9:0] SW,
						input				KEY0,
						input				KEY1,
						input				CLK_50MHZ,
						input 		   CLK_10MHZ
						);
				 	wire clk_div;
					wire [1:0] state; 
					wire [3:0] c3, c2, c1, c0;
					wire [11:0] random_out;	
					wire [15:0] HighScore;
					// to calculate in second
					assign HEX0[7] = 1'b1;
					assign HEX1[7] = 1'b1;
					assign HEX2[7] = 1'b1;
					assign HEX3[7] = 1'b0;
//					
// 				use of HEX3 isn't important here; but for more precise value in second I used it; but can be replaced with just removing some line 
//					// to calculate in mili second
//					assign HEX0[7] = 1'b1;
//					assign HEX1[7] = 1'b1;
//					assign HEX2[7] = 1'b1;
//					wire countdown;
					wire [3:0] oneout,tenout,hunout,thout;
					CLock_divider		(CLK_50MHZ, clk_div);
					LFSR 		 			(CLK_50MHZ, random_out);
					count_down			(random_out,state,KEY0,clk_div,countdown);
					state_machine		(CLK_50MHZ,KEY0,KEY1,SW[0],countdown,state);
					
					BCD_counter			(clk_div, state, c0, c1, c2, c3);
								
					LED_test 			(state, LEDR[0], LEDR[1], LEDR[2], LEDR[3]);
					//stop timer display
//					BCD_decoder       (co, HEX0);
//					BCD_decoder       (c1, HEX1);
//					BCD_decoder       (c2, HEX2);
//			   	BCD_decoder       (c3, HEX3); 
					High_Score        (state,c0,c1,c2,c3,HighScore);					
					mux 				m1	(c0,HighScore[3:0], !SW[1],oneout);
					mux 				m2	(c1,HighScore[7:4], !SW[1],tenout);
					mux 				m3 (c2,HighScore[11:8],!SW[1],hunout);				
					mux 				m4 (c3,HighScore[15:12],!SW[1],thout);
			//  display
					wire[3:0] OUT_1,OUT_2,OUT_3,OUT_4;
				   use_display 		(SW[1],C0,c1,c2,c3,oneout,tenout,hunout,thout,OUT_1,OUT_2,OUT_3,OUT_4);
					BCD_decoder       (OUT_1, HEX0);
					BCD_decoder       (OUT_2, HEX1);
					BCD_decoder       (OUT_3, HEX2);
			   	BCD_decoder       (OUT_4, HEX3); 
					
							 
endmodule	
module use_display
					(
					input sw,
					input [3:0] c0,c1,c2,c3,oneout,tenout,hunout,thout,
					output [3:0] OUT_1,OUT_2,OUT_3,OUT_4
					);
					reg [3:0] OUT1,OUT2,OUT3,OUT4;
					always @(*) begin
					if(sw) begin
							OUT1=oneout;
							OUT2=tenout;
							OUT3=hunout;
							OUT4=thout; // can be replaced if want to display in mili second.
							end
					 else
						begin
								OUT1=c0;
								OUT2=c1;
								OUT3=c2;
								OUT4=c3;
						end
				end
				assign OUT_1=OUT1;
				assign OUT_2=OUT2;
				assign OUT_3=OUT3;
				assign OUT_4=OUT4;
				
				
endmodule
					

module state_machine(
					input clk,
					input start,
					input stop,
					input reset,
					input countdown_finish, 
					output reg [1:0] en
					);
	reg [1:0] state, state_next;
	parameter IDLE = 2'b00, countdown = 2'b01, reaction = 2'b10, display = 2'b11; 
	always @(state, start, stop, reset) begin
		case (state)
			IDLE:
				if (!start) begin					// starts counting down
					state_next = countdown;
				end
				else 
					begin
					state_next = IDLE;
					end
         countdown:
				if(!countdown_finish && !stop | !start)    // reset within delay by press of button
												begin
												state_next = IDLE; 
												end
            else if (countdown_finish && start) begin	// finish count down, start counting up
						//state_next = display;
						 state_next = reaction;
						end

				else 
					begin
					state_next = countdown;
					end
         reaction:
				if (!stop) begin					
					state_next = display;
				end
				else
					begin
					state_next = reaction;
					end
				
         display:
				if (reset) begin
					state_next = IDLE;
				end
				else
					begin
					state_next = display;
					end
		endcase
	end

	always @(posedge clk, posedge reset) begin
		if (reset)
			state  <= IDLE;	      		
		else
			state  <= state_next; 
	end
	
	always @(state) begin
		if (state == IDLE)
			en = IDLE;
		if (state == countdown)
			en = countdown;
		if (state == reaction)
			en = reaction;
		if (state == display)
			en = display;
	end
	

endmodule 

module count_down(
				input[11:0] num,
				input[1:0]  en,
				input start,
			   input	clk1k,
				output reg countdown_finish
				);
	reg [11:0] count;
	
	initial 
		begin
		count = 12'b111111111111;
		end
	
	always @(posedge clk1k) begin
		if (!start) 
			count <= num;			// start counting down
		else if (en == 2'b01 && start) begin
			if (count < 12'd1)  // countdown finished
				countdown_finish <= 1'b1;			// output high
			else begin
				count <= count - 1;
				countdown_finish <= 1'b0;		   // decrement count
			end
		end
	end
endmodule 

module LED_test(en, LED0, LED1, LED2, LED3);
	input [1:0] en;
	output reg LED0, LED1, LED2, LED3;
	
	always @(en) begin
		if (en == 2'b00) begin
			LED0 = 1;
			LED1 = 0;
			LED2 = 0;
			LED3 = 0;
		end
		else if (en == 2'b01) begin 
			LED0 = 0;
			LED1 = 1;
			LED2 = 0;
			LED3 = 0;
		end 
		else if (en == 2'b10) begin
			LED0 = 0;
			LED1 = 0;
			LED2 = 1;
			LED3 = 0;
		end 
		else if (en == 2'b11) begin
			LED0 = 0;
			LED1 = 0;
			LED2 = 0;
			LED3 = 1;
		end 
	end
endmodule

module High_Score(en, BCD0, BCD1, BCD2, BCD3, high_score);
	input [1:0] en; 		
	input [3:0] BCD0, BCD1, BCD2, BCD3;
	output reg [15:0] high_score;
	
	initial
		begin
		high_score = 16'b0;
		end
	
	always @(en) begin
		if (en == 2'b00 && {BCD3, BCD2, BCD1, BCD0} != 0) begin
			if (high_score > {BCD3, BCD2, BCD1, BCD0})
				high_score = {BCD3, BCD2, BCD1, BCD0};
			else 
				high_score = high_score;
		end
	end
	
endmodule  

module mux(
	input [3:0] a,
	input [3:0] b,
	input s,
	output reg [3:0] out
	);
	always@(a or b or s)
		case(s)
			1:out = a ;
			0:out = b ;
		endcase
endmodule
