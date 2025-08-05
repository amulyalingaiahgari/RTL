module arb_d (
  input rst, clk, 
  input [2:0] request, 
  output reg [2:0] grant );
  
  parameter ideal = 3'b000, so = 3'b001, sl = 3'b010, s2 = 3'b011;
  reg [2:0] nextstate, state;

  always @(posedge clk, posedge rst) begin // seq logic for state
    if(rst == 1'b1)
      state <= ideal;
      else
      state <= nextstate;
  end

  always @(posedge clk) begin // combinational logic for nxt state along with output
    case(state)
      
      ideal: begin
        if(req[0]) begin
          nextstate = s0;
          grant = 3'b001;
        end
        else if(req[1]) begin
          nextstate = sl;
          grant = 3'b010;
        end
        else if(req[2]) begin
          nextstate = s2;
          grant = 3'b011;
        end
        else begin
          nextstate = ideal;
          grant = 3'b000;
        end
      end
      
      s0:begin
        if(req[1]) begin
          nextstate = sl;
          grant = 3'b010;
        end
        else if(req[2]) begin
          nextstate = s2;
          grant = 3'b011;
        end
        else if(req[0]) begin
          nextstate = s0;
          grant = 3'b001;
        end
        else begin
          nextstate = ideal;
          grant = 3'b000;
        end
      end
        
      sl:begin
        if(req[2]) begin
          nextstate = s2;
          grant = 3'b011;
        end
        else if(req[0]) begin
          nextstate = s0;
          grant = 3'b001;
        end
        else if(req[1]) begin
          nextstate = s1;
          grant = 3'b010;
        end
        else begin
          nextstate = ideal;
          grant = 3'b000;
        end
      end

      s2:begin
        if(req[0]) begin
          nextstate = s0;
          grant = 3'b001;
        end
        else if(req[1]) begin
          nextstate = s1;
          grant = 3'b010;
        end
        else if(req[2]) begin
          nextstate = s2;
          grant = 3'b011;
        end
        else begin
          nextstate = ideal;
          grant = 3'b000;
        end
      end
      
      default : begin
        nextstate = ideal;
        grant =3'b000;
      end
    endcase
  end
  
endmodule
