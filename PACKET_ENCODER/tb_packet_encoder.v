module tbpacket();
  reg clk,rst;
  reg [7:0] payload_din;
  reg ip_valid;
  reg [7:0] destination_addr;
  reg [7:0] payload_size;
  wire [7:0] packet_out;
  wire packet_valid;

  packet dut(clk, rst, payload_din, ip_valid, destination_addr, payload_size,packet_out,packet_valid);

  always #2 clk = ~clk;
  
  initial begin
    $monitor("time:%ot, mem[wptr]:%h, parity:%h, payload_din:h", $time, dut.mem[dut.wptr], dut.parity, payload_din);
    clk = 0;
    rst=0;
    #4 rst=1;|
    ip_valid=1;
    destination_addr=8'hAA;
    payload_size=8'h5;

    repeat(payload_size) @(posedge clk) begin
    payload_din={$random}%256;
    end
    @(posedge clk) ip_valid=0;

/* @(posedge clk)
payload_din=8'h11;
@(posedge clk)
payload_din=8'h22;
@(posedge clk)
payload_din=8'h33;
@(posedge clk)
payload_din=8'h44;
@(posedge clk)
payload_din=8'h55;
repeat(9)@(posedge clk)begin
end

wait(packet_valid == 0);
ip_valid=1;
destination_addr=8'hBB;
payload_size=8'h6;

@(posedge clk) begin
payload_din=8'h66;
end

@(posedge clk) begin
payload_din=8'h77;
end
@(posedge clk) begin
payload_din=8'h88;
end
@(posedge clk) begin
payload_din=8'h99;
end
@(posedge clk) begin
payload_din=8'h55;
end

@(posedge clk) begin
payload_din=8'h56;
end

@(posedge clk)
ip_valid=0;
*/
    #1000 $finish();
  end
endmodule

/*always #2 clk = ~clk;
initial begin
clk=0;
rst=0;
ip_valid=0;
#4 rst=1;
#4 ip_valid=1;
@(posedge clk) destination_addr=24;
@(posedge clk) payload_size=5;
//repeat(1) @(posedge clk) begin
// destination_addr={srandom}%256;
// payload_size={$random}%256;
// end
repeat(payload_size) @(posedge clk) begin
payload_din={$random}%256;
end
#4 ip_valid=0;
#2000 $finish;
end
endmodule*/
         
