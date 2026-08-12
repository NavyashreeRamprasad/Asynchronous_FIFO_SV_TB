class scoreboard;
rd_transaction rd_tx ;
wr_transaction wr_tx ;
//local_mem -> queue
bit [`DATA_WIDTH-1:0] fifo_scb [$];
bit [`DATA_WIDTH-1:0] rdata_temp;
  task run();
      forever begin
      //get tx info
      mon2scb_wr.get(wr_tx);
      mon2scb_rd.get(rd_tx);

      if(wr_tx.wr_en_i == 1) begin
          fifo_scb.push_front(wr_tx.wdata_i);
      end
      if(rd_tx.rd_en_i == 1) begin
         rdata_temp = fifo_scb.pop_back();
         common::scb_count++;
         if(rdata_temp == rd_tx.rdata_o)
          common::matching++;
         else
          common::mismatch++;
      end
      
      end
  endtask


endclass
