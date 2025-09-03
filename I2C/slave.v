module i2c_slave(
inout sda,
inout scl );

localparam ADDRESS=7'b0000001;

localparam READ_ADDR=0,
ADDR_ACK=1,
READ_DATA=2,
WRITE_DATA=3,
DATA_ACK=4;

reg [7:0]addr;
reg [7:0]counter;
reg [7:0]state=0;
reg [7:0]data_in=0;
reg [7:0]data_out=8'b11001100;
reg sda_out=0;
reg sda_in=0;
reg start=0;
reg write_enable=0;

  assign sda=(write_enable) ? sda_out : 1'bz;

always @(negedge sda) begin
if((!start) && (scl)) begin
start <= 1;
counter <= 7;
end
end

always @(posedge scl) begin
if(start) begin
case(state)
READ_ADDR: begin
addr[counter] <= sda;
if(!counter)
state <= ADDR_ACK;
else
counter <= counter-l;
end
ADDR ACK:begin
if(addr[7:1] == ADDRESS) begin
counter <= 7;
  if(addr[0] == 0)
state <= READ_DATA;
else
state <= WRITE_DATA;
end
end
READ_DATA:begin
data_in[counter] <= sda;
if(!counter)
state <= DATA ACK;
else
counter <= counter-1;
end
DATA_ACK:begin
state <= READ_ADDR;
end
WRITE_DATA:begin
  if(counter == 0)
state <= READ ADDR;
else
counter <= counter-1;
end
endcase
end
end

always @(negedge scl) begin
case(state)
READ_ADDR:begin
write_enable <= 0;
end
ADDR_ACK:begin
sda_out <= 0;
write_enable <= 1;
end
READ_DATA:begin
write_enable <= 0;
end
WRITE_DATA:begin
sda_out <= data_out[counter];
write_enable<=1;
end
  DATA_ACK:begin
    sda_out<=0;
    write_enable<=1;
  end
endcase
end
endmodule
