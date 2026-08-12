class rd_transaction;
    
rand		bit                      rd_en_i;
				bit [`DATA_WIDTH-1:0]    rdata_o;
				bit                      empty_o;
				bit                      underflow_o;


constraint wr_rd{
                  rd_en_i== 1;
                }

function void print(string name ="rd_tx_class");
    $display("----------time = %0t , name = %0s -----------",$time,name);
    $display("rd_en_i = %0b",rd_en_i);
    $display("rdata_o = %0d", rdata_o);
    $display("empty_o = %0b",empty_o);
    $display("underflow_o = %0b",underflow_o);

    $display("--------------------------------------------");
endfunction

endclass
