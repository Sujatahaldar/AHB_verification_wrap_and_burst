class AHB_cov;
  AHB_tx tx;
  mailbox #(AHB_tx) mon2cov;
  covergroup AHB_cg;
    AHB_HRESP :coverpoint tx.HRESP { bins HRESP[]={[0:3]};}
    AHB_HADDR :coverpoint tx.HADDR { bins HADDR[]={[0:255]};}
    AHB_HWDATA :coverpoint tx.HWDATA { bins HWDATA[]={[0:255]};}
    AHB_HBURST :coverpoint tx.HBURST { bins HBURST[]={[0:7]};}
    AHB_HWRITE :coverpoint tx.HWRITE;
    AHB_HREADY :coverpoint tx.HREADY;
  endgroup
  function new();
    this.mon2cov = AHB_cfg :: mon2cov;
    AHB_cg = new();
  endfunction
  task run();
     begin 
      mon2cov.get(tx);
      AHB_cg.sample();
      $display("------------------coverage-------------------");
    end
  endtask
endclass
