class wr_busfm;
  virtual intf vif;
  wr_transaction wr_tx;

  function new();
    vif = top.pif;
  endfunction

 task run();
  forever begin
    @(posedge vif.wr_clk_i);
    if (vif.rst_i == 1) begin   // sample rst_i synchronously with clock
      gen2bfm_wr.get(wr_tx);
      fork
        begin : DRIVE
          drive_tx(wr_tx);   // edge-aligned version, no leading @(posedge)
        end
        begin : RESET_WATCH
          wait(vif.rst_i == 0);
          vif.wr_en_i = 0;
        end
      join_any
      disable fork;
    end
  end
endtask  

  task drive_tx(wr_transaction wr_tx);
    @(posedge vif.wr_clk_i);
    vif.wr_en_i = wr_tx.wr_en_i;
    if (wr_tx.wr_en_i == 1)
      vif.wdata_i = wr_tx.wdata_i;
    @(posedge vif.wr_clk_i);
    common::wr_bfm_count++;
    vif.wr_en_i = 0;
  endtask
endclass
