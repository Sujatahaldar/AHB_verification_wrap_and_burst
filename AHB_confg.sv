class AHB_cfg;
  static mailbox #(AHB_tx) gen2drv = new();
  static mailbox #(AHB_tx) mon2scb = new();
  static mailbox #(AHB_tx) mon2cov = new();
  static virtual intf vif;
endclass