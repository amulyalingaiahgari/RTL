module tb_washing_machine();
  //inputs
  reg clk;
  reg reset;
  reg start;
  reg pause;
  reg [1:0]mode;
  reg power;
//outputs
  wire water_in;
  wire detergent;
  wire door_lock;
  wire drain;
  wire done;

  washing_machine_controller dut(clk, reset, start, pause, mode, power, water_in, detergent, door_lock, drain, done);

  initial clk=0;
  always #5 clk =~ clk; //10ns clock period (100MHZ)

  initial begin
    $monitor("Time=%0t state=%0d |water_in=%b detergent=%b drain=%b rinse_count=%b done=%b", $time,dut.state,water_in, detergent, drain, dut.rinse_count,done);

    power=0;
    reset=1;
    start=0;
    pause=0;
    mode={$random}%4;

    #20;
    power=1;
    reset=0;
    start=1;

    /*#30;
    start=0;
    #1000;
    pause=1;
    #100;
    pause=0;*/

    #20000;
    $finish;
  end
endmodule
