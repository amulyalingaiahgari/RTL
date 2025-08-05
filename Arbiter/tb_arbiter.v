module arb_tb;
  reg rst, clk;
  reg [2:0]request;
  wire [2:0]grant;

  arb_d uut (.rst(rst), .clk(clk), . request(request), .grant(grant));
  always #2 clk = ~clk;

  initial
  begin
    clk=0; rst=1;
    #6 rst=0; request=3'b110;
  end

  initial begin
    $monitor("time=%0d, rst=%b, clk=%b, request=%b, grant=%b", $time, rst, clk, request, grant);
    #20 $finish;
  end
endmodule
