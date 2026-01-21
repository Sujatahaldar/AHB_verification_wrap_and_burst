module amab_ahb_simple(HCLK,HRDATA,HADDR,HRESP,HWDATA,HREADY,HRESET,HTRANS,HBURST,HSIZE,HWRITE);
  
  integer beat_count=0;
//----------------------------I/O DECLARATIONS-------------------------------------------------//
  input HCLK;
  input HRESET;
  input HREADY;
  input [31:0] HRDATA;
  input [1:0]HRESP; 
  output reg [31:0] HADDR;
  output reg [31:0] HWDATA;
  output reg [1:0] HTRANS;
  output reg [2:0] HBURST;
  output reg [2:0] HSIZE;
  output reg HWRITE;
  reg [1:0] hresp_temp = 2'b11;
//----------------------------STATE DEFINATION AND PIPELINE LATCH------------------------------//
  reg [5:0] state,next;
  reg [31:0] HADDR_HWDATA_A;
  reg [31:0] HADDR_HWDATA_B;
//----------------------------HBURST[2:0] TYPES-----------------------------------------------//
  parameter hburst_single=3'b000; 		//single transfer
  parameter hburst_incr=3'b001; 			//incrmental busrt of unspecified length
  parameter hburst_wrap4=3'b010;			//4-beat wrapping burst
  parameter hburst_incr4=3'b011;			//4-beat incremental busrt
  parameter hburst_wrap8=3'b100;			//8-beat wrapping burst
  parameter hburst_incr8=3'b101;			//8-beat incremental burst
  parameter hburst_wrap16=3'b110;			//16-beat wrapping burst
  parameter hburst_incr16=3'b111;			//16-beat incremental burst
//----------------------------HTRANS[1:0] TYPES-----------------------------------------------//
  parameter trans_idle=5'b00000;			//master granted permission but does not transfer
  parameter trans_busy=5'b00001;			//busy in transaction
  parameter trans_nonseq=5'b00010;		//single transfer
  parameter trans_seq=5'b00011;			//burst mode
//----------------------------HRESP[1:0] TYPES------------------------------------------------//
  parameter resp_okay=2'b00;			//slave response as OKAY
  parameter resp_error=2'b01;			//slave response as ERROR
  parameter resp_retry_split=2'b10;		//slave response as SPLIT  
 
  assign HRESP = hresp_temp;
  
//----------------------------STATE TRANSITIONS----------------------------------------------//
  always @ (posedge HCLK)
	 if (!HRESET) 
		  state <= trans_idle; 
	
	 else 
		  state <= next;
//----------------------------HTRANS TYPE BEHAVIOUR------------------------------------------//

  always @ (state)
    begin
	     case (state)
		  
//-----------------------------------IDLE STATE-----------------------------------------------//
  trans_idle: begin
		
			HTRANS = trans_idle; 
			HADDR_HWDATA_A = HADDR;
			HWRITE = 1'b0;
			HSIZE = 3'b010;
			HADDR_HWDATA_B = HWDATA ;
			next = trans_nonseq;
			hresp_temp = resp_okay;	
		
	end //trans_idle
	
//-----------------------------------NONSEQ STATE---------------------------------------------//

		trans_nonseq: begin
			beat_count = 0;
			HTRANS = trans_nonseq;
			HWRITE =1'b1;
			//HWRITE = 1'b0;									//for read(0)/write(1) operation
			HSIZE = 3'b010;	         //32-bits combination for HSIZE, i.e. we will use Single transfer for verification
			   HBURST = hburst_single;								//Single transfer
			   //HBURST = hburst_incr;								//INCREMENTAL transfer of unspecified length
			   //HBURST = hburst_wrap4;								//WRAP 4
			   //HBURST = hburst_incr4;								//INCREMENTAL 4
			   //HBURST = hburst_wrap8;								//WRAP 8
			   //HBURST = hburst_incr8;								//INCREMENTAL 8
			   //HBURST = hburst_wrap16;								//WRAP 16
			   //HBURST = hburst_incr16;								//INCREMENTAL 16
			HADDR_HWDATA_A = 32'h00_00_00_34;							//FF FF = 00 38 (0x38) (BYTES)
								//[31:0][23:16]_[15:8][7:0] = [0][0]_[3][8] (BYTES) 			
			HADDR_HWDATA_B = 32'h11_11_11_34;
			HADDR = HADDR_HWDATA_A;
			//next = trans_busy;
			next = trans_seq;									//condition to by-pass busy state	
		
		end //trans_nonseq	
		
