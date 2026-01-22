class AHB_tx;
  bit HCLK;
  bit HRESET;
  rand logic HREADY;
  logic [31:0] HRDATA;
  rand logic [1:0]HRESP; 
  rand logic [31:0] HADDR;
  rand logic [31:0] HWDATA;
  logic [1:0] HTRANS;
  rand logic [2:0] HBURST;
  rand logic [2:0] HSIZE;
  rand logic HWRITE;
  
  //define constraints
  constraint c1{HADDR[31:0]>=32'd0;  HADDR[31:0] <32'd256;};
  constraint c2{HWDATA[31:0]>=32'd0; HWDATA[31:0] <32'd256;};
  constraint c3{HSIZE==3'b010;};
  constraint c4{HBURST == 3'b011;};
  
    function void print();
      $display("VALUES ARE HADDR=%0b HWDATA=%0b",HADDR,HWDATA);
    endfunction
    
    function AHB_tx copy();
    //to perform deepcopy
       copy = new();
       copy.HRDATA	= this.HRDATA;
       copy.HWRITE	= this.HWRITE;
       copy.HADDR	= this.HADDR;
       copy.HWDATA	= this.HWDATA; 
       copy.HREADY	= this.HREADY;
       copy.HRESP	= this.HRESP;
       copy.HTRANS	= this.HTRANS;
       copy.HBURST	= this.HBURST;
       copy.HSIZE	= this.HSIZE;
       return copy;
    endfunction
endclass

