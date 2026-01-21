class AHB_mon;
  AHB_tx tx;
  mailbox #(AHB_tx)mon2scb;
  mailbox #(AHB_tx)mon2cov;
  virtual intf vif;
  function new();
    this.mon2scb=AHB_cfg::mon2scb;
    this.mon2cov=AHB_cfg::mon2cov;
    this.vif=AHB_cfg::vif;
  endfunction
  task run();
    forever begin 
      wait(!vif.HRESET)
        tx=new();
         @(posedge vif.HCLK)
		      tx.HADDR	<= vif.HADDR;
		      tx.HWDATA	<= vif.HWDATA;
		      tx.HWRITE	<= vif.HWRITE;
		      tx.HSIZE	<= vif.HSIZE;
		      tx.HBURST 	<= vif.HBURST;
		      tx.HTRANS	<= vif.HTRANS;
		      tx.HREADY	<= vif.HREADY;
		      @(negedge vif.HCLK);
		       @(posedge vif.HCLK)
		       tx.HRDATA= vif.HRDATA;
		       mon2scb.put(tx);
		       mon2cov.put(tx);
		      $display("----------monitor--------");
		      tx.print();
    end
  endtask    		    
endclass