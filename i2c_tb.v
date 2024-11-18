module test();

reg clk = 0;

always
    #1  clk = ~clk;
    
initial begin
    #100000 $finish;
end
    

initial begin
    $dumpfile("i2c.vcd");
    //$dumpvars(0,test, i2cSDA, i2cSCL);
    $dumpvars(0,test);
end

wire [1:0] i2cInstruction;
wire [7:0] i2cByteToSend;
wire [7:0] i2cByteReceived;


wire i2cComplete;
wire i2cEnable;





//wire i2cScl;
wire sdaIn;
wire sdaOut;
wire isSending;
//assign i2cSda = (isSending & ~sdaOut) ? 1'b0 : 1'b1;
//assign sdaIn = i2cSda ? 1'b1 : 1'b0;

top i2c_inst (
    .i2cSDA(i2cSDA),
    .i2cSCL(i2cSCL),
    .clk(clk)
);

endmodule
/*i2c c(
    clk,
    sdaIn,
    sdaOut,
    isSending,
    i2cScl,
    i2cInstruction,
    i2cEnable,
    i2cByteToSend,
    i2cByteReceived,
    i2cComplete
);

reg [1:0] adcChannel = 0;
wire [15:0] adcOutputData;
wire adcDataReady;
reg adcEnable = 1;


endmodule*/