class rd_agent;

rd_generator gen; 
rd_busfm bfm; 
rd_monitor mon;
rd_coverage cov;

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
