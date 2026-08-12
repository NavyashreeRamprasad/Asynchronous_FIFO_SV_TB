class wr_agent;

wr_generator gen; 
wr_busfm bfm; 
wr_monitor mon;
wr_coverage cov;

task run();
  gen = new();
  bfm = new();
  mon = new();
  cov = new();
  fork
    gen.run();
    bfm.run();
    mon.run();
    cov.run();
  join
endtask

endclass
