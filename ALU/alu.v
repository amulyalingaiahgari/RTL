module ALU_8bit (
  input  [7:0] A,           // First operand
  input  [7:0] B,           // Second operand
  input  [2:0] ALU_Sel,     // Operation selector
  output reg [7:0] ALU_Out, // Result
  output Zero               // Zero flag
);

    always @(*) begin
        case (ALU_Sel)
            3'b000: ALU_Out = A + B;          // ADD
            3'b001: ALU_Out = A - B;          // SUB
            3'b010: ALU_Out = A & B;          // AND
            3'b011: ALU_Out = A | B;          // OR
            3'b100: ALU_Out = A ^ B;          // XOR
            3'b101: ALU_Out = A << 1;         // Shift Left A
            3'b110: ALU_Out = A >> 1;         // Shift Right A
            3'b111: ALU_Out = A;              // Pass-through A
            default: ALU_Out = 8'b00000000;
        endcase
    end

    assign Zero = (ALU_Out == 8'b00000000) ? 1'b1 : 1'b0;
endmodule
