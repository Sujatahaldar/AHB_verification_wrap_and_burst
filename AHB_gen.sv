typedef class AHB_tx;
class AHB_gen;
  AHB_tx tx;
  mailbox #(AHB_tx)gen2drv;
  function new();
    this.gen2drv=AHB_cfg::gen2drv;
  endfunction
  task run();
    begin
      for(int i=0;i<50;i++)
        begin
          tx=new();
          $display("------------Generator %d---------------",i);
          assert(tx.randomize()) else $display("Randomization failed");
          tx.print();
          gen2drv.put(tx);
        end
    end
  endtask
endclass