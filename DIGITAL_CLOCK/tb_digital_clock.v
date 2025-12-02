module tb_digital_clock;

  reg clk, rst;
  reg twelve_24;
  reg [1:0] mode_sel;
  reg toggle, incr;
  reg set_time, set_alarm;
  reg start_stop, reset_sw_al;
  reg snooze;

  wire [4:0] hours;
  wire [5:0] minutes;
  wire [5:0] seconds;
  wire alarm_signal;
  wire am_pm;

  digital_clock dut(
    .clk(clk),
    .rst(rst),
    .twelve_24(twelve_24),
    .mode_sel(mode_sel),
    .toggle(toggle),
    .incr(incr),
    .set_time(set_time),
    .set_alarm(set_alarm),
    .start_stop(start_stop),
    .reset_sw_al(reset_sw_al),
    .snooze(snooze),
    .hours(hours),
    .minutes(minutes),
    .seconds(seconds),
    .alarm_signal(alarm_signal),
    .am_pm(am_pm)
  );

  // clock
  initial clk=0;
  always #5 clk = ~clk;

  initial begin
    rst = 1;
    toggle = 0;
    incr = 0;
    set_time = 0;
    set_alarm = 0;
    start_stop = 0;
    reset_sw_al = 0;
    snooze = 0;
    twelve_24 = 1;  // 12hr mode
    mode_sel = 0;

    // TIME 0 → Reset
    #20 rst = 0;
    
  //============NORMAL CLOCK RUN (mode 00)=====
    mode_sel = 2'b00;
    #200;

   
  //============SET ALARM (mode 01)============ 
    mode_sel = 2'b01;

    //toggle → select hour
    //toggle = 1; #10; toggle = 0;
    //incr = 1; #50; incr = 0;

    // toggle → select minute
    toggle = 1; #20; toggle = 0;
    incr = 1; #50; incr = 0;

    //toggle → AM/PM
    toggle = 1; #10; toggle = 0;

    // save alarm
    set_alarm = 1; #20; set_alarm = 0;

    // return to normal mode
    mode_sel = 2'b00;
    #3000;

    
    //FORCE ALARM TRIGGER
    #200;
    
    //SNOOZE
        snooze = 1; #20; snooze = 0;
    #200;
    
   
  //=============STOPWATCH (mode 10)=============
    mode_sel = 2'b10;

    // start
    start_stop = 1; #10; start_stop = 0;
    #200;

    // stop
    start_stop = 1; #10; start_stop = 0;
    #100;

    // reset stopwatch
    reset_sw_al = 1; #20; reset_sw_al = 0;
  
 
  //==========SET TIME (mode 11)============
    mode_sel = 2'b11;

    // toggle → select hour
    toggle = 1; #10; toggle = 0;
    incr = 1; #50; incr = 0;

    // toggle → select minute
    toggle = 1; #20; toggle = 0;
    incr = 1; #40; incr = 0;

    // toggle → AM/PM
    toggle = 1; #2; toggle = 0;

    // save alarm
    set_time = 1; #20; set_time = 0;
  
    mode_sel = 2'b00;
    #600;
    
    $finish;
  end
    
  initial begin
   $monitor("time=%0t | Mode=%b | %0d:%0d:%0d | %b | alarm=%b", $time, mode_sel, hours, minutes, seconds, am_pm, alarm_signal);
  end
  
endmodule
