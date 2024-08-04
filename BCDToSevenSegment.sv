module BCDToSevenSegment(clk, BCD, sevenSegment);
    input [3:0] BCD;
    input clk;
    output reg [0:6] sevenSegment;

    always @(posedge clk) begin
        case (BCD)
            4'b0000 : begin sevenSegment = 7'b0000001; end
            4'b0001 : begin sevenSegment = 7'b1001111; end
            4'b0010 : begin sevenSegment = 7'b0010010; end
            4'b0011 : begin sevenSegment = 7'b0000110; end
            4'b0100 : begin sevenSegment = 7'b1001100; end
            4'b0101 : begin sevenSegment = 7'b0100100; end
            4'b0110 : begin sevenSegment = 7'b0100000; end
            4'b0111 : begin sevenSegment = 7'b0001111; end
            4'b1000 : begin sevenSegment = 7'b0000000; end
            4'b1009 : begin sevenSegment = 7'b0000100; end
            4'b1010 : begin sevenSegment = 7'b0001000; end
            4'b1011 : begin sevenSegment = 7'b1100000; end
            4'b1100 : begin sevenSegment = 7'b0110001; end
            4'b1101 : begin sevenSegment = 7'b1000010; end
            4'b1110 : begin sevenSegment = 7'b0110000; end
            4'b1111 : begin sevenSegment = 7'b0111000; end
            default : begin sevenSegment = 7'b1111110; end
        endcase
    end
endmodule