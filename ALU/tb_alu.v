module tb_ALU_8bit;
    // Inputs
    reg [7:0] A;
    reg [7:0] B;
    reg [3:0] ALU_Sel;
    // Outputs
    wire [7:0] ALU_Out;
    wire Zero;
    wire Carryout;

    // Instantiate the ALU
    ALU_8bit uut (
        .A(A),
        .B(B),
        .ALU_Sel(ALU_Sel),
        .ALU_Out(ALU_Out),
        .Zero(Zero),
        .Carryout(Carryout)
    );

    // Test sequence
    initial begin
        $display("Time\tA\tB\tALU_Sel\tCarry\tALU_Out\tZero");
        $monitor("%0dns\t%h\t%h\t%b\t%b\t%h\t%b", $time, A, B, ALU_Sel, Carryout, ALU_Out, Zero);

        A = 8'h0A; B = 8'h05;
        // Test ADD
        ALU_Sel = 4'b0000; 
        // Test SUB
        #10 ALU_Sel = 4'b0001; 
        // Test AND
        #10 ALU_Sel = 4'b0010; 
        // Test OR
        #10 ALU_Sel = 4'b0011; 
        // Test XOR
        #10 ALU_Sel = 4'b0100;
        // Test NOT
        #10 ALU_Sel = 4'b0101; 
        // Test Shift left
        #10 ALU_Sel = 4'b0110;
        // Test Shift right
        #10 ALU_Sel = 4'b0111; 
        // Test compare equality
        #10 ALU_Sel = 4'b1000; 
        // Test compare greater
        #10 ALU_Sel = 4'b1001; 
        // Test compare lesser
        #10 ALU_Sel = 4'b1010; 
        // Test Zero output
        #10 A = 8'b0; B = 8'b0; ALU_Sel = 4'b0000;
      
       #10  $finish;
    end
endmodule
