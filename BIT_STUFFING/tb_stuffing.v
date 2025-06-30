module tb_stuf;
  reg clk;
  reg rst;
  reg valid_in;
  reg data_in;
  wire valid_stuffed;
  wire stuffed_data;

  stuf uut (clk, rst,valid_in, data_in, valid_stuffed, stuffed_data);
  always #2 clk = ~clk;
  initial begin
    clk=0;
    rst=1;
    #4 rst=0;
    #5 valid_in=1;
    repeat(32) @(posedge clk) begin
      data_in=1;
    end
    #4 valid_in=0;
    #50 valid_in=1;
    repeat(12) @(posedge clk) begin
      data_in={$random}%2;
    end
    repeat(10) @(posedge clk) begin
      data_in={$random}%2;
    end
    repeat(10) @(posedge clk) begin
      data_in={$random}%2;
    end
    #4 valid_in=0;
    #30 sfinish;
  end
endmodule
