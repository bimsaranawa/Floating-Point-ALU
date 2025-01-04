module tb_FP_Add_Sub;
    reg [31:0] A;  // Input A
    reg [31:0] B;  // Input B
	 reg add_sub;	 // Add or Sub
    wire [31:0] result; // Output result

    // Instantiate the floating point adder module
    FP_Add_Sub uut (
        .A(A),
        .B(B),
		  .add_sub(add_sub),
        .result(result)
    );

    initial begin
        // Test cases
        A = 32'h42295554; // 42.33333 in IEEE 754
        B = 32'hc0a825af; // -5.2546 in IEEE 754
		  add_sub = 1;
        #10;
        
        $display("A: %h, B: %h, Result: %h", A, B, result);

        A = 32'hc1fb3333; // -31.4 in IEEE 754
        B = 32'hff800000; // -infinity in IEEE 754
		  add_sub = 1;
        #10;

        $display("A: %h, B: %h, Result: %h", A, B, result);

        A = 32'h3f800000; // 1.0 in IEEE 754
        B = 32'hbf800000; // -1.0 in IEEE 754
		  add_sub = 0;
        #10;

        $display("A: %h, B: %h, Result: %h", A, B, result);

        $finish;
    end
endmodule
