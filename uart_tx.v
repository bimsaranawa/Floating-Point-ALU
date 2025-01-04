module uart_tx (
    input wire clk,          // System clock
    input wire [7:0] tx_data, // Byte to transmit
    input wire tx_start,     // Start transmission flag
    output reg tx,           // UART transmit line
    output reg tx_busy       // Transmission in progress flag
);
    parameter BAUD_RATE = 9600;
    parameter CLOCK_FREQ = 100000000; // 100 MHz clock
    localparam BIT_PERIOD = CLOCK_FREQ / BAUD_RATE;

    reg [15:0] bit_timer = 0;
    reg [3:0] bit_index = 0;
    reg [9:0] tx_shift_reg = 10'b1111111111;

    always @(posedge clk) begin
        if (tx_busy) begin
            if (bit_timer == 0) begin
                tx <= tx_shift_reg[0];
                tx_shift_reg <= {1'b1, tx_shift_reg[9:1]};
                bit_index <= bit_index + 1;
                bit_timer <= BIT_PERIOD;

                if (bit_index == 10) begin
                    tx_busy <= 1'b0;
                    tx <= 1'b1;
                end
            end else begin
                bit_timer <= bit_timer - 1;
            end
        end else if (tx_start) begin
            // Load shift register and start transmission
            tx_shift_reg <= {1'b1, tx_data, 1'b0};
            tx_busy <= 1'b1;
            bit_index <= 0;
            bit_timer <= BIT_PERIOD;
            tx <= 1'b0; // Start bit
        end
    end
endmodule
