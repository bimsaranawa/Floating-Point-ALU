module fp_alu_uart (
    input wire clk,         // System clock
    input wire rx,          // UART RX line
    output wire tx          // UART TX line
);
    // UART signals
    wire [7:0] rx_data;
    wire rx_done;
    reg [7:0] tx_data;
    reg tx_start;
    wire tx_busy;

    // ALU inputs and outputs
    reg [31:0] a, b;
    reg [1:0] opcode;
    reg add_sub;            // Add/Sub control bit
    wire [31:0] result;

    // State machine
    reg [3:0] state;
    reg [1:0] byte_count;   // Byte counter for input data assembly

    // Instantiate UART Receiver
    uart_rx uart_rx_inst (
        .clk(clk),
        .rx(rx),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    // Instantiate UART Transmitter
    uart_tx uart_tx_inst (
        .clk(clk),
        .tx_data(tx_data),
        .tx_start(tx_start),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    // Instantiate ALU
    fp_alu alu_inst (
        .a(a),
        .b(b),
        .opcode(opcode),
        .add_sub(add_sub),
        .result(result)
    );

    // State machine for communication
    always @(posedge clk) begin
        case (state)
            // Idle state, waiting for incoming data
            0: if (rx_done) begin
                a[31:24] <= rx_data; // Receive first byte of `a`
                byte_count <= 0;
                state <= 1;
            end

            // Receive remaining bytes of `a`
            1: if (rx_done) begin
                case (byte_count)
                    0: a[23:16] <= rx_data;
                    1: a[15:8] <= rx_data;
                    2: begin
                        a[7:0] <= rx_data;
                        state <= 2; // All bytes of `a` received
                    end
                endcase
                byte_count <= byte_count + 1;
            end

            // Receive all bytes of `b`
            2: if (rx_done) begin
                b[31:24] <= rx_data; // Receive first byte of `b`
                byte_count <= 0;
                state <= 3;
            end

            // Receive remaining bytes of `b`
            3: if (rx_done) begin
                case (byte_count)
                    0: b[23:16] <= rx_data;
                    1: b[15:8] <= rx_data;
                    2: begin
                        b[7:0] <= rx_data;
                        state <= 4; // All bytes of `b` received
                    end
                endcase
                byte_count <= byte_count + 1;
            end

            // Receive opcode and add_sub control bit
            4: if (rx_done) begin
                opcode <= rx_data[1:0];   // Extract 2-bit opcode
                add_sub <= rx_data[2];   // Extract add_sub bit
                state <= 5;              // Proceed to compute
            end

            // Transmit result bytes
            5: begin
                tx_data <= result[31:24]; // Transmit first byte
                tx_start <= 1;
                if (!tx_busy) state <= 6;
            end
            6: begin
                tx_data <= result[23:16]; // Transmit second byte
                tx_start <= 1;
                if (!tx_busy) state <= 7;
            end
            7: begin
                tx_data <= result[15:8]; // Transmit third byte
                tx_start <= 1;
                if (!tx_busy) state <= 8;
            end
            8: begin
                tx_data <= result[7:0]; // Transmit fourth byte
                tx_start <= 1;
                if (!tx_busy) state <= 0; // Return to idle
            end
        endcase
    end
endmodule
