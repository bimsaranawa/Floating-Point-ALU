`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:50:12 10/11/2024
// Design Name:   FP_Mul_Div
// Module Name:   E:/ISE Projects/FP_ALU/tb_FP_Mul_Div.v
// Project Name:  FP_ALU
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: FP_Mul_Div
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb_FP_Mul();

    // Declare testbench variables
    reg [31:0] A; // First floating point input
    reg [31:0] B; // Second floating point input
    wire [31:0] C; // Output of multiplication

    // Instantiate the FP_Mul_Div module
    FP_Mul uut (
        .A(A),
        .B(B),
        .C(C)
    );

    initial begin
        // Initialize inputs and display format
        $display("A\t\tB\t\tC\t\tDescription");
        $display("--------------------------------------------------");
        
        // Test Case 1: Normal multiplication
        A = 32'h40200000; // 2.0 in floating point
        B = 32'h40800000; // 4.0 in floating point
        #10; // Wait for a time unit
        $display("%h\t%h\t%h\tNormal multiplication (2.0 * 4.0)", A, B, C);
        
        // Test Case 2: Multiplying by zero
        A = 32'h00000000; // 0.0 in floating point
        B = 32'h40800000; // 4.0 in floating point
        #10;
        $display("%h\t%h\t%h\tZero multiplication (0.0 * 4.0)", A, B, C);

        // Test Case 3: Multiplying NaN
        A = 32'h7FC00001; // NaN
        B = 32'h40800000; // 4.0 in floating point
        #10;
        $display("%h\t%h\t%h\tNaN multiplication (NaN * 4.0)", A, B, C);

        // Test Case 4: Infinity times a normal number
        A = 32'h7F800000; // +Infinity
        B = 32'h40800000; // 4.0 in floating point
        #10;
        $display("%h\t%h\t%h\tInfinity multiplication (+Inf * 4.0)", A, B, C);

        // Test Case 5: Normal number times Infinity
        A = 32'h40800000; // 4.0 in floating point
        B = 32'h7F800000; // +Infinity
        #10;
        $display("%h\t%h\t%h\tInfinity multiplication (4.0 * +Inf)", A, B, C);

        // Test Case 6: Negative Infinity
        A = 32'hFF800000; // -Infinity
        B = 32'h40800000; // 4.0 in floating point
        #10;
        $display("%h\t%h\t%h\tInfinity multiplication (-Inf * 4.0)", A, B, C);

        // Test Case 7: Normal number times negative Infinity
        A = 32'h40800000; // 4.0 in floating point
        B = 32'hFF800000; // -Infinity
        #10;
        $display("%h\t%h\t%h\tInfinity multiplication (4.0 * -Inf)", A, B, C);

        // Test Case 8: Multiplying two infinities
        A = 32'h7F800000; // +Infinity
        B = 32'h7F800000; // +Infinity
        #10;
        $display("%h\t%h\t%h\tInfinity multiplication (+Inf * +Inf)", A, B, C);

        // Test Case 9: Multiplying NaN with itself
        A = 32'h7FC00001; // NaN
        B = 32'h7FC00001; // NaN
        #10;
        $display("%h\t%h\t%h\tNaN multiplication (NaN * NaN)", A, B, C);

        // Test Case 10: Zero times infinity
        A = 32'h00000000; // 0.0 in floating point
        B = 32'h7F800000; // +Infinity
        #10;
        $display("%h\t%h\t%h\tZero multiplication (0.0 * +Inf)", A, B, C);

        // Test Case 11: Any two Numbers
        A = 32'h436aa666; // 234.65 in floating point
        B = 32'hbe5e353f; // -0.217 in floating point
        #10;
        $display("%h\t%h\t%h\tLarge number multiplication (Max * Max)", A, B, C);

        // Finish the simulation
        $finish;
    end
endmodule
