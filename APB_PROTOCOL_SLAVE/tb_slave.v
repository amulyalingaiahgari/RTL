module tb_apb_slave;
  // Testbench signal declarations
  reg         presetn;
  reg         pclk;
  reg         psel;
  reg         penable;
  reg         pwrite;
  reg  [31:0] paddr;
  reg  [31:0] pwdata;
  wire [31:0] prdata;
  wire        pready;
  wire        pslverr;

  // DUT instantiation
  apb_slave dut(.presetn(presetn), .pclk(pclk), .psel(psel), .penable(penable), .pwrite(pwrite), .paddr(paddr), .pwdata(pwdata), .prdata(prdata), .pready(pready), .pslverr(pslverr));

  // Clock generation (100MHz)
  initial begin
    pclk = 0;
    forever #5 pclk = ~pclk;
  end

  // Stimulus logic
  initial begin
    // Reset
    presetn = 0;
    psel    = 0;
    penable = 0;
    pwrite  = 0;
    paddr    = 0;
    pwdata  = 0;

    #20 presetn = 1;

    // Write Transaction
    #10 psel = 1;
        penable = 0;
        pwrite  = 1;
        paddr   = 32'h5;
        pwdata  = 32'h9;

    #10 penable = 1; //enable phase

    #10 psel = 0;
         penable = 0;

    // Read Transaction
    #10 psel     = 1;
         penable = 0;
         pwrite  = 0;
         paddr   = 32'h5;

    #10 penable = 1;

    #10 psel = 0;
         penable = 0;


//write to out-of-range address//invalid write transcation to addr 58
    #10 psel=1;
        penable=0;
        pwrite=1;
        paddr=58; //invalid
        pwdata=6;

    #10 penable=1;

    #10 psel=0;
        penable=0;
    #20;

//invalid read transaction from address 33
    #10 psel=1;
        penable=0;
        pwrite=0;
        paddr=58; //invalid

    #10 penable=1;

    #10 psel=0;
        penable=0;
    
    #50 $finish;
  end
  
  // Monitor signal activity
  initial begin
    $monitor("T=%0t | pwrite=%b | paddr=%h | pwdata=%h | prdata=%h | psel=%b | penable=%b | pready=%b | pslverr=%b", $time, pwrite, paddr, pwdata, prdata, psel, penable, pready, pslverr);
  end

endmodule
