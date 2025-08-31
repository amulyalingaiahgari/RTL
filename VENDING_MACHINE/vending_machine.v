`timescale 1ns/1ns

module vending_machine(
            input coin1,coin2,
            input rst,clk,
            input item,
            input [1:0] tea_loaded, coffee_loaded,
            output reg change, deliver_tea, deliver_coffee,
            output reg [1:0] tea_available, coffee_available
);
            reg [2:0] state, next_state;
            parameter Idle = 3'd0,
            Idle_tea = 3'd1,
            Idle_coffee = 3'd2,
            tea_st1 = 3'd3, 
            tea_st2 = 3'd4,
            coffee_st1 = 3'd5,
            coffee_st2 = 3'd6;

  //sequential state update
 always @(posedge clk) begin
     if(!rst)
       state <= Idle;
     else
       state <= next_state;
   end
//sequential stock update
  always @(posedge clk) begin
    if(!rst) begin
      tea_available<=0;
      coffee_available<=0;
    end
    else begin     
   case(state)    
    Idle: begin
      tea_available<=tea_loaded;
      coffee_available<=coffee_loaded;
      end
     tea_st1,tea_st2:begin
       if(tea_available > 0)
         tea_available <= tea_available-1;
     end
     coffee_st1,coffee_st2:begin
       if(coffee_available >0)
         coffee_available <= coffee_available-1;
     end
   endcase
    end
  end
  
  //next state logic
  always @(*) begin
    case(state)
      Idle:if((item) && tea_available)
             next_state = Idle_tea;
      else if((!item) && coffee_available)
             next_state = Idle_coffee;
          else  next_state = Idle;

    Idle_tea: if((coin1)&&(item) && tea_available)
                next_state = tea_st1;
     else if((coin2)&&(item) && tea_available)
                next_state = tea_st2;
               else
                next_state = Idle;

    tea_st1:   next_state = Idle;
   
    tea_st2:   next_state = Idle;

      Idle_coffee: if((coin1)&&(!item) && coffee_available)
                   next_state = coffee_st1;
      else if((coin2)&&(!item) && coffee_available)
                   next_state = coffee_st2;
                 else
                   next_state = Idle;

    coffee_st1:   next_state = Idle;
     
   coffee_st2:   next_state = Idle;

   default: next_state = Idle;
  endcase
  end

 // output logic
  always @(*) begin
    change=0;
    deliver_tea=0;
    deliver_coffee=0;
   case(state)
    tea_st1: begin
                deliver_tea = 1;
 end

    tea_st2:  begin
              change = 1;
              deliver_tea = 1;
    end
    coffee_st1:   begin              
              deliver_coffee = 1;
              end

   coffee_st2:   begin
              change = 1;
              deliver_coffee = 1;
end
  endcase
  end
 endmodule
   
