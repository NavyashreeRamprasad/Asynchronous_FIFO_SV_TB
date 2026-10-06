`define DEPTH 16 
`define DATA_WIDTH  32
`define PTR_WIDTH  $clog2(`DEPTH) 

`include "async_fifo.v"
`include "assertions.sv"
`include "fifo_interface.sv"
`include "fifo_tx_rd.sv"
`include "fifo_tx_wr.sv"
`include "common.sv"
`include "fifo_bfm_rd.sv"
`include "fifo_bfm_wr.sv"
`include "fifo_generator_rd.sv"
`include "fifo_generator_wr.sv"
`include "fifo_monitor_rd.sv"
`include "fifo_monitor_wr.sv"
`include "fifo_cov_rd.sv"
`include "fifo_cov_wr.sv"
`include "fifo_agent_rd.sv"
`include "fifo_agent_wr.sv"
`include "fifo_scb.sv"
`include "fifo_env.sv"
`include "top.sv"

