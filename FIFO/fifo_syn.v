module fifo #(parameter width=8, parameter depth=8) (data_out, empty, full, clk, rst, wr_en, rd_en, data_in);
input clk;
input rst;
input wr_en;
input rd en;
input [width-1:0]data_in;
output reg [width-1:0]data_out;
output reg empty;
output reg full;
//internal signals
reg [width-1:0] fifo_mem [0:depth-1];
reg [2:0]wr_ptr;
reg [2:0]rd_ptr;
reg [depth-1:0]fifo_state;

//logic for write and read data
always @(posedge clk) begin
if(rst) begin
wr_ptr <= 0;
fifo_state <= 0;
end
else begin
if(wr en && (!full)&&(fifo_state[wr_ptr] == 0)) begin
wr_ptr <= wr_ptr+1;
fifo_mem[wr_ptr] <= data_in;
fifo_state[wr_ptr] <= 1;
end
else
wr_ptr <= 0;
end
end
always @(posedge clk) begin
if(rst) begin
rd_ptr <= 0;
fifo_state <= 0;
  end
else begin
if (rd en && (!empty) ) begin
data_out <= fifo_mem[rd_ptr];
rd_ptr <= rd_ptr+1;
fifo_state[rd_ptr] <= 0;
end
else
rd_ptr <= 0;
end
end
//logic for full and empty
always @(posedge clk) begin
if(rst) begin
full <= 0;
empty <= 0;
end
else begin
full <= (fifo_state[wr_ptr] == 1);
empty <= (fifo_state[rd_ptr] == 0);
end
end
endmodule
