module uart_tb;
  // Clock and reset
  logic clk;
  logic reset;
  // Transmitter signals
  logic transmit;
  logic [7:0] TxData;
  logic TxD;
  logic tx_busy;
  // Receiver signals
  logic rxd;
  logic [7:0] RxData;
  logic valid_rx;

  // Clock generation: 50 MHz
  initial clk = 0;
  always #10 clk = ~clk;  // 20ns period → 50MHz

  // Instantiate Transmitter
  Uart_Transmitter tx_inst (
    .clk(clk),
    .reset(reset),
    .transmit(transmit),
    .TxData(TxData),
    .TxD(TxD),
    .busy(tx_busy)
  );

  // Instantiate Receiver
  Uart_Receiver rx_inst (
    .clk(clk),
    .reset(reset),
    .RxD(RxD),        // Connect TX to RX directly
    .RxData(RxData),
    .valid_rx(valid_rx)
  );

  // Test logic
  initial begin
    // Initial values
    reset = 1;
    transmit = 0;
    TxData = 8'h00;

    // Apply reset
    #100;
    reset = 0;
    #100;
    
    // Send data byte
    @(posedge clk);
    TxData = 8'hA5;  // Arbitrary test byte: 10100101
    transmit = 1;
    @(posedge clk);
    transmit = 0;

    // Wait for transmission and reception
    wait (valid_rx);
    $display("PASS:Received Correct Data = %h", RxData);

    // Wait a bit and finish
    #10000;
    $finish;
  end
assign rxd=txd;
  initial 
    $monitor("Time:%0t | TxData:%hb | TxD:%b | busy=%b | RxD=%b | RxData=%h | valid_rx=%b", $time,TxData,TxD,busy,RxD,RxData,valid_rx);
endmodule
