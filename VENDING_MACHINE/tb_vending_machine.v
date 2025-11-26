`timescale 1ns/1ns

module vending_tb;

  reg coin1,coin2,rst,clk,item;
  reg [1:0] tea_loaded,coffee_loaded;

  wire change,deliver_tea,deliver_coffee;
  wire [1:0] tea_available,coffee_available;

  vending_machine dut(
    .coin1(coin1), 
    .coin2(coin2), 
    .rst(rst), 
    .clk(clk), 
    .item(item), 
    .tea_loaded(tea_loaded), 
    .coffee_loaded(coffee_loaded),
    .change(change), 
    .deliver_tea(deliver_tea), 
    .deliver_coffee(deliver_coffee), 
    .tea_available(tea_available), 
    .coffee_available(coffee_available)
  );


  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

 initial begin
   $monitor("t=%0t,state:%b,coin1=%b,coin2:%b,item=%b,tea_available=%0d, coffee_avl=%0d,change=%b,tea=%b,coffee=%b",
            $time,dut.state,coin1,coin2,item,tea_available,coffee_available,change,deliver_tea,deliver_coffee);
   
   rst =0; coin1 = 0; coin2 = 0;
   tea_loaded = 2'd2; coffee_loaded = 2'd2;
  
   #12 rst = 1;
   item = 1; #10;
  
   @(negedge clk) coin1 = 1; coin2 = 0;
   #10; coin1 = 0; coin2 = 0;
  
   @(negedge clk) coin1 = 0; coin2 = 0;
   #20; coin1 = 0; coin2 = 1;
   #30;
  
   @(negedge clk) coin1 = 1; coin2 = 0; item = 0;
   #30; coin1 = 0; coin2 = 0;
   #20;
 
   @(negedge clk) coin1 = 0; coin2 = 1;
   #40;
   #10 $finish;
 end
endmodule  
  
