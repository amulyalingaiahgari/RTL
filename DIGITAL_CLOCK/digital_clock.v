module digital_clock(
  input clk,rst,
  input twelve_24,
  input [1:0] mode_sel, //0=normal clock, 1=alarm mode, 2=stopwatch mode, 3=set time mode
  input toggle,
  input incr,
  input set_time,
  input set_alarm,
  input start_stop,
  input reset_sw_al,
  input snooze,
  
  output reg [4:0] hours,
  output reg [5:0] minutes,
  output reg [5:0] seconds,
  output reg alarm_signal,
  output reg am_pm
);
   //digital clock signals
  reg [4:0] hh;
  reg [5:0] mm;
  reg [5:0] ss;
  reg a_p;

  //alarm signals
  reg [4:0] hh_alarm;
  reg [5:0] mm_alarm;
  reg [5:0] ss_alarm;
  reg a_p_alarm;

  reg [3:0]alarm_count;
  reg alarm_start;

  reg [2:0]snooze_delay=5;
  
  //signals to select field and increment
  reg [2:0] toggle_count;
  reg [4:0] incr_h;
  reg [5:0] incr_m;
  reg incr_a_p;

  //stopwatch signals
  reg [4:0] hh_sw;
  reg [5:0] mm_sw;
  reg [5:0] ss_sw;

  reg start_sw;
  
  //set time signals
  reg [4:0] hh_st;
  reg [5:0] mm_st;
  reg [5:0] ss_st;
  reg am_pm_st;

  //------------ mode selection ---------------
  always@(posedge clk)begin
    if(rst) begin
      hours <= 0;
      minutes <= 0;
      seconds <= 0;
      am_pm <= 0;
    end
    else begin
      case(mode_sel)
        2'b00: begin // normal clock mode
          hours <= hh;
          minutes <= mm;
          seconds <= ss;
          am_pm <= a_p;
        end          
        2'b01: begin //alarm mode
          if(!toggle_count)begin
            hours <= hh_alarm;
            minutes <= mm_alarm;
            seconds <= 0;
            am_pm <= a_p_alarm;
          end
          else begin
            hours <= incr_h;
            minutes <= incr_m;
            seconds <= ss;
            am_pm <= incr_a_p;
          end
        end
        2'b10: begin
          hours <= hh_sw;
          minutes <= mm_sw;
          seconds <= ss_sw;
          am_pm <= 1'bx;
        end
        2'b11: begin
          hours <= hh_st;
          minutes <= mm_st;
          seconds <= ss_st;
          am_pm <= am_pm_st;
        end
      endcase
    end
  end

  //---------------toggle counter and increment logic -----------
  //toggle counter
  always @(posedge clk) begin
    if(rst) begin
      toggle_count <= 0;
    end
    else begin
      if(mode_sel == 1 || mode_sel == 3)begin
        if(toggle)begin
          if(twelve_24)
            toggle_count<=(toggle_count==2)? 0:toggle_count+1;
          else
            toggle_count<=(toggle_count==1)?0:toggle_count+1;
        end
        else
          toggle_count<=toggle_count;
      end
      else begin
        toggle_count <= 0;
      end      
    end    
  end
  
  //incr counter
  always @(posedge clk) begin
    if(rst) begin
      toggle_count <= 0;
      incr_h <= 0;
      incr_m <= 0;
      incr_a_p<=0;
    end
    else if(mode_sel == 1 || mode_sel == 3)begin
      if(incr) begin
        if(toggle_count == 0) begin
          if(twelve_24)begin
            if(incr_h == 12) 
              incr_h <= 1;
            else 
              incr_h <= incr_h +1;
          end
          else begin
            if(incr_h == 23) 
              incr_h <= 0;
            else
            incr_h <= incr_h +1;
          end          
        end
        else if(toggle_count == 1) begin
          if(incr_m < 59)
            incr_m <= incr_m+1;
          else
            incr_m <=0;
        end
        else if(toggle_count==2 && twelve_24) begin
          incr_a_p <= ~incr_a_p;
        end        
      end
    end
    else begin
      incr_h <= incr_h;
      incr_m <= incr_m;
      incr_a_p<= incr_a_p;
    end    
  end

  //----------------normal clock mode(digital clock timer)-----------
  always @(posedge clk) begin
    if(rst) begin
      hh <= 0;
      mm <= 0;
      ss <= 0;
      a_p <= 0;
    end
    else begin
      if(ss == 59 )begin
        ss<=0;
        if(mm == 59)begin
          mm<=0;
          if(twelve_24)begin
            if(hh == 12) begin
              a_p = ~a_p;
              hh <= 1;
            end
            else begin
              hh <= hh+1;
            end
          end
          else begin
            if(hh == 23) 
              hh <= 0;
            else
              hh <= hh+1;
          end          
        end
        else begin
          mm <= mm+1;
        end        
      end
      else begin
        ss <= ss+1;
      end      
    end
  end

  //-----------------alarm mode-----------------
  //save alarm
  always@(posedge clk)begin
    if(rst) begin
      hh_alarm <= 0;
      mm_alarm <= 0;
      ss_alarm <= 0;
      a_p_alarm <= 0;  
    end
    else if(mode_sel == 1 && set_alarm) begin
      if(twelve_24) begin
        hh_alarm <= incr_h;
        mm_alarm <= incr_m;
        ss_alarm <= 0;
        a_p_alarm <= incr_a_p;
      end
      else begin
        hh_alarm <= incr_h;
        mm_alarm <= incr_m;
        ss_alarm <= 0;
        a_p_alarm <= 0;
      end      
    end
  end
  
  //alarm ring
  always@(posedge clk )begin
    if(rst || reset_sw_al) begin
      alarm_signal<=0;
      alarm_count<=0;
      alarm_start<=0;
    end
    else begin
      if(hh_alarm == hh && mm_alarm == mm && ss_alarm == ss && a_p_alarm == a_p )begin
        alarm_start <= 1;
      end
      else if(alarm_count <9 && alarm_start)begin
        alarm_signal <= 1;
      end
      else if(alarm_count == 9)begin
        alarm_count <= 0;
        alarm_signal <= 0;
        alarm_start <= 0;
      end
      else begin
        alarm_count <= alarm_count;
      end
    end
  end

  //alarm hold for 10 clocks
  always@(posedge clk)begin
    if(rst) begin
      alarm_count <= 0;
    end
    else begin
      if(alarm_start)
        alarm_count <= alarm_count+1;
      else
        alarm_count <= 0;
    end    
  end
  
  //snooze every 10 min
  always@(posedge clk)begin
    if(rst) begin
      alarm_signal <= 0;
    end
    else begin
      if(alarm_signal && snooze) begin
        alarm_signal <= 0;
        alarm_count <= 0;
        alarm_start <= 0;
        if(mm_alarm + snooze_delay > 59) begin
          mm_alarm <= (mm_alarm + snooze_delay)-60;
          if(hh_alarm == 12 && twelve_24)
            hh_alarm <= 1;
          else if(hh_alarm == 23 && !twelve_24)
            hh_alarm <= 0;
          else
            hh_alarm <= hh_alarm+1;
        end
        else
          mm_alarm <= mm_alarm+snooze_delay;
      end
      else
        snooze_delay <= snooze_delay;
    end
  end
  
