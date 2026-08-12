class environment;

wr_agent wr_agnt;
rd_agent rd_agnt;
scoreboard scb;
task run();
  rd_agnt = new();
  wr_agnt = new();
  scb = new();
  fork
  rd_agnt.run();
  wr_agnt.run();
  scb.run();
  join
endtask

endclass
