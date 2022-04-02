// show ahead fifo simulation wrapper
// with time improvement
module fifo_8_8_sa (
    rst, rd_clk, rd_en, dout, empty, wr_clk, wr_en, din, full);

parameter DataWidth = 8;

input rst;
input rd_clk;
input rd_en;
input wr_clk;
input wr_en;
input [(DataWidth-1):0] din;
output empty;
output full;
output [(DataWidth-1):0] dout;

reg fifo_valid, middle_valid, dout_valid;
reg [(DataWidth-1):0] dout, middle_dout;

wire [(DataWidth-1):0] fifo_dout;
wire fifo_empty, fifo_rd_en;
wire will_update_middle, will_update_dout;

// original dual-clock fifo from Lattice
fifo_8_8 lattice_fifo (
    .Data(din),
    .WrClock(wr_clk),
    .RdClock(rd_clk),
    .WrEn(wr_en),
    .RdEn(fifo_rd_en),
    .Reset(rst),
    .RPReset(0),
    .Q(fifo_dout),
    .Empty(fifo_empty),
    .Full(full)
);

assign will_update_middle = fifo_valid && (middle_valid == will_update_dout);
assign will_update_dout = (middle_valid || fifo_valid) && (rd_en || !dout_valid);
assign fifo_rd_en = (!fifo_empty) && !(middle_valid && dout_valid && fifo_valid);
assign empty = !dout_valid;

always @(posedge rd_clk)
    if (rst) begin
        fifo_valid <= 0;
        middle_valid <= 0;
        dout_valid <= 0;
        dout <= 0;
        middle_dout <= 0;
    end
    else begin
        if (will_update_middle)
            middle_dout <= fifo_dout;

        if (will_update_dout)
            dout <= middle_valid ? middle_dout : fifo_dout;

        if (fifo_rd_en)
            fifo_valid <= 1;
        else if (will_update_middle || will_update_dout)
            fifo_valid <= 0;

        if (will_update_middle)
            middle_valid <= 1;
        else if (will_update_dout)
            middle_valid <= 0;

        if (will_update_dout)
            dout_valid <= 1;
        else if (rd_en)
            dout_valid <= 0;
    end

endmodule