//-----------------------------------SEQ STATE-----------------------------------------------//

		trans_seq: begin
			
			HTRANS = trans_seq;
			
//------------------------------------SINGLE && READY 1-------------------------------------//

			if (HBURST==hburst_single && HREADY==1'b1) begin
				HADDR_HWDATA_A = HADDR;
				HADDR_HWDATA_B=HWDATA;
				//state = 5'bxxxxx;
				next = trans_idle;
			end // if (HBURST==hburst_single && HREADY==1'b1)

//------------------------------------SINGLE && READY 0-------------------------------------//

			if (HBURST==hburst_single && HREADY==1'b0) begin
				HADDR_HWDATA_A = HADDR_HWDATA_A;
				HADDR_HWDATA_B = HADDR_HWDATA_B;
				HWDATA = HADDR_HWDATA_B;
				//state = 5'bxxxxx;
				HADDR = HADDR_HWDATA_A;
				next = trans_seq;
			end // if (HBURST==hburst_single && HREADY==1'b1)

//------------------------------------INCR && READY 1--------------------------------------//
			
			if (HBURST==hburst_incr && HREADY==1'b1) begin
				HADDR = HADDR_HWDATA_A;
				HADDR_HWDATA_A = HADDR_HWDATA_A+4;
				HADDR = HADDR_HWDATA_A;							//condition if busy is not a valid state
				HWDATA = HADDR_HWDATA_B;
				HADDR_HWDATA_B = HADDR_HWDATA_B+4;
				//state = 5'bxxxxx;
				next = trans_seq;

			end // if (HBURST==hburst_incr && HREADY==1'b0)
		
//------------------------------------INCR && READY 0--------------------------------------//

			if (HBURST==hburst_incr && HREADY==1'b0) begin
				HADDR_HWDATA_A = HADDR_HWDATA_A;
				HADDR = HADDR_HWDATA_A;
 				//state = 5'bxxxxx;
				next = trans_seq;

			end // if (HBURST==hburst_incr && HREADY==1'b0)		

//------------------------------------INCR4 && READY 1-------------------------------------//	

			if (HBURST==hburst_incr4 && HREADY==1'b1) begin
				if (beat_count != 2) begin	
				HADDR = HADDR_HWDATA_A;
				HADDR_HWDATA_A = HADDR_HWDATA_A+4;
				HADDR = HADDR_HWDATA_A;							//condition if busy is not a valid state
				HWDATA = HADDR_HWDATA_B;
				HADDR_HWDATA_B = HADDR_HWDATA_B+4;
				//state = 5'bxxxxx;
				next = trans_seq;
				beat_count = beat_count +1;
				end // if (beat_count != 2)

				else begin
				beat_count = 0;
				HADDR = HADDR_HWDATA_A;
				HADDR_HWDATA_A = HADDR_HWDATA_A+4;
				HADDR = HADDR_HWDATA_A;
				HWDATA = HADDR_HWDATA_B;
				HADDR_HWDATA_B = HADDR_HWDATA_B+4;
				//state = 5'bxxxxx;
				next = trans_nonseq;
				end // else (beat_count != 2)
  			
			end //if (HBURST==hburst_incr4 && HREADY==1'b1)

//-----------------------------------INCR4 && READY 0--------------------------------------//

			else if (HBURST==hburst_incr4 && HREADY==1'b0) begin
				if (beat_count != 2) begin
				HADDR_HWDATA_A = HADDR_HWDATA_A;
				
				if (HADDR_HWDATA_A == HADDR_HWDATA_A) begin
					HADDR = HADDR_HWDATA_A;
 					//state = 5'bxxxxx;
					next = trans_seq;
					beat_count = beat_count +1;
				end // if (HADDR_HWDATA_A == HADDR_HWDATA_A)
				
				else begin
					HADDR_HWDATA_B = HADDR_HWDATA_B;
					HWDATA = HADDR_HWDATA_B;
					//state = 5'bxxxxx;
					HADDR = HADDR_HWDATA_A;
					next = trans_seq;
					beat_count = beat_count +1;
				end //else
				end // if (beat_count != 2)

				else begin
					HADDR_HWDATA_B = HADDR_HWDATA_B;
					HWDATA = HADDR_HWDATA_B;
					//state = 5'bxxxxx;
					HADDR = HADDR_HWDATA_A;
					next = trans_seq;
					beat_count = 0;

				end // else (beat_count != 2) 
			end // else if (HBURST==hburst_incr4 && HREADY==1'b0)			
			
//------------------------------------INCR8 && READY 1-------------------------------------//
			
			if (HBURST==hburst_incr8 && HREADY==1'b1) begin
				if (beat_count != 6) begin	
				HADDR = HADDR_HWDATA_A;
				HADDR_HWDATA_A = HADDR_HWDATA_A+4;
				HADDR = HADDR_HWDATA_A;							//condition if busy is not a valid state
				HWDATA = HADDR_HWDATA_B;
				HADDR_HWDATA_B = HADDR_HWDATA_B+4;
				//state = 5'bxxxxx;
				next = trans_seq;
				beat_count = beat_count +1;
				end // if (beat_count != 6)

				else begin
				beat_count = 0;
				HADDR = HADDR_HWDATA_A;
				HADDR_HWDATA_A = HADDR_HWDATA_A+4;
				HADDR = HADDR_HWDATA_A;
				HWDATA = HADDR_HWDATA_B;
				HADDR_HWDATA_B = HADDR_HWDATA_B+4;
				//state = 5'bxxxxx;
				next = trans_nonseq;
				end // else (beat_count != 6)
  			
			end //if (HBURST==hburst_incr8 && HREADY==1'b1)

//-----------------------------------INCR8 && READY 0--------------------------------------//

			else if (HBURST==hburst_incr8 && HREADY==1'b0) begin
				if (beat_count != 6) begin
				HADDR_HWDATA_A = HADDR_HWDATA_A;
				
				if (HADDR_HWDATA_A == HADDR_HWDATA_A) begin
					HADDR = HADDR_HWDATA_A;
 					//state = 5'bxxxxx;
					next = trans_seq;
					beat_count = beat_count +1;
				end // if (HADDR_HWDATA_A == HADDR_HWDATA_A)
				
				else begin
					HADDR_HWDATA_B = HADDR_HWDATA_B;
					HWDATA = HADDR_HWDATA_B;
					//state = 5'bxxxxx;
					HADDR = HADDR_HWDATA_A;
					next = trans_seq;
					beat_count = beat_count +1;
				end //else
				end // if (beat_count != 6)

				else begin
					HADDR_HWDATA_B = HADDR_HWDATA_B;
					HWDATA = HADDR_HWDATA_B;
					//state = 5'bxxxxx;
					HADDR = HADDR_HWDATA_A;
					next = trans_seq;
					beat_count = 0;

				end // else (beat_count != 6) 
			end // else if (HBURST==hburst_incr8 && HREADY==1'b0)									
			
//-----------------------------------INCR16 && READY 1--------------------------------------//
	
			if (HBURST==hburst_incr16 && HREADY==1'b1) begin
				if (beat_count != 14) begin	
				HADDR = HADDR_HWDATA_A;
				HADDR_HWDATA_A = HADDR_HWDATA_A+4;
				HADDR = HADDR_HWDATA_A;							//condition if busy is not a valid state
				HWDATA = HADDR_HWDATA_B;
				HADDR_HWDATA_B = HADDR_HWDATA_B+4;
				//state = 5'bxxxxx;
				next = trans_seq;
				beat_count = beat_count +1;
				end // if (beat_count != 14)

				else begin
				beat_count = 0;
				HADDR = HADDR_HWDATA_A;
				HADDR_HWDATA_A = HADDR_HWDATA_A+4;
				HADDR = HADDR_HWDATA_A;
				HWDATA = HADDR_HWDATA_B;
				HADDR_HWDATA_B = HADDR_HWDATA_B+4;
				//state = 5'bxxxxx;
				next = trans_nonseq;
				end // else (beat_count != 14)
  			
			end //if (HBURST==hburst_incr16 && HREADY==1'b1)

//-----------------------------------INCR16 && READY 0--------------------------------------//

			else if (HBURST==hburst_incr16 && HREADY==1'b0) begin
				if (beat_count != 14) begin
				HADDR_HWDATA_A = HADDR_HWDATA_A;
				
				if (HADDR_HWDATA_A == HADDR_HWDATA_A) begin
					HADDR = HADDR_HWDATA_A;
 					//state = 5'bxxxxx;
					next = trans_seq;
					beat_count = beat_count +1;
				end // if (HADDR_HWDATA_A == HADDR_HWDATA_A)
				
				else begin
					HADDR_HWDATA_B = HADDR_HWDATA_B;
					HWDATA = HADDR_HWDATA_B;
					//state = 5'bxxxxx;
					HADDR = HADDR_HWDATA_A;
					next = trans_seq;
					beat_count = beat_count +1;
				end //else
				end // if (beat_count != 14)

				else begin
					HADDR_HWDATA_B = HADDR_HWDATA_B;
					HWDATA = HADDR_HWDATA_B;
					//state = 5'bxxxxx;
					HADDR = HADDR_HWDATA_A;
					next = trans_seq;
					beat_count = 0;

				end // else (beat_count != 14) 
			end // else if (HBURST==hburst_incr16 && HREADY==1'b0)


			//------------------------------------WRAP4 && READY 1------------------------------------//

			else if (HBURST==hburst_wrap4 && HREADY==1'b1) begin
				if (HADDR_HWDATA_A [4] == HADDR_HWDATA_A [4]) begin 
					if (beat_count!=2) begin
						HADDR = HADDR_HWDATA_A;
						HADDR_HWDATA_A[7:0] =  HADDR_HWDATA_A[7:0] + 4; 			//1st BYTE
						HADDR_HWDATA_A[15:8] = HADDR_HWDATA_A[15:8];				//2nd BYTE
						HADDR_HWDATA_A[23:16] = HADDR_HWDATA_A[23:16];				//3rd BYTE
						HADDR_HWDATA_A[31:24] = HADDR_HWDATA_A[31:24];				//4th BYTE  
						
						HADDR_HWDATA_A  = {HADDR_HWDATA_A [31:24],HADDR_HWDATA_A [23:16],HADDR_HWDATA_A [15:8],HADDR_HWDATA_A[7:0]}; 		//WRAP4, the last byte will increment 4 times byte addressable
						HADDR = HADDR_HWDATA_A;							//condition if busy is not a valid state
						HWDATA = HADDR_HWDATA_B;
						HADDR_HWDATA_B = HADDR_HWDATA_B+4;
						//state = 5'bxxxxx;
						next = trans_seq;	
						beat_count = beat_count+1;
					end // if (beat_count!=2)	
					
				else begin
					beat_count = beat_count+1;
					HADDR_HWDATA_A =  HADDR_HWDATA_A;
					HADDR_HWDATA_A [31:4] = HADDR_HWDATA_A [31:4]; 
					HADDR_HWDATA_A[3:0] =  HADDR_HWDATA_A[3:0]+4;				//1st BYTE 4 BITS 
					next = trans_nonseq;
					HADDR = {HADDR_HWDATA_A [31:4],HADDR_HWDATA_A[3:0]};							//condition if busy is not a valid state
					HWDATA = HADDR_HWDATA_B;
					HADDR_HWDATA_B = HADDR_HWDATA_B+4;
				end // else (HADDR_HWDATA_A [4] == HADDR_HWDATA_A [4])			
			
				end // if (HADDR_HWDATA_A [4] == HADDR_HWDATA_A [4] )
			
			end // else if (HBURST=hburst_wrap4 && HREADY=1'b1)


//------------------------------------WRAP8 && READY 1------------------------------------//

			else if (HBURST==hburst_wrap8 && HREADY==1'b1) begin
				if (HADDR_HWDATA_A [5] == HADDR_HWDATA_A [5]) begin
					if (beat_count!=6) begin
						HADDR = HADDR_HWDATA_A;
						HADDR_HWDATA_A[31:5] = HADDR_HWDATA_A[31:5];
						HADDR_HWDATA_A[4:0] = HADDR_HWDATA_A[4:0]+4;
						HADDR_HWDATA_A  = {HADDR_HWDATA_A [31:5],HADDR_HWDATA_A[4:0]};
						HADDR = HADDR_HWDATA_A;							
						HWDATA = HADDR_HWDATA_B;
						HADDR_HWDATA_B = HADDR_HWDATA_B+8;
						//state = 5'bxxxxx;
						next = trans_seq;	
						beat_count = beat_count+1;
					end // if (beat_count!=6)

				else begin
					beat_count = beat_count +1;
					HADDR_HWDATA_A =  HADDR_HWDATA_A;
					HADDR_HWDATA_A[31:5] = HADDR_HWDATA_A[31:5];
					HADDR_HWDATA_A[4:0] = HADDR_HWDATA_A[4:0]+4;
					HADDR_HWDATA_A  = {HADDR_HWDATA_A [31:5],HADDR_HWDATA_A[4:0]};
					next = trans_nonseq;
					HADDR = HADDR_HWDATA_A;
					HWDATA = HADDR_HWDATA_B;
					HADDR_HWDATA_B = HADDR_HWDATA_B+8;
					end // else (HADDR_HWDATA_A [5] == HADDR_HWDATA_A [5])							
			
				end // if (HADDR_HWDATA_A [5] == HADDR_HWDATA_A [5]) 
			
			end // else if (HBURST==hburst_wrap8 && HREADY==1'b1)

//------------------------------------WRAP16 && READY 1------------------------------------//
	
			else if (HBURST==hburst_wrap16 && HREADY==1'b1) begin
				if (HADDR_HWDATA_A [6] == HADDR_HWDATA_A [6]) begin
					if (beat_count!=14) begin
						HADDR = HADDR_HWDATA_A;
						HADDR_HWDATA_A[31:6] = HADDR_HWDATA_A[31:6];
						HADDR_HWDATA_A[5:0] = HADDR_HWDATA_A[5:0]+4;
						HADDR_HWDATA_A  = {HADDR_HWDATA_A [31:6],HADDR_HWDATA_A[5:0]};
						HADDR = HADDR_HWDATA_A;							
						HWDATA = HADDR_HWDATA_B;
						HADDR_HWDATA_B = HADDR_HWDATA_B+8;
						//state = 5'bxxxxx;
						next = trans_seq;	
						beat_count = beat_count+1;
					end // if (beat_count!=14)

				else begin
					beat_count = beat_count +1;
					HADDR_HWDATA_A =  HADDR_HWDATA_A;
					HADDR_HWDATA_A[31:6] = HADDR_HWDATA_A[31:6];
					HADDR_HWDATA_A[5:0] = HADDR_HWDATA_A[5:0]+4;
					HADDR_HWDATA_A  = {HADDR_HWDATA_A [31:6],HADDR_HWDATA_A[5:0]};
					next = trans_nonseq;
					HADDR = HADDR_HWDATA_A;
					HWDATA = HADDR_HWDATA_B;
					HADDR_HWDATA_B = HADDR_HWDATA_B+8;
					end // else (HADDR_HWDATA_A [6] == HADDR_HWDATA_A [6])						
			
				end // if (HADDR_HWDATA_A [6] == HADDR_HWDATA_A [6]) 
			
			end // else if (HBURST==hburst_wrap16 && HREADY==1'b1)

		end // trans_seq
		
		default : next = trans_idle;
	
	endcase

end
endmodule
