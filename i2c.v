`default_nettype none

module i2c(
 inout i2cSDA,
 output i2cSCL,
 input clk
);
    reg scl = 1;
    wire sclWire;
    assign sclWire = scl;

    wire sdaOutWire;
    reg sdaOutReg = 0;
    assign sdaOutWire = sdaOutReg;

    wire isSendingWire;
    reg isSending = 1;
    assign isSendingWire = isSending;

    assign i2cSDA = (isSendingWire & ~sdaOutWire) ? 1'b0 : 1'bz;
    assign i2cSCL = sclWire;


    reg [23:0] waitBeforeInitCounter = 24'h000000;
    localparam WAIT_BEFORE_INIT = 24'h66FF30; // started with 66 before BUT MUST CHANGE FOR SIMS
    // CHANGE TO 00FF30 FOR SIMS OR ELSE NOTHING SHOWS UP



    localparam INST_START_TX = 0;
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

    // send_data state machine
    localparam WAIT_FOR_START = 0;
    localparam SEND_INIT = 1;
    localparam SEND_DATA = 2;

    reg [3:0] SEND_DATA_STATE = WAIT_FOR_START;
    reg [1:0] readyToSendByte = 0;
    reg [3:0] sendInitInstructionKeeper = 0;
    reg [3:0] sendDataInstructionKeeper = 0;


    localparam BYTE_ARRAY_SEND_START = 0;
    localparam BYTE_ARRAY_SEND_BYTE = 1;
    localparam BYTE_ARRAY_STOP_TX = 2;

    // Timer for 20ms interval
    reg [19:0] testTimer  = 0;

    reg [7:0] byteToSend;
    reg [7:0] dataToSend;
    reg [2:0] state = STATE_IDLE;
    reg complete= 1; // CAREFULL AS THIS MIGHT NOT INITIALIZE TO 1 ON REAL FPGA

    reg [7:0] initCode [0:22]; // Declare an 8-bit wide, 23-element array

    initial begin
        initCode[0]  = 8'hAE;
        initCode[1]  = 8'hD5;
        initCode[2]  = 8'h80;
        initCode[3]  = 8'hA8;
        initCode[4]  = 8'h3F;
        initCode[5]  = 8'hD3;
        initCode[6]  = 8'h00;
        initCode[7]  = 8'h40;
        initCode[8]  = 8'h8D;
        initCode[9]  = 8'h14;
        initCode[10] = 8'h20;
        initCode[11] = 8'h00;
        initCode[12] = 8'hA0;
        initCode[13] = 8'hC0;
        initCode[14] = 8'h81;
        initCode[15] = 8'h7F;
        initCode[16] = 8'hD9;
        initCode[17] = 8'hF1;
        initCode[18] = 8'hDB;
        initCode[19] = 8'h40;
        initCode[20] = 8'hA4;
        initCode[21] = 8'hA6;
        initCode[22] = 8'hAF;
    end

    reg hasAddressBeenSent = 0;
    reg hasZeroBeenSent = 0;
    reg has40BeenSent = 0;
    reg hasDataBeenSent = 0;
    reg [7:0] initCodeIndex = 0;

    always @(posedge clk) begin
    case (state)
    	// states here
        STATE_IDLE: begin // 4
            //if (enable) begin
            complete <= 0; // was 0
            clockDivider <= 0;
            bitToSend <= 0;
            //state <= {1'b0,instruction};
            //end
        end
        

    
        INST_START_TX: begin // 0
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
        INST_STOP_TX: begin // 1
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
        /*INST_READ_BYTE: begin
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
        end*//*
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
        end*/
        INST_WRITE_BYTE: begin // 3
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
        STATE_RCV_ACK: begin // 7 // DEALT WITH BY WRITE BYTE
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
           //     sdaIn should be 0 but might as well not check // TODO: IMPLEMENT CHECKING
           // end 
        end
        STATE_DONE: begin // 5
            complete <= 1;
            //if (~enable)
            state <= STATE_IDLE;
        end
        default: begin
            state <= STATE_IDLE;
        end
    endcase

    case (SEND_DATA_STATE)
        WAIT_FOR_START: begin
            // just dont do anything
            sendInitInstructionKeeper <= 0;

        end
        SEND_INIT: begin
            // 0
            if (sendInitInstructionKeeper == BYTE_ARRAY_SEND_START && complete == 1) begin 

            // send start and reset values
            hasAddressBeenSent <= 0;
            hasZeroBeenSent <= 0;
            initCodeIndex <= 0;

            isSending <= 1;
            state <= INST_START_TX;
            sendInitInstructionKeeper <= BYTE_ARRAY_SEND_BYTE;

            // 1
            end else if (sendInitInstructionKeeper == BYTE_ARRAY_SEND_BYTE && complete == 1) begin
                            // SEND ADRESS THEN SEND 00 THE ITERATE OVER ARRAY BUT WAIT FOR ACK BEFORE EACH
            // send address
            if (hasAddressBeenSent == 0) begin
                byteToSend <= {OLED_ADDRESS, 1'b0}; // write
                hasAddressBeenSent <= 1;
                state <= INST_WRITE_BYTE;
            end else if (hasZeroBeenSent == 0) begin
                byteToSend <= {8'h00}; // write
                hasZeroBeenSent <= 1;
                state <= INST_WRITE_BYTE;
            end else if (initCodeIndex == 8'd23) begin // STOP TX MAKE SURE TO ADJUST TO ARRAY SIZE
                //sendInitInstructionKeeper <= BYTE_ARRAY_STOP_TX;
                state <= INST_STOP_TX;
                initCodeIndex <= 0;
                complete <= 0;
                sendInitInstructionKeeper <= BYTE_ARRAY_STOP_TX;
                hasAddressBeenSent <= 0;
                hasZeroBeenSent <= 0;
                SEND_DATA_STATE <= WAIT_FOR_START;
                
            end else begin
                byteToSend <= initCode[initCodeIndex];
                initCodeIndex <= initCodeIndex + 1;
                state <= INST_WRITE_BYTE;
            end
            


            sendInitInstructionKeeper <= BYTE_ARRAY_SEND_BYTE;

            // 2
            /*end else if (sendInitInstructionKeeper == BYTE_ARRAY_STOP_TX && complete == 1) begin // RECEIVING ACK DEALT WITH BY WRITE_BYTE

            // received ack
            
            state <= INST_STOP_TX; // STOP
            sendInitInstructionKeeper <= BYTE_ARRAY_SEND_START;
            SEND_DATA_STATE <= WAIT_FOR_START;

            

            end else if (complete == 1) begin

            SEND_DATA_STATE <= WAIT_FOR_START;
            sendInitInstructionKeeper <= BYTE_ARRAY_SEND_START;
            */
            end

        end
        SEND_DATA: begin // 2
            if (sendDataInstructionKeeper == BYTE_ARRAY_SEND_START && complete == 1) begin 

            // send start and reset values
            hasAddressBeenSent <= 0;
            has40BeenSent <= 0;
            hasDataBeenSent <= 0;

            isSending <= 1;
            state <= INST_START_TX;
            sendDataInstructionKeeper <= BYTE_ARRAY_SEND_BYTE;

            // 1
            end else if (sendDataInstructionKeeper == BYTE_ARRAY_SEND_BYTE && complete == 1) begin
                            // SEND ADRESS THEN SEND 00 THE ITERATE OVER ARRAY BUT WAIT FOR ACK BEFORE EACH
            // send address
            if (hasAddressBeenSent == 0) begin
                byteToSend <= {OLED_ADDRESS, 1'b0}; // write
                hasAddressBeenSent <= 1;
                state <= INST_WRITE_BYTE;
            end else if (has40BeenSent == 0) begin
                byteToSend <= {8'h40}; // 
                has40BeenSent <= 1;
                state <= INST_WRITE_BYTE;
            end else if (hasDataBeenSent == 0) begin // STOP TX MAKE SURE TO ADJUST TO ARRAY SIZE
                state <= INST_WRITE_BYTE;
                byteToSend <= dataToSend; // TODO: 
                hasDataBeenSent <= 1;
                
                
            end else if (has40BeenSent && hasAddressBeenSent && hasDataBeenSent) begin
                state <= INST_STOP_TX;
                
                complete <= 0;
                sendDataInstructionKeeper <= BYTE_ARRAY_STOP_TX;
                hasAddressBeenSent <= 0;
                has40BeenSent <= 0;
                hasDataBeenSent <= 0;
                SEND_DATA_STATE <= WAIT_FOR_START;
            end
            


            sendDataInstructionKeeper <= BYTE_ARRAY_SEND_BYTE;
            end
        end
        

        default: begin
            SEND_DATA_STATE <= WAIT_FOR_START;
        end
    endcase


    /*
    testTimer <= testTimer + 1;
    if (testTimer == 16'hFFFF) begin // 27MHz * 20ms = 540000
        testTimer <= 0;
        SEND_DATA_STATE <= SEND_DATA;
        complete <= 1;
        dataToSend <= 8'hAA;
    end 
    */

    
    if (waitBeforeInitCounter == WAIT_BEFORE_INIT) begin
        SEND_DATA_STATE <= SEND_INIT;
        complete <= 1;
        waitBeforeInitCounter <= waitBeforeInitCounter + 9; // we only want it to count down once
    end else if (waitBeforeInitCounter < WAIT_BEFORE_INIT) begin
        waitBeforeInitCounter <= waitBeforeInitCounter + 1;
    end else if (waitBeforeInitCounter > WAIT_BEFORE_INIT) begin // we can star the test send data routine

        testTimer <= testTimer + 1;
        if (testTimer == 16'hFFFF) begin // 27MHz * 20ms = 540000
            testTimer <= 0;
            SEND_DATA_STATE <= SEND_DATA;
            complete <= 1;
            dataToSend <= 8'hFF; // 8'hAA works well because its 10101010
        end

    end
    end
endmodule
