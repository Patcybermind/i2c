/*`default_nettype none

module controller #(
    parameter address = 7'd0
) (
    input clk,
    input [1:0] channel,
    output reg [15:0] outputData = 0,
    output reg dataReady = 1,
    input enable,
    output reg [1:0] instructionI2C = 0,
    output reg enableI2C = 0,
    output reg [7:0] byteToSendI2C = 0,
    input [7:0] byteReceivedI2C,
    input completeI2C
    
);
// setup config
i2c i2c_inst (
    .state(state)
);

localparam CONFIG_REGISTER = 8'b00000001;
localparam CONVERSION_REGISTER = 8'b00000000;

localparam TASK_SETUP = 0;
localparam TASK_CHECK_DONE = 1;
localparam TASK_CHANGE_REG = 2;
localparam TASK_READ_VALUE = 3;

localparam INST_START_TX = 0;
localparam INST_STOP_TX = 1;
localparam INST_READ_BYTE = 2;
localparam INST_WRITE_BYTE = 3;




reg [1:0] taskIndex = 0;
reg [2:0] subTaskIndex = 0;
reg [4:0] state = STATE_IDLE;
reg [7:0] counter = 0;
reg processStarted = 0;

reg [7:0] initCode[0:22];
integer i;

initial begin
initCode[0]= 8'hAE;
initCode[1]= 8'hD5;
initCode[2]= 8'h80;
initCode[3]= 8'hA8;
initCode[4]= 8'h3F;
initCode[5]= 8'hD3;
initCode[6]= 8'h00;
initCode[7]= 8'h40;
initCode[8]= 8'h8D;
initCode[9]= 8'h14;
initCode[10]= 8'h20;
initCode[11]= 8'h00;
initCode[12]= 8'hA0;
initCode[13]= 8'hC0;
initCode[14]= 8'h81;
initCode[15]= 8'h7F;
initCode[16]= 8'hD9;
initCode[17]= 8'hF1;
initCode[18]= 8'hDB;
initCode[19]= 8'h40;
initCode[20]= 8'hA4;
initCode[21]= 8'hA6;
initCode[22]= 8'hAF;
end

// REMEMBER TO ADD 0x00 AFTER THE FIRST ADRESS TRANSMISSION FOR COMMAND MODE

localparam DELAY_COUNT = 27_000_000; // 27 MHz clock, 1 second delay

reg [24:0] delayCounter = DELAY_COUNT;


always @(posedge clk) begin
    if (delayCounter > 0) begin
        delayCounter <= delayCounter - 1;
    end else begin
        delayCounter <= DELAY_COUNT; // it will restart EVERY second
        instructionState <= STATE_RUN_TASK;

    end
end



// State encoding
localparam CONTROLLER_WAIT = 4'd0;
localparam SEND_BYTE = 4'd1;
localparam STATE_1 = 4'd2;
localparam STATE_2 = 4'd3;
localparam STATE_3 = 4'd4;
localparam STATE_4 = 4'd5;
localparam STATE_5 = 4'd6;
localparam STATE_6 = 4'd7;
localparam STATE_7 = 4'd8;


reg [3:0] controllerState = 'd0;

always @(posedge clk) begin
case(controllerState)
    CONTROLLER_WAIT: begin        
    end





endcase

end

endmodule
*/