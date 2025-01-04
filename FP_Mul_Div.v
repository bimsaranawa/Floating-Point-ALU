`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:43:23 10/11/2024 
// Design Name: 
// Module Name:    FP_Mul_Div 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module FP_Mul(
    input [31:0] A,   // Input A
    input [31:0] B,   // Input B
    output reg [31:0] C // Output C
);

    reg [7:0] expA;
    reg [7:0] expB;
    reg [8:0] exp_sum;
    reg [23:0] mantA; 
    reg [23:0] mantB;
    reg [47:0] mantC;

    always @(*) begin
        // Initialize output
        C = 32'b0;

        // Extract exponent and mantissa parts from A and B
        expA = A[30:23]; // Exponent from A (bits [30:23])
        expB = B[30:23]; // Exponent from B (bits [30:23])

        // Check for NaN inputs
        if ((expA == 8'hFF && A[22:0] != 23'b0) || (expB == 8'hFF && B[22:0] != 23'b0)) begin
            // If either A or B is NaN, set C to NaN
            C[30:23] = 8'hFF; // Set exponent to all 1's
            C[22:0] = 23'b1;  // Set fraction to non-zero for NaN
            C[31] = A[31] ^ B[31]; // Set sign bit
        end
        // Check for zero inputs
        else if (A == 32'b0 || B == 32'b0) begin
            // If either A or B is zero, set C to zero
            C = 32'b0;
        end
        // Check for infinity cases
        else if (expA == 8'hFF || expB == 8'hFF) begin
            // If either input is infinity
            if (A[22:0] == 23'b0 && B[22:0] == 23'b0) begin
                // Both are infinity, result is also infinity
                C[30:23] = 8'hFF; // Set exponent to all 1's
                C[22:0] = 23'b0;  // Set fraction to zero
                C[31] = A[31] ^ B[31]; // Set sign bit based on A and B
            end else if (A[22:0] == 23'b0) begin
                // A is zero, B is infinity
                C[30:23] = 8'hFF; // Result is infinity
                C[22:0] = 23'b0;  // Set fraction to zero
                C[31] = B[31];    // Set sign bit based on B
            end else if (B[22:0] == 23'b0) begin
                // B is zero, A is infinity
                C[30:23] = 8'hFF; // Result is infinity
                C[22:0] = 23'b0;  // Set fraction to zero
                C[31] = A[31];    // Set sign bit based on A
            end else begin
                // One of them is infinity, the other is a normal number
                C[30:23] = 8'hFF; // Result is infinity
                C[22:0] = 23'b0;  // Set fraction to zero
                C[31] = A[31] ^ B[31]; // Set sign bit
            end
        end
        else begin
            // Add implicit leading 1 for normalized numbers
            mantA = {1'b1, A[22:0]}; // Mantissa of A
            mantB = {1'b1, B[22:0]}; // Mantissa of B

            // Multiply mantissas
            mantC = mantA * mantB;

            // Add exponents (subtract bias)
            exp_sum = expA + expB - 8'd127; // 127 is the bias for single-precision

            // Handle overflow of mantissa if needed
            if (mantC[47] == 1'b1) begin
                // If there is an overflow in mantC
                C[22:0] = mantC[46:24]; // Assign mantissa
                exp_sum = exp_sum + 1'b1; // Increase exponent
            end else begin
                C[22:0] = mantC[45:23]; // Normal mantissa assignment
            end

            // Normalize the exponent and check for underflow or overflow
            if (exp_sum[8] == 1'b1) begin
                // If exp_sum is too large, set to infinity
                C[30:23] = 8'hFF; // Result is infinity
                C[22:0] = 23'b0;  // Set fraction to zero
                C[31] = A[31] ^ B[31]; // Sign bit
            end else if (exp_sum < 8'd0) begin
                // Underflow (if exp_sum is negative, we should handle denormals)
                C[30:23] = 8'b0; // Result is denormalized (zero exponent)
                C[22:0] = mantC[45:23]; // Assign mantissa (adjust if necessary)
            end else begin
                // Normal case
                C[30:23] = exp_sum[7:0]; // Assign calculated exponent
                C[31] = A[31] ^ B[31]; // Sign bit
            end
        end
    end  
endmodule
