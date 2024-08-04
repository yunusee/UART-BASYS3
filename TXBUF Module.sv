module TXBUF
#(parameter DATA_BIT = 8, ITEM_COUNT = 4)
(
    input logic clk,
    input logic [15:0] clkdiv,
    input logic [DATA_BIT-1:0] dataBits,
    input logic loadEnable,
    input logic transmitEnable,
    input logic autoTransfer,
    output logic done,
    output logic tx,
    output logic [DATA_BIT-1:0] led,
    output logic [ITEM_COUNT-1: 0][DATA_BIT+2: 0] loadMemory
);

    typedef enum logic [2:0] { idleState, loadState, transmitState, loadWaitState, transmitWaitState, autoState } stateType;
    stateType state = idleState;
    logic [15:0] cntr;
    logic [3:0] bitcntr;
    logic [1:0] ind;
    logic [DATA_BIT+2:0] txBuffer;
    logic parityBit;
    logic startBit;
    logic stopBit;
    integer limit = 1;
    assign startBit = 1'b0;
    assign stopBit = 1'b1;

    initial begin
        for (int i = 0; i < 4; i++) begin
            loadMemory[i] = 11'b00000000000;
        end
    end

    always_ff @(posedge clk) begin
        case (state)
            idleState: begin
                tx <= 1'b1;
                done <= 1'b0;
                if (loadEnable) begin
                    state <= loadState;
                end else if (transmitEnable) begin
                    cntr <= 0;
                    bitcntr <= 0;
                    if (autoTransfer) ind <= 0;
                    else ind <= 3;
                    state <= transmitState;
                end
            end
            loadState: begin
                parityBit <= (dataBits[0] ^ dataBits[1] ^ dataBits[2] ^ dataBits[3] ^ dataBits[4] ^ dataBits[5] ^ dataBits[6] ^ dataBits[7]);
                loadMemory[3] <= loadMemory[2];
                loadMemory[2] <= loadMemory[1];
                loadMemory[1] <= loadMemory[0];
                loadMemory[0] <= {stopBit, parityBit, dataBits, startBit};
                led <= dataBits;
                state <= loadWaitState;
            end
            loadWaitState: begin
                if (!loadEnable) begin
                    state <= idleState;
                end
            end
            transmitState: begin
                tx <= loadMemory[ind][bitcntr];
                cntr <= cntr + 1;
                if (cntr == clkdiv) begin
                    cntr <= 0;
                    bitcntr <= bitcntr + 1;
                    if (bitcntr == DATA_BIT + 2) begin
                        bitcntr <= 0;
                        done <= 1'b1;
                        if (ind == 3) state <= transmitWaitState;
                        else state <= autoState;
                    end
                end
            end
            transmitWaitState: begin
                if (!transmitEnable) begin
                    state <= idleState;
                end
            end
            autoState: begin
                ind <= ind + 1;
                state <= transmitState;
            end
        endcase
    end
endmodule