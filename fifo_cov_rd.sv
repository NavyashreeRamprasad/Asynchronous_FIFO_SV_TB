class rd_coverage;
rd_transaction rd_tx;

  covergroup cgr;

  READ: coverpoint rd_tx.rd_en_i{
  bins RD_EN = {1'b1};}

  EMPTY: coverpoint rd_tx.empty_o{
  bins EM ={1'b1};} 

  UNDERFLOW: coverpoint rd_tx.underflow_o{
  bins UF ={1'b1};}

  endgroup


function new();
    cgr = new();
endfunction

task run();
  forever begin
  mon2cov_rd.get(rd_tx);
  //rd_tx.print("COV_RD_TX");
  cgr.sample();
  end
endtask

endclass
