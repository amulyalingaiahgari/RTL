module Uart_Receiver (
    input  logic        clk,
    input  logic        reset,
    input  logic        RxD,
    output logic [7:0]  RxData,
    output logic        valid_rx
);

    parameter int clk_freq     = 50_000_000;
    parameter int baud_rate    = 115200;
    parameter int div_sample   = 16;
    parameter int div_counter  = clk_freq / (baud_rate * div_sample);
    parameter int mid_sample   = div_sample / 2;
    parameter int total_bits   = 10;

    logic state, nextstate;
    logic shift;
    logic [3:0] bit_counter;
    logic [3:0] sample_counter;
    logic [15:0] cycle_counter;
    logic [9:0] rxshift_reg;
    logic clear_bitcounter, inc_bitcounter;
    logic clear_samplecounter, inc_samplecounter;
    logic valid_rx_next;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state           <= 0;
            bit_counter     <= 0;
            sample_counter  <= 0;
            cycle_counter   <= 0;
            rxshift_reg     <= 10'b1111111111;
            valid_rx        <= 0;
        end else begin
            valid_rx <= 0;
            if (cycle_counter == div_counter - 1) begin
                cycle_counter <= 0;
                state <= nextstate;

                if (shift)
                    rxshift_reg <= {RxD, rxshift_reg[9:1]};

                if (clear_samplecounter)
                    sample_counter <= 0;
                if (inc_samplecounter)
                    sample_counter <= sample_counter + 1;

                if (clear_bitcounter)
                    bit_counter <= 0;
                if (inc_bitcounter)
                    bit_counter <= bit_counter + 1;

                if (valid_rx_next)
                    valid_rx <= 1;
            end else begin
                cycle_counter <= cycle_counter + 1;
            end
        end
    end

    always_comb begin
        shift               = 0;
        clear_samplecounter = 0;
        inc_samplecounter   = 0;
        clear_bitcounter    = 0;
        inc_bitcounter      = 0;
        valid_rx_next       = 0;
        nextstate           = state;

        case (state)
            0: begin // Idle
                if (!RxD) begin
                    nextstate           = 1;
                    clear_bitcounter    = 1;
                    clear_samplecounter = 1;
                end
            end

            1: begin // Receiving
                if (sample_counter == mid_sample)
                    shift = 1;

                if (sample_counter == div_sample - 1) begin
                    clear_samplecounter = 1;
                    if (bit_counter == total_bits - 1) begin
                        if (rxshift_reg[9]) begin // Stop bit check
                            valid_rx_next = 1;
                        end
                        nextstate = 0;
                    end else begin
                        inc_bitcounter = 1;
                    end
                end else begin
                    inc_samplecounter = 1;
                end
            end
        endcase
    end

    assign RxData = rxshift_reg[8:1]; // Extracting 8-bit data from shift register

endmodule
