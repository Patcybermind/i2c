`default_nettype none

module top(
 inout i2cSDA,
 output i2cSCL
);
    wire sclWire;
    wire sdaOutWire;
    wire isSendingWire;
    assign i2cSDA = (isSendingWire & ~sdaOutWire) ? 1'b0 : 1'bz;
    assign i2cSCL = sclWire;

    
endmodule

module i2c (
    input clk,
    input sdaIn,
    output reg sdaOutReg = 1,
    output wire sdaOutWire,
    output reg isSending = 0,// WAS REG and issending and 0
    output isSendingWire,
    output reg scl = 1,
    output wire sclWire,
    input [1:0] instruction,
    input enable,
    input [7:0] byteToSend,
    output reg [7:0] byteReceived =0,
    output reg complete
    //output reg [2:0] state = STATE_IDLE
);
    assign isSendingWire = isSending;
    assign sdaOutWire = sdaOutReg;
    assign sclWire = scl;

    always @(posedge clk) begin
        scl <= 1;
        sdaOutReg <= 1;
    end
endmodule

/*    localparam INST_START_TX = 0;
    localparam INST_STOP_TX = 1;
    localparam INST_READ_BYTE = 2;
    localparam INST_WRITE_BYTE = 3;
    localparam STATE_IDLE = 4;
    localparam STATE_DONE = 5;
    localparam STATE_SEND_ACK = 6;
    localparam STATE_RCV_ACK = 7;

    reg [6:0] clockDivider = 0;

    
    reg [2:0] bitToSend = 0;

    localparam OLED_ADDRESS = 7'h3c; // dont forget to add add b0 at the end of byte for write

    
    localparam WAIT_FOR_START = 0;
    localparam SEND_BYTE_ARRAY = 1;

    reg [3:0] SEND_DATA_STATE = WAIT_FOR_START;
    reg [1:0] readyToSendByte = 0;
    reg [3:0] sendByteArrayInstructionKeeper = 0;

    localparam BYTE_ARRAY_SEND_START = 0;
    localparam BYTE_ARRAY_SEND_ADDRESS = 1;

    // Timer for 20ms interval
    reg [19:0] testTimer = 0;

    always @(posedge clk) begin
    case (state)
    	// states here
        STATE_IDLE: begin
            if (enable) begin
                complete <= 0;
                clockDivider <= 0;
                bitToSend <= 0;
                state <= {1'b0,instruction};
            end
        end
        

    
        INST_START_TX: begin
            isSending <= 1;
            clockDivider <= clockDivider + 1;
            if (clockDivider[6:5] == 2'b00) begin
                scl <= 1;
                sdaOutReg <= 1;
            end else if (clockDivider[6:5] == 2'b01) begin
                sdaOutReg <= 0;
            end else if (clockDivider[6:5] == 2'b10) begin
                scl <= 0;
            end else if (clockDivider[6:5] == 2'b11) begin
                state <= STATE_DONE;
            end
        end
        INST_STOP_TX: begin
            isSending <= 1;
            clockDivider <= clockDivider + 1;
            if (clockDivider[6:5] == 2'b00) begin
                scl <= 0;
                sdaOutReg <= 0;
            end else if (clockDivider[6:5] == 2'b01) begin
                scl <= 1;
            end else if (clockDivider[6:5] == 2'b10) begin
                sdaOutReg <= 1;
            end else if (clockDivider[6:5] == 2'b11) begin
                state <= STATE_DONE;
            end
        end
        INST_READ_BYTE: begin
            isSending <= 0;
            clockDivider <= clockDivider + 1;
            if (clockDivider[6:5] == 2'b00) begin
                scl <= 0;
            end else if (clockDivider[6:5] == 2'b01) begin
                scl <= 1;
            end else if (clockDivider == 7'b1000000) begin
                byteReceived <= {byteReceived[6:0], sdaIn ? 1'b1 : 1'b0};
            end else if (clockDivider == 7'b1111111) begin
                bitToSend <= bitToSend + 1;
                if (bitToSend == 3'b111) begin
                    state <= STATE_SEND_ACK;
                end
            end else if (clockDivider[6:5] == 2'b11) begin
                scl <= 0;
            end
        end
        STATE_SEND_ACK: begin
            isSending <= 1;
            sdaOutReg <= 0;
            clockDivider <= clockDivider + 1;
            if (clockDivider[6:5] == 2'b01) begin
                scl <= 1;
            end else if (clockDivider == 7'b1111111) begin
                state <= STATE_DONE;
            end else if (clockDivider[6:5] == 2'b11) begin
                scl <= 0;
            end
        end
        INST_WRITE_BYTE: begin
            isSending <= 1;
            clockDivider <= clockDivider + 1;
            sdaOutReg <= byteToSend[3'd7-bitToSend] ? 1'b1 : 1'b0;

            if (clockDivider[6:5] == 2'b00) begin
                scl <= 0;
            end else if (clockDivider[6:5] == 2'b01) begin
                scl <= 1;
            end else if (clockDivider == 7'b1111111) begin
                bitToSend <= bitToSend + 1;
                if (bitToSend == 3'b111) begin
                    state <= STATE_RCV_ACK;
                end
            end else if (clockDivider[6:5] == 2'b11) begin
                scl <= 0;
            end
        end
        STATE_RCV_ACK: begin
           isSending <= 0;
           clockDivider <= clockDivider + 1;
        
           if (clockDivider[6:5] == 2'b01) begin
               scl <= 1;
           end else if (clockDivider == 7'b1111111) begin
               state <= STATE_DONE;
           end else if (clockDivider[6:5] == 2'b11) begin
               scl <= 0;
           end
           // else if (clockDivider == 7'b1000000) begin
           //     sdaIn should be 0 but might as well not check
           // end 
        end
        STATE_DONE: begin
            complete <= 1;
            if (~enable)
                state <= STATE_IDLE;
        end
        default: begin
            state <= STATE_IDLE;
        end


    endcase

    case (SEND_DATA_STATE)
        WAIT_FOR_START: begin
            // just dont do anything
            sendByteArrayInstructionKeeper <= 0;

        end
        SEND_BYTE_ARRAY: begin
            
            if (sendByteArrayInstructionKeeper == BYTE_ARRAY_SEND_START && complete == 1) begin 
                // send start
                isSending <= 1;
                state <= INST_START_TX;
                sendByteArrayInstructionKeeper <= BYTE_ARRAY_SEND_ADDRESS;
            end else if (sendByteArrayInstructionKeeper == BYTE_ARRAY_SEND_ADDRESS && complete == 1) begin
                // send address
                state <= INST_WRITE_BYTE;
                byteToSend <= {OLED_ADDRESS, 1'b0}; // write
                //sendByteArrayInstructionKeeper <= ;
            end

        end

        default: begin
            SEND_DATA_STATE <= WAIT_FOR_START;
        end
    endcase


    
    
    if (testTimer == 20'd540000) begin // 27MHz * 20ms = 540000
        testTimer <= 0;
        SEND_DATA_STATE <= SEND_BYTE_ARRAY;
    end else begin
        testTimer <= testTimer + 1;
    end
    
    end
    


endmodule
*/

