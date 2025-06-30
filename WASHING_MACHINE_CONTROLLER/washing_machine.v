module washing_machine_controller (
  //inputs
  input clk,
  input reset,
  input start,
  input pause,
  input [1:0] mode,
  input power,
  //outputs
  output reg water_in,
  output reg detergent,
  output reg door_lock,
  output reg drain,
  output reg done
);

  reg [1:0] rinse_count;
  reg [2:0] state, next_state;
  reg [9:0] timer;

  parameter IDLE   = 3'b000,
            FILL   = 3'b001,
            WASH   = 3'b010,
            DRAIN  = 3'b011,
            RINSE  = 3'b100,
            SPIN   = 3'b101;

  parameter MIN = 60,
            WATER_IN_TIME = 2 * MIN,
            DETERGENT_TIME = 30,
            DRAIN_TIME = 1 * MIN,
            SPIN_TIME = 3 * MIN,
            RINSE_TIME = 5 * MIN,
            QUICK_WASH = 5 * MIN,
            NORMAL_WASH = 10 * MIN,
            HEAVY_WASH = 15 * MIN;

  reg [8:0] WASH_TIME;
  // Wash time based on mode
  always @(*) begin
    case (mode)
      2'b00: WASH_TIME = QUICK_WASH;
      2'b01: WASH_TIME = NORMAL_WASH;
      2'b10: WASH_TIME = HEAVY_WASH;
      default: WASH_TIME = NORMAL_WASH;
    endcase
  end

  // Timer and state update
  always @(posedge clk) begin
    if (reset) begin
      state <= IDLE;
      timer <= 0;
      rinse_count<=0;
      water_in<=0;
      detergent<=0;
      door_lock<=0;
      drain<=0;
      done<=0;
    end
    else if (!power || pause) begin
      state <= state;
      timer <= timer;
    end
    else begin
      state <= next_state;
      if (state != next_state)
        timer <= 0;
      else
        timer <= timer + 1;
    end
  end


  // Rinse count logic
  always @(posedge clk) begin
    if (reset)
      rinse_count <= 0;
    else if (state==DRAIN && next_state==RINSE && rinse_count<2)
      rinse_count <= rinse_count + 1;
    else if (state == IDLE)
      rinse_count <= 0;
    else 
      rinse_count<=rinse_count;
  end

  // FSM Output and Next State Logic
  always @(*) begin
    // Default output values
    door_lock = 0;
    water_in = 0;
    detergent = 0;
    drain = 0;
    done = 0;
    next_state = state;

    case (state)
      IDLE: begin
        door_lock = 0;
        done = (!start);
        next_state = (start && power) ? FILL : IDLE;
      end
      FILL: begin
        door_lock = 1;
        water_in = 1;
        detergent = 1;
        next_state = (timer >= WATER_IN_TIME + DETERGENT_TIME) ? WASH : FILL;
      end
      WASH: begin
        door_lock = 1;
        water_in = 1;
        detergent = 1;
        next_state = (timer >= WASH_TIME) ? DRAIN : WASH;
      end
      DRAIN: begin
        door_lock = 1;
        drain = 1;
        if(timer >= DRAIN_TIME) begin
           if(rinse_count == 2) 
              next_state=SPIN;
            else
              next_state=RINSE;
         end
         else
          next_state=DRAIN;
      end
      RINSE: begin
        door_lock = 1;
        water_in = 1;
        next_state = (timer >= RINSE_TIME) ? DRAIN : RINSE;
      end
      SPIN: begin
        door_lock = 1;
        if(timer >= SPIN_TIME) begin
          next_state=IDLE;
          done=1;
        end
        else
          next_state=SPIN;
      end
      default: next_state = IDLE;
    endcase
  end

endmodule
