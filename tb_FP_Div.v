`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:58:45 10/12/2024
// Design Name:   FP_div
// Module Name:   E:/ISE Projects/FP_ALU/tb_FP_Div.v
// Project Name:  FP_ALU
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: FP_div
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_FP_Div;

    // Inputs
    reg [31:0] A;
    reg [31:0] B;

    // Outputs
    wire [31:0] C;

    // Instantiate the Division module
    FP_Div uut (
        .float_a(A), 
        .float_b(B), 
        .result(C)
    );

    initial begin
        // Initialize inputs
        $monitor("Time: %0d, A = %h, B = %h, C = %h", $time, A, B, C);

        // Case 1: Normal division
        A = 32'h40e00000; // 7.0 in IEEE 754 format
        B = 32'hc0400000; // -3.0 in IEEE 754 format
        #10;

        // Case 2: Divide by zero
        A = 32'h40400000; // 3.0
        B = 32'h00000000; // 0.0
        #10;

        // Case 3: Zero divided by non-zero
        A = 32'h00000000; // 0.0
        B = 32'h40000000; // 2.0
        #10;

        // Case 4: Infinity division
        A = 32'h7F800000; // Infinity
        B = 32'h40000000; // 2.0
        #10;

        // Finish simulation
        #10;
        $finish;
    end
endmodule
