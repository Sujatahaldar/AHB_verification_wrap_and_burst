class AHB_env;
  AHB_gen gen;
  AHB_driver drv;
  AHB_mon mon;
  AHB_cov cov;
  AHB_scb scb;
  
  function new();
    gen=new();
    drv=new();
    mon=new();
    cov=new();
    scb=new();
  endfunction
  
  task run();
    begin 
      fork
      gen.run();
      drv.run();
      mon.run();
      scb.run();
      cov.run();
      join
    end
  endtask
endclass