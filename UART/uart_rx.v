module Uart_Receiver #(
    parameter int CLK_FREQ     = 50_000_000,
    parameter int BAUD_RATE    = 115200,
    parameter int OVERSAMPLE   = 16
)(
    input  logic clk,
    input  logic reset,
    input  logic RxD,
    output logic [7:0] RxData,
    output logic valid_rx
);

    localparam int DIV_CNT = CLK_FREQ / (BAUD_RATE * OVERSAMPLE);
    localparam int DIV_W   = $clog2(DIV_CNT);
    localparam int SAMPLE_MID = OVERSAMPLE/2;

    // Registers
    logic [DIV_W-1:0] timer, timer_n;
    logic [3:0] sample_cnt, sample_cnt_n;
    logic [3:0] bit_cnt, bit_cnt_n;
    logic [9:0] shift_reg, shift_reg_n;

    typedef enum logic {IDLE, RECEIVE} state_t;
    state_t state, state_n;

    logic valid_n;

    // --------------------------------------------------------
    //               SEQUENTIAL LOGIC (always_ff)
    // --------------------------------------------------------
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state       <= IDLE;
            timer       <= 0;
            sample_cnt  <= 0;
            bit_cnt     <= 0;
            shift_reg   <= 10'h3FF;
            valid_rx    <= 0;
        end else begin
            state      <= state_n;
            timer      <= timer_n;
            sample_cnt <= sample_cnt_n;
            bit_cnt    <= bit_cnt_n;
            shift_reg  <= shift_reg_n;
            valid_rx   <= valid_n;
        end
    end

    // --------------------------------------------------------
    //                 COMBINATIONAL LOGIC (FSM)
    // --------------------------------------------------------
    always_comb begin
        // Hold values by default
        state_n      = state;
        timer_n      = timer;
        sample_cnt_n = sample_cnt;
        bit_cnt_n    = bit_cnt;
        shift_reg_n  = shift_reg;
        valid_n      = 0;

        case (state)

            // ------------------------------------------------
            //                      IDLE
            // ------------------------------------------------
            IDLE: begin
                if (!RxD) begin // detect start bit
                    state_n      = RECEIVE;
                    timer_n      = 0;
                    sample_cnt_n = 0;
                    bit_cnt_n    = 0;
                end
            end

            // ------------------------------------------------
            //                   RECEIVE STATE
            // ------------------------------------------------
            RECEIVE: begin
                if (timer == DIV_CNT - 1) begin
                    timer_n = 0;

                    // Mid-sample: shift data
                    if (sample_cnt == SAMPLE_MID)
                        shift_reg_n = {RxD, shift_reg[9:1]};

                    // Sample end
                    if (sample_cnt == OVERSAMPLE - 1) begin
                        sample_cnt_n = 0;

                        if (bit_cnt == 9) begin
                            if (shift_reg[9])      // stop bit check
                                valid_n = 1;
                            state_n = IDLE;
                        end else begin
                            bit_cnt_n = bit_cnt + 1;
                        end
                    end else begin
                        sample_cnt_n = sample_cnt + 1;
                    end

                end else begin
                    timer_n = timer + 1;
                end
            end

        endcase
    end

    assign RxData = shift_reg[8:1];

endmodule
