interface  intf(input logic HCLK, HRESET);
	
	logic   [31:0] HWDATA; 
 	logic   [31:0] HADDR;
	logic	[31:0] HRDATA;  
	logic   [2:0]  HSIZE;	  
	logic   [2:0]  HBURST;   
	logic   [1:0]  HTRANS;  
	logic          HWRITE;   
	logic [1:0]    HRESP; 
	logic	        HREADY;


clocking CB1 @(posedge HCLK);

	default input #1 output #1; //input and output skews
	input 		HADDR,HWDATA,HWRITE,HSIZE,HBURST,HTRANS;
	output 		HRESP,HREADY;

endclocking 


endinterface
