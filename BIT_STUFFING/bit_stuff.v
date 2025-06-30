module stuf (
  input clk,
  input rst,
  input valid_in,
  input data_in,
  output reg valid_stuffed
  output reg stuffed_data );
  reg [3:0] count_ones;

  parameter memsize=8;
  reg mem[memsize-1:0];
  reg [2:0]wr_ptr;
  reg [2:0]rd_ptr;
  reg delay;

//data_in logic and wr_ptr logicl
  always @(posedge clk) begin
    if(rst) begin
      wr_ptr <= 0;
    end
    else begin
      if(valid_in) begin
        mem[wr_ptr] <= data_in;
        wr_ptr <= wr_ptr+1;
      end
      else begin
        mem[wr_ptr] <= 0;
        wr_ptr <= 0;
      end
    end
  end
//output valid logic
  always @(posedge clk) begin
    if(rst)begin
      valid_stuffed <= 0;
      delay <= 0;
    end
    else if(valid in)
      delay <= 1;
    else
      delay <= delay;
  end
  
  always @(posedge clk) begin
    if(rst)begin
      valid_stuffed <= 0;
      delay <= 0;
    end
    else if(count_ones == 4 && wr_ptr == rd_ptr)
      delay <= 0;
    else if (delay)
      valid_stuffed <= 1;
    else begin
      valid_stuffed <= 0;
      rd_ptr <= 0;
    end
  end

  //stuffing logic
  always @(posedge clk) begin
    if(rst) begin
      count_ones <= 0;
      stuffed data <= 0;
      rd_ptr <= 0;
      valid stuffed <= 0;
    end
    else if(valid_stuffed) begin
      if (!mem[rd_ptr] && count_ones != 4) begin
        stuffed_data <= mem[rd_ptr];
        rd_ptr <= rd_ptr+1;
      end
      else begin
        if(count_ones == 4)begin
          stuffed_data <= 1'b0;
          count_ones <= 0;
          rd_ptr <= rd_ptr;
        end
        else begin
          stuffed_data<=mem[rd_ptr];
          count_ones<=count_ones+1;
          rd_ptr<=rd_ptr+1;
        end
      end
    end
    else begin
      rd_ptr<=0;
      stuffed_data<=1'b0;
      count_ones<=0;
    end
  end
endmodule
          
