module tb_top;
  logic HCLK,HRESET;
  intf vif1(HCLK,HRESET);
  AHB_tb tb();
  amab_ahb_simple a1(vif1.HCLK,vif1.HRDATA,vif1.HADDR,vif1.HRESP,vif1.HWDATA,vif1.HREADY,vif1.HRESET,vif1.HTRANS,vif1.HBURST,vif1.HSIZE,vif1.HWRITE);
  initial
  HCLK =0;
  always
  #5
  HCLK = ~HCLK;
  initial
  begin
    HRESET = 1;
    #20
    HRESET =0;
  end
  initial
  begin
    AHB_cfg:: vif = vif1;
  end
endmodule