`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:26:13 10/12/2024 
// Design Name: 
// Module Name:    FP_Div 
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
module FP_Div (
    input wire [31:0] float_a,     // First floating-point number
    input wire [31:0] float_b,     // Second floating-point number
    output reg [31:0] result       // Result of the division
);

    // Intermediate signals
    wire [23:0] mant_a;
    wire [23:0] mant_b;
    reg [47:0] mant_div;            // Declare mant_div as reg for procedural assignment
    reg [7:0] exp_result;
    reg sign_result;

    // Extract fields from the input floating-point numbers
    wire sign_a = float_a[31];
    wire [7:0] exp_a = float_a[30:23];
    wire sign_b = float_b[31];
    wire [7:0] exp_b = float_b[30:23];

    assign mant_a = {1'b1, float_a[22:0]}; // Implicit leading 1 for normalized numbers
    assign mant_b = {1'b1, float_b[22:0]}; // Implicit leading 1 for normalized numbers

    // Perform the division operation
    always @* begin
        // Handle special cases
        if (float_a == 32'h7FC00000 || float_b == 32'h7FC00000) begin
            // If either input is NaN, result is NaN
            result = 32'h7FC00000; // Set result to NaN
        end else if (float_b == 32'h00000000) begin
            // Handle division by zero (set result to infinity)
            result = {sign_a ^ sign_b, 8'hFF, 23'h000000}; // Set result to +inf or -inf
        end else if (float_a == 32'h00000000) begin
            // If the numerator is zero, result is zero
            result = 32'h00000000; // Set result to 0
        end else if (exp_a == 8'hFF && exp_b == 8'hFF) begin
            // Handle special case: 0 / 0 = NaN
            result = 32'h7FC00000; // Set result to NaN
        end else if (exp_a == 8'hFF) begin
            // If numerator is NaN, return NaN
            result = 32'h7FC00000; // Set result to NaN
        end else if (exp_b == 8'hFF) begin
            // If denominator is NaN, return NaN
            result = 32'h7FC00000; // Set result to NaN
        end else begin
            // Normal division
            mant_div = (mant_a << 23) / mant_b; // Division of mant_a shifted left by 23 by mant_b
            
            // Calculate the exponent for the result
            exp_result = exp_a - exp_b + 127;   // Adjust exponent for bias
				
				// Determine the sign of the result
            sign_result = sign_a ^ sign_b; // XOR for sign of the result

            // Normalize the mantissa based on the lower part of mant_div
            if (mant_div[22:0] == 0) begin
                // If mant_div is zero, set result to zero
                result = 32'h00000000; // Set result to 0
            end else begin
                // Check if normalization is required
                if (mant_div[23]) begin
                    // If mant_div[23] is set, it's already normalized
                    // Simply take the lower part of mant_div
                    result = {sign_result, exp_result[7:0], mant_div[22:0]}; // Use lower part of mant_div
                end else begin
                    // If mant_div[23] is not set, we need to normalize
                    mant_div = mant_div << 1; // Shift left to normalize
                    exp_result = exp_result - 1; // Decrement exponent
                    result = {sign_result, exp_result[7:0], mant_div[22:0]}; // Update the result
                end
            end
        end
    end

endmodule
