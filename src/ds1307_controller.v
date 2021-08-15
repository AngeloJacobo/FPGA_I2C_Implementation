`timescale 1ns / 1ps

module ds1307_controller(
	input clk,rst_n,
	inout sda,scl,
	input[1:0] key,
	output[7:0] seg_out,
	output[5:0] sel_out,
	output [3:0] led
    );
	 //FSM state declarations
	 localparam idle=0,
					a_w=1,
					b_w=2,
					c_w=3,
					d_w=4,
					e_w=5,
					f_w=6,
					g_w=7,
					h_w=8,
					i_w=9,
					j_w=10,
					
					a_r=11,
					b_r=12,
					c_r=13,
					d_r=14,
					e_r=15,
					f_r=16,
					g_r=17,
					h_r=18,
					i_r=19,
					j_r=20;
					
					
					
	 
	 (*KEEP="TRUE"*)reg[4:0] state_q,state_d;
	 reg[5:0] in0,in1,in2,in3,in4,in5;
	 reg start,stop;
	 reg[7:0] wr_data;
	 wire rd_tick;
	 wire[1:0] ack;
	 wire[7:0] rd_data;
	 wire key1_tick;
	 reg key1_q=0;
	 reg[3:0] led_q=0,led_d;
	 reg[3:0] sec1_q=0,sec1_d,sec0_q=0,sec0_d;
	 reg[3:0] min1_q=0,min1_d,min0_q=0,min0_d;
	 reg[3:0] hour1_q=0,hour1_d,hour0_q=0,hour0_d;
	 reg[3:0] date1_q=0,date1_d,date0_q=0,date0_d;
	 reg[3:0] month1_q=0,month1_d,month0_q=0,month0_d;
	 reg[3:0] year1_q=0,year1_d,year0_q=0,year0_d;
	 
	 //register operations
	 always @(posedge clk,negedge rst_n) begin
		if(!rst_n) begin
			state_q<=idle;
			led_q<=0;
			sec1_q<=0;
			sec0_q<=0;
			min1_q<=0;
			min0_q<=0;
			hour1_q<=0;
			hour0_q<=0;
			date1_q<=0;
			date0_q<=0;
			month1_q<=0;
			month0_q<=0;
			year1_q<=0;
			year0_q<=0;
			key1_q<=0;
		end
		else begin
			state_q<=state_d;
			led_q<=led_d;
			sec1_q<=sec1_d;
			sec0_q<=sec0_d;
			min1_q<=min1_d;
			min0_q<=min0_d;
			hour1_q<=hour1_d;
			hour0_q<=hour0_d;
			date1_q<=date1_d;
			date0_q<=date0_d;
			month1_q<=month1_d;
			month0_q<=month0_d;
			year1_q<=year1_d;
			year0_q<=year0_d;
			if(key1_tick) key1_q<=!key1_q;
			else key1_q<=key1_q;
		end
	 end
	 
	 //FSM next-state declarations
	 always @* begin
		state_d=state_q;
		start=0;
		stop=0;
		wr_data=0;
		led_d=led_q;
		sec1_d=sec1_q;
		sec0_d=sec0_q;
		min1_d=min1_q;
		min0_d=min0_q;
		hour1_d=hour1_q;
		hour0_d=hour0_q;
		date1_d=date1_q;
		date0_d=date0_q;
		month1_d=month1_q;
		month0_d=month0_q;
		year1_d=year1_q;
		year0_d=year0_q;
		
		case(state_q) 
			idle: if(!key[0]) state_d=a_w; //go to write sequence
					else state_d=a_r; //go to read sequence
					 
					 /////////write to ds1307/////////////
			a_w: begin
					led_d[0]=!led_q[0];
					start=1;
					wr_data=8'b1101_0000; //slave address
					if(ack==2'b11) begin
						state_d=b_w;
						start=0;
					end
				  end
			b_w: begin
					wr_data=8'b0000_0000; //first address locatio
					if(ack==2'b11) state_d=c_w;
				  end
			c_w: begin
					wr_data=8'b0000_0000; //byte1(seconds)
					if(ack==2'b11) state_d=d_w;
				  end
			d_w: begin
					wr_data=8'b0_100_0000; //byte2(minutes)
					if(ack==2'b11) state_d=e_w;
				  end
			e_w: begin
						led_d[1]=!led_q[1];
						wr_data=8'b0_1_0_1_0000; //byte3(hours)
						if(ack==2'b11) state_d=f_w;
				  end
			f_w: begin
						wr_data=8'b00000_011; //byte4(day)
						if(ack==2'b11) state_d=g_w;
					end
			g_w: begin
						led_d[2]=!led_q[2];
						wr_data=8'b00_10_1000; //byte5(date)
						if(ack==2'b11) state_d=h_w;
				  end
			h_w: begin
						wr_data=8'b000_0_0111; //byte6(month)
						if(ack==2'b11) state_d=i_w;
				  end
			i_w: begin
						wr_data=8'b0010_0001; //byte7(Year)
						if(ack==2'b11) state_d=j_w;
				  end
			j_w: begin
						led_d[3]=!led_q[3];
						wr_data=8'b0000_0000; //byte8(control)
						if(ack==2'b11) begin
							stop=1;
							state_d=idle;
						end
				  end
				  
				  
				  
					 /////////read from ds1307/////////////
			a_r: begin
					start=1;
					wr_data=8'b1101_0000; //slave address
					if(ack==2'b11) begin
						state_d=b_r;
						start=0;
					end
				  end
			b_r: begin
					wr_data=8'b0000_0000; //first address location
					if(ack==2'b11) begin
						start=1; //repeated start for read sequence
						state_d=c_r;
					end
				  end
			c_r: begin
					wr_data=8'b1101_0001; //slave address but with READ bit
					if(rd_tick) begin //byte 1(seconds)
						sec1_d=rd_data[6:4];
						sec0_d=rd_data[3:0];
						state_d=d_r;
					end
				  end
			d_r: if(rd_tick) begin //byte 2(minutes)
						min1_d=rd_data[6:4];
						min0_d=rd_data[3:0];
						state_d=e_r;
					end
			e_r: if(rd_tick) begin //byte 3(hours)
						hour1_d=rd_data[4];
						hour0_d=rd_data[3:0];
						state_d=f_r;
					end
			f_r: if(rd_tick) begin //byte 4(days)
						state_d=g_r;
					end
			g_r: if(rd_tick) begin //byte 5(date)
						date1_d=rd_data[5:4];
						date0_d=rd_data[3:0];
						state_d=h_r;
					end
			h_r: if(rd_tick) begin //byte 6(month)
						month1_d=rd_data[4];
						month0_d=rd_data[3:0];
						state_d=i_r;
					end
			i_r: if(rd_tick) begin //byte 7(years)
						year1_d=rd_data[7:4];
						year0_d=rd_data[3:0];
						state_d=idle;
						stop=1;
					end
	  default: state_d=idle;
		endcase
	 end
	 
	 assign  led=led_q;
	 
	 //logic for seven segments
	 always @* begin
		in0=0;
		in1=0;
		in2=0;
		in3=0;
		in4=0;
		in5=0;
		if(key1_q) begin //display time. Format: hh.mm.ss
			in5={2'b00,hour1_q};
			in4={2'b10,hour0_q};
			in3={2'b00,min1_q};
			in2={2'b10,min0_q};
			in1={2'b00,sec1_q};
			in0={2'b00,sec0_q};
		end
		else if(!key1_q) begin //display date. Format: mm.dd.yy
			in5={2'b00,month1_q};
			in4={2'b10,month0_q};
			in3={2'b00,date1_q};
			in2={2'b10,date0_q};
			in1={2'b00,year1_q};
			in0={2'b00,year0_q};
		end
	 end
	 
	 
	 //module instantiations
	 i2c_top #(.freq(100_000)) m0
	(
		.clk(clk),
		.rst_n(rst_n),
		.start(start),
		.stop(stop),
		.wr_data(wr_data),
		.rd_tick(rd_tick), //ticks when read data from servant is ready,data will be taken from rd_data
		.ack(ack), //ack[1] ticks at the ack bit[9th bit],ack[0] asserts when ack bit is ACK,else NACK
		.rd_data(rd_data), 
		.scl(scl),
		.sda(sda)
    );
	 LED_mux m1
	(
		.clk(clk),
		.rst(rst_n),
		.in0(in0),
		.in1(in1),
		.in2(in2),
		.in3(in3),
		.in4(in4),
		.in5(in5), //format: {dp,char[4:0]} , dp is active high
		.seg_out(seg_out),
		.sel_out(sel_out)
    );
	 debounce_explicit m2
	(
		.clk(clk),
		.rst_n(rst_n),
		.sw(key[1]),
		.db_level(),
		.db_tick(key1_tick)
    );


endmodule
