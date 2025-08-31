module packet(clk, rst, payload_din, ip_valid, destination_addr, payload_size, packet_out, packet_valid);
  input clk, rst;
  input [7:0] payload_din;
  input ip_valid;
  input [7:0] destination_addr;
  input [7:0] payload_size;
  output reg [7:0] packet_out;
  output reg packet_valid;

  reg [7:0] parity;
  reg [15:0] header;
  reg [7:0]mem[0:258];
  reg[8:o] wptr;
  reg[8:0] rptr;

  always @(posedge clk)begin
    if(Irst) begin
      wptr <= 0;
      parity <= 0;
    end
    else begin
      if (ip_valid) begin
        header[15:8] <= destination_addr;
        header [7:0] <= payload_size;
        if(wptr == 0) begin
          mem[wptr] <= destination_addr;
          mem[wptr+2] <= payload_din;
          //parity <= payload_din;
          wptr <= wptr+1;
        end
        else if(wptr == 1) begin
          mem[wptr] <= payload_size;
          mem[wptr+2] <= payload_din;
          //parity <= parity^payload_din;
          wptr <= wptr+1;
        end
        else begin
          if(wptr < payload_size) begin
            mem[wptr+2] <= payload_din;
            //parity <= parity^payload_din;
            wptr <= wptr+1;
          end
        end
      end
    end
  end
  
  always @(posedge clk) begin
    if(!rst) begin
      parity <= 0;
      wptr <= 0;
      packet_valid <= 0;
    end
    else if(wptr == payload_size) begin
      mem[wptr+2] <= parity;
      wptr <= wptr+1;
      packet_valid <= 1;
    end
    else if(wptr <= payload_size) begin
      parity <= (destination_addr)^(payload_size)^(payload_din);
    end
  end

  always @(posedge clk) begin
    if(!rst) begin
      rptr <= 0;
      packet_out <= 0;
    end
    else if(wptr >= payload_size && rptr < wptr+2 && packet_valid) begin
      packet_out <= mem[rptr];
      rptr <= rptr+1;
    end
    else if(rptr == wptr+2) begin
      rptr <= 0;
      wptr <= 0;
      packet_valid <= 0;
      parity <= 0;
    end
  end
endmodule
