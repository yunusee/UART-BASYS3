module RXBUF
#(parameter DATA_BIT = 8, ITEM_COUNT = 4)
(
    input logic clk,
    input logic [15:0] clkdiv,
    input logic rx,
    output logic [7:0] led,
    output logic done,
    output logic [ITEM_COUNT-1: 0][DATA_BIT+2: 0] receiveMemory
);

    typedef enum logic [1:0] { idleState, receiveState, processState} stateType;
    stateType state = idleState;
    logic [DATA_BIT + 2:0] rxBuffer;
    logic [3:0] bitcntr;
    logic [15:0] cntr;
    logic [1:0] receivecntr;
    integer limit = 1;

    initial begin
        for (int i = 0; i < 4; i++) begin
            receiveMemory[i] = 11'b00000000000;
        end
        done = 0;
        led = 8'b00000000;
    end

    always_ff @(posedge clk) begin
        case (state)
            idleState: begin
                done <= 1'b0;
                if (!rx) begin
                    cntr <= cntr + 1;
                    if (cntr == clkdiv[15:1]) begin
                        receiveMemory[3:1] <= receiveMemory[2:0];
                        bitcntr <= 0;
                        cntr <= 0;
                        receivecntr <= 0;
                        state <= receiveState;
                    end
                end
            end
            receiveState: begin
                cntr <= cntr + 1;
                if (cntr == clkdiv) begin
                    cntr <= 0;
                    bitcntr <= bitcntr + 1;
                    receiveMemory[0] <= {rx, receiveMemory[0][DATA_BIT+2:1]};
                end
                if (bitcntr == DATA_BIT+2) begin
                    led <= receiveMemory[0][7:0];
                    done <= 1'b1;
                    state <= processState;
                end
            end
            processState: begin
                if (~(receiveMemory[0][1]^receiveMemory[0][2]^receiveMemory[0][3]^receiveMemory[0][4]^receiveMemory[0][5]^receiveMemory[0][6]^receiveMemory[0][7]^receiveMemory[0][8]^receiveMemory[0][9])) begin
                    receiveMemory[0] <= 10'b0000000000;
                end
                led <= receiveMemory[0][8:1];
                state <= idleState;
            end
        endcase
    end
endmodule