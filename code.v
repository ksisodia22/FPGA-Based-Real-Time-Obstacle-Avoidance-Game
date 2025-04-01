module mainFinal1(L,R, mainEn, secEn, clk, DAC_clk, VGA_R, VGA_G, VGA_B,  VGA_hSync, VGA_vSync, blank_n , sync_n );

output sync_n;
input mainEn,secEn;

reg [0:20]TotalAr;
wire [0:2]outOb;
reg [0:17]tempArray;


input clk, L, R;
wire [2:0]out;
output [7:0]VGA_R, VGA_G, VGA_B;
output VGA_hSync,VGA_vSync,blank_n;
output DAC_clk;
reg gState;

integer int;
parameter case0 = 3'b000;


	clk_reduce reduce1(clk, VGA_clk); //Reduces 50MHz clock to 25MHz  //*
		
	random rand1(secEn, clk, outOb); //*
	// kbInput kbIn(KB_clk, data, direction, reset); //* 
	position posnupdate( clk,L,L_state,  L_down, R, R_state, R_down, out);  // what are these
	updateClk UPDATE(clk, update);
	assign DAC_clk = VGA_clk;
	
	
	
	
	always @(clk)
	begin
		TotalAr[18] = out[0];
		TotalAr[19] = out[1];
		TotalAr[20] = out[2];
	end
	
	always @(posedge update)
	begin
	
	
	if (TotalAr[0:2] == 3'bxxx)
		TotalAr[0:2] = 3'b000;
	if (TotalAr[0:2] == 3'bzzz)
		TotalAr[0:2] = 3'b000;
// heartbeat == 1 is implied
if (TotalAr[0:2] == case0)
		begin 
	
	// implies each obstacle is seperated by an empty horizontal line between obstacles	
			tempArray[3:17] <= TotalAr[0:14];      // shift down all 5 rows
			tempArray[0:2] = outOb;               // insert new obstacle at top
			TotalAr[0:17] = tempArray[0:17];       // update TotalAr	
			 
		end 
else // if (ObsAr[0:2] != 3'b000); ----> set the top to 000 and push rest of array
	begin 
		tempArray[3:17] <= TotalAr[0:14];        // shift down as usual
		tempArray[0:2] = 3'b000;                 // but insert a blank row instead
		TotalAr[0:17] = tempArray[0:17];   // assign individually???
	end
end

reg[0:2]AA;
parameter[0:1] A=0,B=1,C=2;
always @(negedge VGA_clk) 
	case (AA)
	A: if(~mainEn)
		begin
		gState=1;
		AA=B;
		end
	B: if(((TotalAr[15] == TotalAr[18])|(TotalAr[16] == TotalAr[19])|(TotalAr[17] == TotalAr[20])))
		begin
		gState=0;
		AA=A;
		end
		
	
	endcase

		//always @(posedge VGA_clk) 
		//begin
		//if (gState ==1)
		//if (TotalAr[15:17] == TotalAr[18:20])
		//gState = 0;
		//end
	
	
	

vgatester vgatester1(gState, clk, VGA_hSync, VGA_vSync, VGA_R, VGA_G, VGA_B, blank_n, sync_n, TotalAr);
	

	
	
	
endmodule


///////////////////////////

module random(start,clk,outOb);
input start,clk; output reg [2:0]outOb;

always @ (posedge clk)

if (start) 

outOb <= 3'b000; 

else if 
(outOb < 6) outOb <= outOb + 1; 

else 
outOb = 3'b000;

endmodule



/////////

module clk_reduce(master_clk, VGA_clk);

	input master_clk; //50MHz clock
	output reg VGA_clk; //25MHz clock
	reg q;

	always@(posedge master_clk)
	begin
		q <= ~q; 
		VGA_clk <= q;
	end
endmodule

/////////////////////////////

//TAKEN FROM BRANDON HILL//

module vgatester(gState, clkin, vga_h_sync, vga_v_sync, vga_R, vga_G, vga_B, videoblank, videosync, Obs);
	input clkin, gState;
	input  [0:20]Obs;
	output videoblank, videosync;
	output vga_h_sync, vga_v_sync;
	output reg [7:0] vga_R, vga_G, vga_B;

	reg write;
	reg [9:0] CounterX;
	reg [8:0] CounterY;
	reg vga_HS, vga_VS;
	reg clk;
	reg clkdel;
	reg [2:0] col;
	
	wire CounterXmaxed = (CounterX==799);

		  


	always @(posedge clkin)
		if(clk)
			begin
				clk = 0;
			end
		else
			begin
				clk = 1;
			end

	
	assign videoblank = 1;
	assign videosync = 1;

	always @(posedge clk)
		if(CounterXmaxed)
			CounterX <= 0;
		else
			CounterX <= CounterX + 1;

	always @(posedge clk)
		if(CounterXmaxed)
			  CounterY <= CounterY + 1;

	
	always @(posedge clk)
		begin
			vga_HS <= (CounterX<=96);   // active for 16 clocks
			vga_VS <= (CounterY==0) | (CounterY==1);   // active for 800 clocks
		end 

	assign vga_h_sync = ~vga_HS;
	assign vga_v_sync = ~vga_VS;


	always @(posedge clk)
		begin
			if((CounterX>144) & (CounterX<384) & (CounterY>40) & (CounterY<515))
				if (~gState)
					col = 3'b100;
				else
				begin
					if (CounterX>=144 && CounterX<=223 && CounterY>=35 && CounterY<=103)
						begin
							write = Obs[0];
							col = 3'b111;
						end
					else if (CounterX>=223 && CounterX<=302 && CounterY>=35 && CounterY<=103)
						begin
							write = Obs[1];
							col = 3'b111;
						end
					else if (CounterX>=302 && CounterX<=380 && CounterY>=35 && CounterY<=103)
						begin
							write = Obs[2];
							col = 3'b111;
						end
					else if (CounterX>=144 && CounterX<= 223 && CounterY>=103 && CounterY<=171)
						begin
							write = Obs[3];
							col = 3'b111;
						end
					else if (CounterX>=223 && CounterX<= 302 && CounterY>=103 && CounterY<=171)
						begin
							write = Obs[4];
							col = 3'b111;
						end
					else if (CounterX>=302 && CounterX<= 380 && CounterY>=103 && CounterY<=171)
						begin
							write = Obs[5];
							col = 3'b111;
						end
					else if (CounterX>=144 && CounterX<= 223 && CounterY>=171 && CounterY<=239)
						begin
							write = Obs[6];
							col = 3'b111;
						end
					else if (CounterX>=223 && CounterX<= 302 && CounterY>=171 && CounterY<=239)
						begin
							write = Obs[7];
							col = 3'b111;
						end
					else if (CounterX>=302 && CounterX<= 380 && CounterY>=171 && CounterY<=239)
						begin
							write = Obs[8];
							col = 3'b111;
						end
					else if (CounterX>=144 && CounterX<= 223 && CounterY>=239 && CounterY<=307)
						begin
							write = Obs[9];
							col = 3'b111;
						end
					else if (CounterX>=223 && CounterX<= 302 && CounterY>=239 && CounterY<=307)
						begin
							write = Obs[10];
							col = 3'b111;
						end
					else if (CounterX>=302 && CounterX<= 380 && CounterY>=239 && CounterY<=307)
						begin
							write = Obs[11];
							col = 3'b111;
						end
					else if (CounterX>=144 && CounterX<= 223 && CounterY>=307 && CounterY<=375)
						begin
							write = Obs[12];
							col = 3'b111;
						end
					else if (CounterX>=223 && CounterX<= 302 && CounterY>=307 && CounterY<=375)
						begin
							write = Obs[13];
							col = 3'b111;
						end
					else if (CounterX>=302 && CounterX<= 380 && CounterY>=307 && CounterY<=375)
						begin
							write = Obs[14];
							col = 3'b111;
						end
					else if (CounterX>=144 && CounterX<= 223 && CounterY>=375 && CounterY<=443)
						begin
							write = Obs[15];
							col = 3'b111;
						end
					else if (CounterX>=223 && CounterX<= 302 && CounterY>=375 && CounterY<=443)
						begin
							write = Obs[16];
							col = 3'b111;
						end
					else if (CounterX>=302 && CounterX<= 380 && CounterY>=375 && CounterY<=443)
						begin
							write = Obs[17];
							col = 3'b111;
						end
					else if (CounterX>=144 && CounterX<= 223 && CounterY>=443 && CounterY<=515)
						begin
						write = Obs[18];
						col = 3'b010;
						end
					else if (CounterX>=223 && CounterX<= 302 && CounterY>=443 && CounterY<=515)
						begin
						write = Obs[19];
						col = 3'b010;
						end
					else if (CounterX>=302 && CounterX<= 380 && CounterY>=443 && CounterY<=515)
						begin
						write = Obs[20];
						col = 3'b010;
						end
					else
						write = 0;
				end
			else
				begin
				write = 0;
				end
				
			vga_R [7:0] = {8{(col[0] & write & (CounterX>144) & (CounterX<784) & (CounterY>35) & (CounterY<515))}};
			vga_G [7:0] = {8{(col[1] & write & (CounterX>144) & (CounterX<784) & (CounterY>35) & (CounterY<515))}};
			vga_B [7:0] = {8{(col[2] & write & (CounterX>144) & (CounterX<784) & (CounterY>35) & (CounterY<515))}}; 

		end
endmodule

	///////////////////////////
	
module updateClk(master_clk, update);
	input master_clk;
	output reg update;
	reg [22:0]count;	

	always@(posedge master_clk)
	begin
		count <= count + 1;
		if(count == 7897897)
		begin
			update <= ~update;
			count <= 0;
		end	
	end
endmodule

/////////////////////////////

//http://www.fpga4fun.com/Debouncer2.html for debouncer//


module position(input clk, input L, output reg L_state, output L_down, input R, output reg R_state, output R_down, output reg [2:0]out);

reg L_sync_0;  always @(posedge clk) L_sync_0 <= ~L;  // invert PB to make PB_sync_0 active high
reg L_sync_1;  always @(posedge clk) L_sync_1 <= L_sync_0;

reg R_sync_0;  always @(posedge clk) R_sync_0 <= ~R;  // invert PB to make PB_sync_0 active high
reg R_sync_1;  always @(posedge clk) R_sync_1 <= R_sync_0;


reg [15:0] L_cnt;

wire L_idle = (L_state==L_sync_1);
wire L_cnt_max = &L_cnt;	// true when all bits of PB_cnt are 1's

reg [15:0] R_cnt;

wire R_idle = (R_state==R_sync_1);
wire R_cnt_max = &R_cnt;


always @(posedge clk)
if(L_idle)
    L_cnt <= 0;  // nothing's going on
else
begin
    L_cnt <= L_cnt + 16'd1;  // something's going on, increment the counter
    if(L_cnt_max) L_state <= ~L_state;  // if the counter is maxed out, PB changed!
end

always @(posedge clk)
if(R_idle)
    R_cnt <= 0;  // nothing's going on
else
begin
    R_cnt <=R_cnt + 16'd1;  // something's going on, increment the counter
    if(R_cnt_max) R_state <= ~R_state;  // if the counter is maxed out, PB changed!
end

assign L_down = ~L_idle & L_cnt_max & ~L_state;
assign R_down = ~R_idle & R_cnt_max & ~R_state;




reg [0:3] Y1;
parameter [3:0] A=3'b001, B=3'b010, C=3'b100, D=3'b000;


always @ (posedge clk)
begin
	case(Y1)	
		A:
			if(L_down)
			begin
				out=B;
				Y1=B;
			end
	
	
		B:	begin
				if (R_down)
			begin
				out=A;
				Y1=A;
			end
		if(L_down)
			begin
				out=C;
				Y1=C;
			end
		
			
			end
							
		C:
				if (R_down)
			begin
				out=B;
				Y1=B;
			end
		D: begin
				Y1=B;
				out=B;
			end
			endcase
end
endmodule 

