module async_fifo (
    input  wr_clk_i,
    input  rd_clk_i,
    input  rst_i,
    input  wr_en_i,
    input  rd_en_i,
    input  [`DATA_WIDTH-1:0] wdata_i,
    output reg [`DATA_WIDTH-1:0] rdata_o,
    output reg full_o,
    output reg empty_o,
    output reg overflow_o,
    output reg underflow_o
);

integer i;

// FIFO Memory
reg [`DATA_WIDTH-1:0] fifo [0:`DEPTH-1];

// Binary pointers
reg [`PTR_WIDTH-1:0] wr_pntr, rd_pntr;

// Toggle bits
reg wr_toggle, rd_toggle;

// Pointer synchronization
reg [`PTR_WIDTH-1:0] rd_pntr_wr_clk;
reg [`PTR_WIDTH-1:0] wr_pntr_rd_clk;

reg rd_toggle_wr_clk;
reg wr_toggle_rd_clk;

// Write Logic

always @(posedge wr_clk_i or negedge rst_i)
begin
    if(rst_i==0) begin
        wr_pntr      <= 0;
        wr_toggle    <= 0;
        overflow_o   <= 0;

        for(i=0;i<`DEPTH;i=i+1)
            fifo[i] <= 0;
    end
    else begin

        overflow_o <= 0;

        if(wr_en_i) begin

            if(full_o)
                overflow_o <= 1;

            else begin

                fifo[wr_pntr] <= wdata_i;

                if(wr_pntr == `DEPTH-1) begin
                    wr_pntr   <= 0;
                    wr_toggle <= ~wr_toggle;
                end
                else
                    wr_pntr <= wr_pntr + 1;

            end
        end
    end
end

// Read Logic

always @(posedge rd_clk_i or negedge rst_i)
begin
    if(rst_i==0) begin
        rd_pntr      <= 0;
        rd_toggle    <= 0;
        rdata_o      <= 0;
        underflow_o  <= 0;
    end
    else begin

        underflow_o <= 0;

        if(rd_en_i) begin

            if(empty_o)
                underflow_o <= 1;

            else begin

                rdata_o <= fifo[rd_pntr];

                if(rd_pntr == `DEPTH-1) begin
                    rd_pntr   <= 0;
                    rd_toggle <= ~rd_toggle;
                end
                else
                    rd_pntr <= rd_pntr + 1;

            end
        end
    end
end

// Synchronize Read Pointer into Write Clock

always @(posedge wr_clk_i or negedge rst_i)
begin
    if(rst_i==0) begin
        rd_pntr_wr_clk   <= 0;
        rd_toggle_wr_clk <= 0;
    end
    else begin
        rd_pntr_wr_clk   <= rd_pntr;
        rd_toggle_wr_clk <= rd_toggle;
    end
end

// Synchronize Write Pointer into Read Clock

always @(posedge rd_clk_i or negedge rst_i)
begin
    if(rst_i==0) begin
        wr_pntr_rd_clk   <= 0;
        wr_toggle_rd_clk <= 0;
    end
    else begin
        wr_pntr_rd_clk   <= wr_pntr;
        wr_toggle_rd_clk <= wr_toggle;
    end
end

// Full Flag

always @(*)
begin
    if(rst_i==0)
        full_o <= 0;
    else
        full_o <= (wr_pntr == rd_pntr_wr_clk) &&
                  (wr_toggle != rd_toggle_wr_clk);
end

// Empty Flag

always @(*)
begin
    if(rst_i==0)
        empty_o <= 1;
    else
        empty_o <= (wr_pntr_rd_clk == rd_pntr) &&
                   (wr_toggle_rd_clk == rd_toggle);
end

endmodule
