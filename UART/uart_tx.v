module Uart_Transmitter (
    input  logic        clk,
    input  logic        reset,
    input  logic        transmit,
    input  logic [7:0]  TxData,
    output logic        TxD,
    output logic        busy
);

  // Parameters
  parameter int clk_freq    = 50_000_000;
  parameter int baud_rate   = 115200;
  parameter int div_counter = clk_freq / baud_rate;

  // Internal signals
  logic [8:0] cycle_counter;  // Counts clock cycles
  logic [3:0] bit_index;      // Tracks which bit is being sent
  logic [9:0] tx_shift;       // Shift register: start + 8 data + stop
  logic sending;              // Sending state

  // Always block for UART transmission logic
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      TxD           <= 1;
      sending       <= 0;
      cycle_counter <= 0;
      bit_index     <= 0;
      busy          <= 0;

    end else begin

      if (transmit && !sending) begin
        // Load shift register with start(0), data, stop(1)
        tx_shift      <= {1'b1, TxData, 1'b0};
        sending       <= 1;
        bit_index     <= 0;
        cycle_counter <= 0;
        busy          <= 1;

      end else if (sending) begin
        if (cycle_counter == div_counter - 1) begin
          cycle_counter <= 0;
          TxD           <= tx_shift[bit_index];
          bit_index     <= bit_index + 1;

          if (bit_index == 9) begin
            sending <= 0;
            busy    <= 0;
            TxD     <= 1; // Idle state
          end

        end else begin
          cycle_counter <= cycle_counter + 1;
        end
      end
    end
  end

endmodule
