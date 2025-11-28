module uart_tb;

  // Clock + Reset
  logic clk;
  logic reset;

  // TX signals
  logic transmit;
  logic [7:0] TxData;
  logic TxD;
  logic tx_busy;

  // RX signals
  logic RxD;
  logic [7:0] RxData;
  logic valid_rx;

  // Clock generation: 50 MHz
  initial clk = 0;
  always #10 clk = ~clk;   // 20ns → 50MHz

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
    .RxD(RxD),
    .RxData(RxData),
    .valid_rx(valid_rx)
  );

  // Loopback: TX → RX
  assign RxD = TxD;

  // -------------------------
  // TASK: Send a single byte
  // -------------------------
  task send_byte(input [7:0] data);
  begin
      @(posedge clk);
      TxData   = data;
      transmit = 1;
      @(posedge clk);
      transmit = 0;

      // Wait for valid receive
      wait (valid_rx);

      if (RxData == data)
          $display("PASS: Sent=%h | Received=%h | Time=%0t", data, RxData, $time);
      else
          $display("FAIL: Sent=%h | Received=%h | Time=%0t", data, RxData, $time);
  end
  endtask

  // -------------------------
  // Main stimulus
  // -------------------------
  initial begin
      // Initial values
      reset = 1;
      transmit = 0;
      TxData = 0;

      #200;
      reset = 0;
      #100;

      // Send multiple bytes
      send_byte(8'hA5);
      send_byte(8'h5A);
      send_byte(8'hFF);
      send_byte(8'h00);
      send_byte(8'h3C);

      #5000;
      $display("UART TEST COMPLETED");
      $finish;
  end

  // -------------------------
  // Monitor prints
  // -------------------------
initial begin
    $monitor("T=%0t | Tx=%b | TxData=%h | TxD=%b | RxD=%b | RxData=%h | valid_rx=%b | busy=%b",
              $time, transmit, TxData, TxD, RxD, RxData, valid_rx, tx_busy);
  end

endmodule
