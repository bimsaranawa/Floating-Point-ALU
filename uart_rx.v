module uart_rx (
    input wire clk,         // System clock
    input wire rx,          // UART receive line
    output reg [7:0] rx_data, // Received byte
    output reg rx_done      // Data reception complete flag
);
    parameter BAUD_RATE = 9600;
    parameter CLOCK_FREQ = 100000000; // 100 MHz clock
    localparam BIT_PERIOD = CLOCK_FREQ / BAUD_RATE;
    
    reg [15:0] bit_timer = 0;
    reg [3:0] bit_index = 0;
    reg [7:0] rx_shift_reg = 0;
    reg rx_sync = 1'b1, rx_prev = 1'b1;
    reg receiving = 1'b0;

    always @(posedge clk) begin
        // Synchronize RX line to avoid metastability
        rx_sync <= rx;
        rx_prev <= rx_sync;

        if (!receiving) begin
            // Start bit detection
            if (rx_prev && !rx_sync) begin
                receiving <= 1'b1;
                bit_timer <= BIT_PERIOD / 2;
                bit_index <= 0;
            end
        end else begin
            if (bit_timer == 0) begin
                bit_timer <= BIT_PERIOD;
                if (bit_index == 0) begin
                    // Start bit check
                    if (rx_sync == 1'b0) bit_index <= bit_index + 1;
                    else receiving <= 1'b0; // Invalid start bit
                end else if (bit_index <= 8) begin
                    // Shift in data bits
                    rx_shift_reg <= {rx_sync, rx_shift_reg[7:1]};
                    bit_index <= bit_index + 1;
                end else begin
                    // Stop bit check
                    if (rx_sync == 1'b1) begin
                        rx_data <= rx_shift_reg;
                        rx_done <= 1'b1;
                    end
                    receiving <= 1'b0;
                end
            end else begin
                bit_timer <= bit_timer - 1;
            end
        end

        // Reset rx_done flag
        if (rx_done && !receiving) rx_done <= 1'b0;
    end
endmodule
