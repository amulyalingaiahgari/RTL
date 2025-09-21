module ALU_8bit (
  input  [7:0] A,           // First operand
  input  [7:0] B,           // Second operand
  input  [3:0] ALU_Sel,     // Operation selector
  output reg [7:0] ALU_Out, // Result
  output Zero,              // Zero flag
  output reg Carryout       // Carry
);

    always @(*) begin
        case (ALU_Sel)
            4'b0000: {Carryout,ALU_Out} = A + B; // ADD
            4'b0001: {Carryout,ALU_Out} = A - B; // SUB
            4'b0010: ALU_Out = A & B;            // AND
            4'b0011: ALU_Out = A | B;            // OR
            4'b0100: ALU_Out = A ^ B;            // XOR
            4'b0101: ALU_Out = ~A ;              // NOT A
            4'b0110: ALU_Out = A << 1;           // Shift left A
            4'b0111: ALU_Out = A >> 1;           // Shift right A
            4'b1000: ALU_Out = A == B;           // Comapre equality
            4'b1001: ALU_Out = A > B;            // Compare greater
            4'b1010: ALU_OUt = A < B;            // Compare lesser
            default: ALU_Out = 8'b0;
        endcase
    end

    assign Zero = (ALU_Out == 8'b0) ? 1'b1 : 1'b0;
endmodule
