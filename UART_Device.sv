module UART_Device
#(parameter
    DATA_BIT = 8,
    BAUD_RATE = 115200,
    CLK_FREQ = 100000000,
    ITEM_COUNT = 4)
(
    input logic clk,
    input logic btnC,
    input logic btnD,
    input logic btnU,
    input logic btnL,
    input logic btnR,
    input logic rx,
    input logic [15:0] sw,
    output logic tx,
    output logic [15: 0] led,
    output logic [0:6] seg,
    output logic [3:0] an
);

    typedef enum logic [1:0] { transmitState, receiveState } stateType;
    stateType state = transmitState;
    logic [ITEM_COUNT-1:0][DATA_BIT+2:0] loadMemory;
    logic [ITEM_COUNT-1:0][DATA_BIT+2:0] receiveMemory;
    logic [15:0] clkdiv = CLK_FREQ / BAUD_RATE;
    logic transmitDone;
    logic receiveDone;
    logic currentBit;
    logic transmit;
    logic load;
    logic changeDisplay;
    logic prevData;
    logic nextData;
    logic [3:0] index = 4'b0000;
    logic [7:0] currentData;
    reg [1:0] activeDigit = 0;
    integer refreshCounter = 0;
    logic [0:6] seg0, seg1, seg2, seg3;

    buttonDebouncer transmitDebouncer(clk, btnC, transmit);
    buttonDebouncer loadDebouncer(clk, btnD, load);
    buttonDebouncer changeDisplayDebouncer(clk, btnU, changeDisplay);
    buttonDebouncer prevPageDebouncer(clk, btnL, prevPage);
    buttonDebouncer nextPageDebouncer(clk, btnR, nextPage);

    BCDToSevenSegment d0(clk, currentData[3:0], seg0);
    BCDToSevenSegment d1(clk, currentData[7:4], seg1);
    BCDToSevenSegment d2(clk, index, seg2);

    TXBUF (clk, clkdiv, sw[DATA_BIT-1:0], load, transmit, sw[15], transmitDone, tx, led[DATA_BIT-1:0], loadMemory);
    RXBUF (clk, clkdiv, rx, led[15: 15-DATA_BIT+1], receiveDone, receiveMemory);

    always @(posedge clk) begin
        refreshCounter <= refreshCounter + 1;
        if (refreshCounter == 250000) begin
            refreshCounter <= 0;
            activeDigit <= activeDigit + 1;
            if (activeDigit == 3) activeDigit <= 0;
        end
    end

    always @(posedge clk) begin
        case (state)
            transmitState: begin
                seg3 <= 7'b1110000;
                currentData <= loadMemory[index][8:1];
                if (changeDisplay) state <= receiveState;
            end
            receiveState: begin
                seg3 <= 7'b1111010;
                currentData <= receiveMemory[index][8:1];
                if (changeDisplay) state <= transmitState;
            end
        endcase

        if (prevPage) begin
            if (index == 0) begin
                index = ITEM_COUNT - 1;
            end else begin
                index <= index - 1;
            end
        end

        if (nextPage) begin
            if (index == 3) begin
                index = 0;
            end else begin
                index <= index + 1;
            end
        end
    end

    always @(posedge clk) begin
        case (activeDigit)
            2'b00: begin
                seg <= seg0;
                an <= 4'b1110;
            end
            2'b01: begin
                seg <= seg1;
                an <= 4'b1101;
            end
            2'b10: begin
                seg <= seg2;
                an <= 4'b1011;
            end
            2'b11: begin
                seg <= seg3;
                an <= 4'b0111;
            end
        endcase
    end
endmodule