module buttonDebouncer(
    input logic clk, button,
    output logic buttonOut
);

    integer timer = 0;
    typedef enum logic [1:0] {idleState, debounceState, stallState} stateType;
    stateType [1:0] state = idleState;

    always_ff @(posedge clk) begin
        case (state)
            idleState: begin
                buttonOut <= 0;
                if(button) begin
                    state <= debounceState;
                end else if (!button) begin
                    state <= idleState;
                end
            end
            debounceState: begin
                timer <= timer+1;
                if(timer >= 20000)begin
                    timer <= 0;
                    buttonOut <= 1;
                    state <= stallState;
                end
            end
            stallState: begin
                buttonOut <= 0;
                if(button) begin
                    buttonOut <= 0;
                end else begin
                    state <= idleState;
                end
            end
        endcase
    end
endmodule