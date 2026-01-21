class AHB_scb;
  mailbox #(AHB_tx) mon2scb;
  AHB_tx tx;
  function new();
    this.mon2scb = AHB_cfg::mon2scb;
  endfunction
  task run();
    forever 
    begin
      $display("-----------------Scoreboard-------------------------");
      tx = new;
      mon2scb.get(tx);
      $display("Address:%0h Data:%0h",tx.HADDR,tx.HWDATA);
		  if(tx.HRESP==0 && tx.HREADY==0) $display("Transfer pending");
		  else if(tx.HRESP==0 && tx.HREADY==1) $display("Transfer completed");
		  else if (tx.HRESP==1 && tx.HREADY==0) $display("Error response first cycle");
		  else if (tx.HRESP==1 && tx.HREADY==1) $display("Complete Error response");
    end
  endtask
endclass
  
      