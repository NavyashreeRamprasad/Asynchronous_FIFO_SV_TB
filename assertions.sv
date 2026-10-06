module fifo_checks (
  // clocks and reset
  input wr_clk_i,
  input rd_clk_i,
  input rst_i,
  // port signals
  input wr_en_i,
  input rd_en_i,
  input full_o,
  input empty_o,
  input overflow_o,
  input underflow_o,
  input wdata_i,
  input rdata_o,
  // internal signals
  input [`PTR_WIDTH-1:0] wr_pntr,
  input [`PTR_WIDTH-1:0] rd_pntr,
  input wr_toggle,
  input rd_toggle,
  input [`PTR_WIDTH-1:0] rd_pntr_wr_clk,
  input rd_toggle_wr_clk,
  input [`PTR_WIDTH-1:0] wr_pntr_rd_clk,
  input wr_toggle_rd_clk
);

  // ---------------- FULL (write clock) ----------------
  // Pointers match and toggles differ -> full_o must be 1
property p1;
  @(posedge wr_clk_i) disable iff (!rst_i)
    ((wr_pntr == rd_pntr_wr_clk) && (wr_toggle != rd_toggle_wr_clk)) |-> full_o;
endproperty
  a_full: assert property (p1);

  // Write while full -> overflow_o on next cycle
property p2;
    @(posedge wr_clk_i) disable iff (!rst_i)
    (wr_en_i && full_o) |=> overflow_o
 endproperty 
  a_overflow: assert property (p2);

  // ---------------- EMPTY (read clock) ----------------

  // Pointers match and toggles equal -> empty_o must be 1
property p3;
     @(posedge rd_clk_i) disable iff (!rst_i)
    ((rd_pntr == wr_pntr_rd_clk) && (rd_toggle == wr_toggle_rd_clk)) |-> empty_o
endproperty

 a_empty: assert property (p3);

  // Read while empty -> underflow_o on next cycle
property p4;
    @(posedge rd_clk_i) disable iff (!rst_i)
    (rd_en_i && empty_o) |=> underflow_o
 endproperty 
  a_underflow: assert property (p4);


// if rst ==0 is wr_en or rd_en high
property p5;
  @(posedge wr_clk_i) rst_i ==0 |-> !wr_en_i;
  endproperty 
  wr_en_a: assert property (p5);

property p8;
  @(posedge rd_clk_i) rst_i ==0 |-> !rd_en_i;
  endproperty 
  rd_en_a: assert property (p8);

//is wdata and rdata valid
property p6;
  @(posedge wr_clk_i) disable iff (!rst_i)
  wr_en_i ==1 |-> !($isunknown(wdata_i));
 endproperty 
  wdata_a: assert property (p6);
property p7;
  @(posedge rd_clk_i) disable iff (!rst_i)
  rd_en_i ==1 |=> !($isunknown(rdata_o));
 endproperty 
  rdata_a: assert property (p7);

endmodule


// Attach the checker to the FIFO (no RTL changes needed)
bind async_fifo fifo_checks u_fifo_checks (
  .wr_clk_i         (wr_clk_i),
  .rd_clk_i         (rd_clk_i),
  .rst_i            (rst_i),
  .wr_en_i          (wr_en_i),
  .rd_en_i          (rd_en_i),
  .full_o           (full_o),
  .empty_o          (empty_o),
  .overflow_o       (overflow_o),
  .underflow_o      (underflow_o),
  .wdata_i          (wdata_i),
  .rdata_o          (rdata_o),
  .wr_pntr          (wr_pntr),
  .rd_pntr          (rd_pntr),
  .wr_toggle        (wr_toggle),
  .rd_toggle        (rd_toggle),
  .rd_pntr_wr_clk   (rd_pntr_wr_clk),
  .rd_toggle_wr_clk (rd_toggle_wr_clk),
  .wr_pntr_rd_clk   (wr_pntr_rd_clk),
  .wr_toggle_rd_clk (wr_toggle_rd_clk)
);