//-----------------------stopwatch mode--------------------------
  always@(posedge clk)begin
    if(rst || reset_sw_al)begin
      start_sw<=0;
    end
    else begin
      if(mode_sel == 2'b10)begin
        if(start_stop)
          start_sw <= ~ start_sw;
        else 
          start_sw <= start_sw;
      end
      else begin
        start_sw<=0;
      end
    end
  end
  
  //stopwatch counter
  always@(posedge clk)begin
    if(rst || reset_sw_al)begin
      hh_sw <= 0;
      mm_sw <= 0;
      ss_sw <= 0;
    end
    else begin
      if(start_sw)begin
        if(ss_sw == 59) begin
          ss_sw <= 0;
          if(mm_sw == 59) begin
            mm_sw <= 0;
            hh_sw <= hh_sw+1;
          end
          else
          mm_sw <= mm_sw+1;
        end
        else
          ss_sw <= ss_sw+1;
      end
      else begin
        hh_sw <= hh_sw;
        mm_sw <= mm_sw;
        ss_sw <= ss_sw ; 
      end
    end
  end

//----------------set time mode----------------------
  always@(posedge clk)begin
    if(rst)begin
      hh_st <= 0;
      mm_st <= 0;
      ss_st <= 0;
      am_pm_st<=0;
    end
    else begin
      if(mode_sel == 2'b11 && set_time)begin
        hh_st <= incr_h;
        mm_st <= incr_m;
        ss_st <= 0;
        am_pm_st <= incr_a_p;
  
        hh <= incr_h;
        mm <= incr_m;
        ss <= 0;
        a_p <= incr_a_p;
      end
      else begin
        hh_st <= hh_st;
        mm_st <= mm_st;
        ss_st <= ss_st;
        am_pm_st<=am_pm_st;
      end
    end
  end

endmodule  
  
