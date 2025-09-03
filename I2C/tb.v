module i2c_tb;
reg clk, rst;
reg [6:0]addr;
reg [7:0]data_in;
reg enable, rd_wr;
wire [7:0]data_out;
wire ready;
wire i2c_sda, i2c_scl;

  i2c_master master(.clk(clk), .rst(rst), .addr(addr), .data_in(data_in), .enable(enable), .rd_wr(rd_wr), .data_out(data_out), .ready(ready), .i2c_sda(i2c_sda), .i2c_scl(i2c_scl));
i2c_slave slave(.sda(i2c_sda), .scl(i2c_scl));

always #1 clk = ~clk;

initial begin
clk=0;
rst=1;
#100 rst=0;|

addr=7'b0000001;
data_in=8'b1010_1010;
rd_wr=0;
enable=1;

#10;
wait(master.state == 0);

data_in=8'b0000_1111;
#10;
wait(master.state == 0);

enable=0;
#500 $finish;
end

initial begin
  if($time == 10000
$finish;
     end
initial begin
  $monitor("Time:0t | Enable:%b | master_state:%0d | slave_state:%0d", $time,enable,master.state,slave.state);
end
     endmodule
