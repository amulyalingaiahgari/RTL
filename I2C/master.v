module i2c_master(
  input clk,rst,
  input [6:0]addr,
  input [7:0]data_in,
  input enable,
  input rd_wr,
  output reg [7:0]data_out,
  output ready,
  inout i2c_sda,
  inout i2c_scl );

  localparam IDLE=0,
  START=1,
  ADDRESS=2,
  ADDR_ACK=3,
  WRITE_DATA=4,
  MASTER_DATA_ACK=5,
  READ_DATA=6,
  SLAVE_DATA_ACK=7,
  STOP=8;

  localparam DIVIDE_BY=4;

  reg [7:0]state;
  reg [7:0]saved_addr;
  reg [7:0]saved_data;
  reg [7:0]counter;
  reg [7:0]counter2=0;
  reg write_enable;
  reg sda_out;
  reg i2c_scl_enable=0;
  reg i2c_clk=1;

  assign ready = ( (!rst) && (state == IDLE) ) ? 1 : 0;
  assign i2c_scl = (!i2c_scl_enable) ? 1 : i2c_clk;
  assign i2c_sda = (write_enable) ? sda_out : 1'bz;

  always @(posedge clk) begin
    if(counter2 == (DIVIDE_BY/2)-1) begin
      i2c_clk <= ~i2c_clk;
      counter2 <= 0;
    end
    else
      counter2 <= counter2+1;
  end

  always @(negedge i2c_clk, posedge rst) begin
    if(rst) begin
      i2c_scl_enable <= 0;
      data_out <= 0;
    end
    else begin
      if((state == IDLE) || (state == START) || (state == STOP) ) begin
        i2c_scl_enable <= 0;
      end
      else begin
        i2c_scl_enable <= 1;
      end
    end
  end

  always @(posedge i2c_clk, posedge rst) begin
    if(rst) begin
      state <= IDLE;
    end
    else begin
      case(state)
        IDLE:begin
          if(enable) begin
            state <= START;
            saved_addr <= {addr,rd_wr};
            saved_data <= data_in;
          end
          else
            state <= IDLE;
        end
        START:begin
          counter <= 7;
          state <= ADDRESS;
        end
        ADDRESS:begin
          if(!counter) begin
            state <= ADDR_ACK;
          end
          else begin
            // state <= ADDRESS;
            counter <= counter-l;
          end
        end
        ADDR_ACK:begin
          if( ! i2c_sda) begin
            counter <= 7;
            if(saved_addr[0] == 0)
              state <= WRITE_DATA;
            else
              state <= READ DATA;
          end
          else
            state <= STOP;
        end
        WRITE_DATA:begin
          if(!counter) begin
            state <= SLAVE_DATA_ACK;
          end
          else begin
            //state <= WRITE_DATA;
            counter <= counter-1;
          end
        end
        SLAVE_DATA_ACK:begin
          if((!i2c_sda) && (enable))
            state <= STOP;
        end
        READ_DATA:begin
          data_out[counter] <= i2c_sda;
          if(!counter)
            state <= MASTER_DATA_ACK;
          else
            counter <= counter-1;
        end
        MASTER_DATA_ACK:begin
          state <= STOP;
        end
        STOP:begin
          state <= IDLE;
        end
      endcase
    end
  end

  always @(negedge i2c_clk, posedge rst) begin
    if(rst) begin
      write_enable <= 1;
      sda_out <= 1;
    end
    else begin
case(state)
START:begin
write_enable <= 1;
sda_out <= 0;
end
ADDRESS: begin
write_enable <= 1;
sda_out <= saved_addr[counter];
end
ADDR ACK:begin
write_enable <= 0;
end
WRITE_DATA:begin
write_enable <= 1;
sda_out <= saved_data[counter];
end
SLAVE_DATA_ACK:begin
write_enable <= 0;
end
MASTER_DATA_ACK:begin
write_enable <= 1;
sda_out <= 0:
end
READ_DATA:begin
write_enable <= 0;
end
STOP:begin
write_enable <= 1;
sda_out <= 1;
end
default:begin
write_enable <= 0;
end
endcase
end
end
  endmodule
