program AHB_tb();
  AHB_env env;
  initial
  begin
    env=new();
    env.run();
  end
endprogram