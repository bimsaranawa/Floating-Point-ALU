module fp_alu_top (
    input  wire btn1,         // Button 1: Opcode[0]
    input  wire btn2,         // Button 2: Opcode[1]
    input  wire btn3,         // Button 3: Add/Sub (0 = Add, 1 = Sub)
    output wire led_add,      // LED for Add operation
    output wire led_sub,      // LED for Sub operation
    output wire led_mul,      // LED for Mul operation
    output wire led_div       // LED for Div operation
);

// Hardcoded 32-bit floating-point numbers (example values)
wire [31:0] a = 32'hc1be1d49; // -23.7643 in IEEE 754
wire [31:0] b = 32'h3f3ad42c; // 0.7298 in IEEE 754

// Inputs for fp_alu
wire [1:0] opcode = {btn2, btn1};
wire add_sub = btn3;

// Output of fp_alu
wire [31:0] alu_result;

// Instantiate fp_alu
fp_alu fp_alu_inst (
    .a(a),
    .b(b),
    .opcode(opcode),
    .add_sub(add_sub),
    .result(alu_result)
);

// Expected results (hardcoded for the given inputs and operations)
wire [31:0] expected_add    = 32'hc1b846a8; 
wire [31:0] expected_sub    = 32'hc1c3f3ea;
wire [31:0] expected_mul    = 32'hc18abed7; 
wire [31:0] expected_div    = 32'hc2024043; 

// Compare ALU result with expected result for each operation
assign led_add = (opcode == 2'b00 && !add_sub && alu_result == expected_add);
assign led_sub = (opcode == 2'b00 && add_sub && alu_result == expected_sub);
assign led_mul = (opcode == 2'b01 && alu_result == expected_mul);
assign led_div = (opcode == 2'b10 && alu_result == expected_div);

endmodule
