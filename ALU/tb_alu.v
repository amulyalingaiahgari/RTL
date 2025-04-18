module tb_ALU_8bit;
    // Inputs
    reg [7:0] A;
    reg [7:0] B;
    reg [2:0] ALU_Sel;
    // Outputs
    wire [7:0] ALU_Out;
    wire Zero;

    // Instantiate the ALU
    ALU_8bit uut (
        .A(A),
        .B(B),
        .ALU_Sel(ALU_Sel),
        .ALU_Out(ALU_Out),
        .Zero(Zero)
    );

    // Test sequence
    initial begin
        $display("Time\tA\tB\tSel\tOut\tZero");
        $monitor("%0dns\t%h\t%h\t%b\t%h\t%b", $time, A, B, ALU_Sel, ALU_Out, Zero);

        A = 8'h0A; B = 8'h05;
        // Test ADD
        ALU_Sel = 3'b000; 
        // Test SUB
        #10 ALU_Sel = 3'b001; 
        // Test AND
        #10 ALU_Sel = 3'b010; 
        // Test OR
        #10 ALU_Sel = 3'b011; 
        // Test XOR
        #10 ALU_Sel = 3'b100;
        // Test Shift Left
        #10 ALU_Sel = 3'b101; 
        // Test Shift Right
        #10 ALU_Sel = 3'b110;
        // Test Pass-through
        #10 ALU_Sel = 3'b111; 
        // Test Zero output
        #10 A = 8'h00; B = 8'h00; ALU_Sel = 3'b000;
      
       #10  $finish;
    end
endmodule
