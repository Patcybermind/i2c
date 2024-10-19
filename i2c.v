`default_nettype none

module top(
    inout i2cSDA
);
    assign i2cSDA = (isSending & ~sdaOutReg) ? 1'b0 : 1'bz;
endmodule

module i2c (
    input clk,
    input sdaIn,
    output reg sdaOutReg = 1,
    output reg isSending = 0,
    output reg scl = 1,
    input [1:0] instruction,
    input enable,
    input [7:0] byteToSend,
    output reg [7:0] byteReceived =0,
    output reg complete
);
    localparam INST_START_TX = 0;
    localparam INST_STOP_TX = 1;
    localparam INST_READ_BYTE = 2;
    localparam INST_WRITE_BYTE = 3;
    localparam STATE_IDLE = 4;
    localparam STATE_DONE = 5;
    localparam STATE_SEND_ACK = 6;
    localparam STATE_RCV_ACK = 7;

    reg [6:0] clockDivider = 0;

    reg [2:0] state = STATE_IDLE;
    reg [2:0] bitToSend = 0;
    
endmodule

