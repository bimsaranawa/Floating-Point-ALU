`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:01:47 10/21/2024 
// Design Name: 
// Module Name:    fp_alu 
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
module fp_alu (
    input  [31:0] a,        // Input operand a
    input  [31:0] b,        // Input operand b
    input  [1:0]  opcode,   // 2-bit opcode to select operation (00 = Add/Sub, 01 = Mul, 10 = Div)
    input         add_sub,  // 1-bit to decide Add (0) or Sub (1) when opcode is 00
    output [31:0] result    // 32-bit result
);

// Wires for the outputs of the individual modules
wire [31:0] add_sub_result;
wire [31:0] mul_result;
wire [31:0] div_result;

// Instantiate the FP_Add_Sub module
FP_Add_Sub add_sub_inst (
    .A(a),
    .B(b),
    .add_sub(add_sub),
    .result(add_sub_result)
);

// Instantiate the FP_Mul module
FP_Mul mul_inst (
    .A(a),
    .B(b),
    .C(mul_result)
);

// Instantiate the FP_Div module
FP_Div div_inst (
    .float_a(a),
    .float_b(b),
    .result(div_result)
);

// Output logic based on opcode
assign result = (opcode == 2'b00) ? add_sub_result :
                (opcode == 2'b01) ? mul_result :
                (opcode == 2'b10) ? div_result : 32'b0;

endmodule

