class wr_generator;
  wr_transaction wr_tx;
  task run();
  wait(top.rst_i ==1 ); 
      case(common::testcase)
         
          "EMPTY": begin
                  repeat(`DEPTH+1) begin
                  wr_tx = new();
                  wr_tx.randomize with {wr_tx.wr_en_i == 1;};
                  gen2bfm_wr.put(wr_tx);
                  //wr_tx.print("GEN");
                  end
                 end
                 
         "UNDERFLOW": begin
                  
                  repeat(`DEPTH+1) begin
                  wr_tx = new();
                  wr_tx.randomize with {wr_tx.wr_en_i == 1;};
                  gen2bfm_wr.put(wr_tx);
                  //wr_tx.print("GEN");
                  end
                 end

         "FULL": begin
                  
                  repeat(`DEPTH+1) begin
                  wr_tx = new();
                  wr_tx.randomize with {wr_tx.wr_en_i == 1;};
                  gen2bfm_wr.put(wr_tx);
                  //wr_tx.print("GEN");
                  end
                 end

         "OVERFLOW": begin
                  
                  repeat(`DEPTH+2) begin
                  wr_tx = new();
                  wr_tx.randomize with {wr_tx.wr_en_i == 1;};
                  gen2bfm_wr.put(wr_tx);
                  //wr_tx.print("GEN");
                  end
                 end

         "CONCURRENT": begin
                  
                  repeat(common::N+1) begin
                  wr_tx = new();
                  wr_tx.randomize with {wr_tx.wr_en_i == 1;};
                  gen2bfm_wr.put(wr_tx);
                  end
                 end
         default:$error("INVALID TESTCASE");

      endcase
  endtask

endclass
