`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:10:18 10/21/2024
// Design Name:   fp_alu
// Module Name:   E:/ISE Projects/FP_ALU/tb_fp_alu.v
// Project Name:  FP_ALU
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: fp_alu
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_fp_alu;

// Testbench signals
reg  [31:0] a;
reg  [31:0] b;
reg  [1:0]  opcode;
reg         add_sub;
wire [31:0] result;

// Instantiate the fp_alu
fp_alu uut (
    .a(a),
    .b(b),
    .opcode(opcode),
    .add_sub(add_sub),
    .result(result)
);

// Test cases
initial begin
    // Initialize signals
    a = 32'hc1be1d49;  // Example input: -23.7643 (float representation)
    b = 32'h3f3ad42c;  // Example input: 0.7298 (float representation)

    // Test Add (opcode = 00, add_sub = 0)
    opcode = 2'b00;
    add_sub = 1'b0;
    #10;
    $display("Addition result: %h", result);

    // Test Sub (opcode = 00, add_sub = 1)
    add_sub = 1'b1;
    #10;
    $display("Subtraction result: %h", result);

    // Test Mul (opcode = 01)
    opcode = 2'b01;
    #10;
    $display("Multiplication result: %h", result);

    // Test Div (opcode = 10)
    opcode = 2'b10;
    #10;
    $display("Division result: %h", result);

    // Finish simulation
    $finish;
end

endmodule
