module FP_Add_Sub (
    input [31:0] A,   // First floating point number
    input [31:0] B,   // Second floating point number
	 input add_sub,	 // Add or Sub
    output reg [31:0] result // Sum of A and B
);
    // Splitting the fields for A
    wire sign_A = A[31];
    wire [7:0] exponent_A = A[30:23];
    wire [23:0] mantissa_A = {1'b1, A[22:0]}; // Implied leading 1

    // Splitting the fields for B
    wire sign_B = (add_sub == 0) ? B[31] : ~B[31];
    wire [7:0] exponent_B = B[30:23];
    wire [23:0] mantissa_B = {1'b1, B[22:0]}; // Implied leading 1

    // Compare exponents and align mantissas
    wire [7:0] exponent_diff;
    wire [23:0] mantissa_A_shifted;
    wire [23:0] mantissa_B_shifted;
    wire [7:0] final_exponent;

    assign exponent_diff = (exponent_A > exponent_B) ? (exponent_A - exponent_B) : (exponent_B - exponent_A);
    assign mantissa_A_shifted = (exponent_A > exponent_B) ? mantissa_A : (mantissa_A >> exponent_diff);
    assign mantissa_B_shifted = (exponent_B > exponent_A) ? mantissa_B : (mantissa_B >> exponent_diff);
    assign final_exponent = (exponent_A > exponent_B) ? exponent_A : exponent_B;

	 // Perform addition or subtraction based on signs
	 wire [24:0] mantissa_sum;
	 assign mantissa_sum = (sign_A == sign_B) ? (mantissa_A_shifted + mantissa_B_shifted) : (mantissa_A_shifted - mantissa_B_shifted);

    // Variables for normalization
    reg [23:0] normalized_mantissa;
    reg [7:0] normalized_exponent;
    reg result_sign;

    // Procedural block for normalization and assembling the result
    always @* begin
		 // Handle Infinity cases
		 if (A[30:23] == 8'hFF && A[22:0] == 0) begin
			  // A is infinity
			  if (B[30:23] == 8'hFF && B[22:0] == 0) begin
					// Both A and B are infinity
					if (sign_A == sign_B) begin
						 // Infinity + Infinity or -Infinity + -Infinity
						 result = {sign_A, 8'hFF, 23'b0};  // Return the same infinity
					end else begin
						 // Infinity - Infinity (or -Infinity + Infinity)
						 result = 32'h7FC00000;  // NaN (Not a Number)
					end
			  end else begin
					// A is infinity, B is finite
					result = {sign_A, 8'hFF, 23'b0};  // Return A (infinity)
			  end
		 end else if (B[30:23] == 8'hFF && B[22:0] == 0) begin
			  // B is infinity, A is finite
			  result = {sign_B, 8'hFF, 23'b0};  // Return B (infinity)
		 end else begin
			  // Normal addition/subtraction
			  if (mantissa_sum == 0) begin
					// Handle zero case
					normalized_mantissa = 0;
					normalized_exponent = 0;
					result_sign = 0;  // Zero is positive
			  end else if (mantissa_sum[24]) begin
					normalized_mantissa = mantissa_sum[24:1];  // Right shift
					normalized_exponent = final_exponent + 1;
			  end else if (mantissa_sum[23] == 0) begin
					normalized_mantissa[23:1] = mantissa_sum[22:0];  // Left shift
					normalized_mantissa[0] = 0;
					normalized_exponent = final_exponent - 1;	 
			  end else begin
					normalized_mantissa = mantissa_sum[23:0];
					normalized_exponent = final_exponent;
			  end

			  // Determine the result sign
			  result_sign = (mantissa_sum == 0) ? 0 : sign_A;

			  // Assemble the final result
			  result = {result_sign, normalized_exponent, normalized_mantissa[22:0]};  // [Sign | Exponent | Mantissa]
		 end
	end
endmodule
