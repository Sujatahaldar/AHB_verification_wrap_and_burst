class AHB_driver;
  virtual intf vif;
  mailbox #(AHB_tx)gen2drv;
  AHB_tx tx;
  function new();
    this.gen2drv=AHB_cfg::gen2drv;
    this.vif=AHB_cfg::vif;
  endfunction
  task run();
    forever begin
      wait(!vif.HRESET)
     	  gen2drv.get(tx);
     	  @(posedge vif.HCLK)
        //vif.HREADY=1;
        //if(vif.HREADY)begin		
		     vif.HADDR	<= tx.HADDR;
		     vif.HWDATA	<= tx.HWDATA;
		     vif.HWRITE	<= tx.HWRITE;
		     vif.HSIZE	<= tx.HSIZE;
		     vif.HBURST 	<= tx.HBURST;
		     vif.HTRANS	<= tx.HTRANS;
		     vif.HREADY	<= tx.HREADY;
		     //$display("Address: %0h Data: %0h",vif.HADDR,vif.HWDATA);
		     $display("-----DRIVER------");
         tx.print();
		  end
	endtask 
	task reset();	
	  begin
		  $display("Bus System Reset\n");			
		  vif.HADDR	<= 0;
		  vif.HWDATA	<= 0;
		  vif.HWRITE	<= 0;
		  vif.HSIZE	<= 0;
		  vif.HBURST 	<= 0;
		  vif.HTRANS	<= 0;
		  vif.HREADY	<= 1;
	  end
  endtask 
        
endclass