module Uart_Transmitter #(
    parameter int CLK_FREQ  = 50_000_000,
    parameter int BAUD_RATE = 115200
)(
    input  logic clk,
    input  logic reset,
    input  logic transmit,
    input  logic [7:0] TxData,
    output logic TxD,
    output logic busy
);

    localparam int DIV_CNT = CLK_FREQ / BAUD_RATE;
    localparam int DIV_W   = $clog2(DIV_CNT);

    logic [DIV_W-1:0] bit_timer;
    logic [3:0]       bit_index;
    logic [9:0]       shift_reg;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            TxD       <= 1;
            bit_timer <= 0;
            bit_index <= 0;
            shift_reg <= 10'h3FF;
            busy      <= 0;
        end 
        else begin
            if (!busy) begin
                if (transmit) begin
                    // Load frame: stop + data + start
                    shift_reg <= {1'b1, TxData, 1'b0};
                    bit_index <= 0;
                    bit_timer <= 0;
                    busy      <= 1;
                end
            end

            else begin
                // **Clock enable based on bit timer**
                if (bit_timer == DIV_CNT - 1) begin
                    bit_timer <= 0;
                    TxD       <= shift_reg[bit_index];
                    bit_index <= bit_index + 1;

                    if (bit_index == 9) begin
                        busy <= 0;
                        TxD  <= 1;
                    end
                end else begin
                    bit_timer <= bit_timer + 1;
                end
            end
        end
    end
endmodule
