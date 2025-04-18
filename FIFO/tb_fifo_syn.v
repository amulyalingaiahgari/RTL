module tbfifo;
reg clk;
reg rst;
reg wr_en;
reg [7:0]data_in;
reg rd en;
wire [7:0]data_out;
wire empty;
wire full;
fifo dut (data_out, empty, full, clk, rst,wr_en,rd_en, data_in);
always #2 clk =~ clk;
initial
begin
  clk=0;
  rst=1;
  wr_en=0;
  rd en=0;
  data_in=0;
  #4 rst=0;
  wr_en=1;
  repeat (20) @(posedge clk) begin
    data_in={$random}%256;
  end
  #10 rd en=1;
  repeat (20) @(posedge clk) begin
    data_in={$random}%256;
  end
  #5 rd en=0;
  repeat(5) @(posedge clk) begin
    data_in={$random}%256;
  end
  #5 rd_en=1;
  #50 $finish;
end
endmodule
