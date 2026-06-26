`timescale 1ns/1ps

module ssg_reset_sync_3ff (
    input  wire clk_i,
    input  wire async_reset_i,
    output wire sync_reset_o
);
    (* ASYNC_REG = "TRUE" *) reg [2:0] sync_r = 3'b111;

    always @(posedge clk_i or posedge async_reset_i) begin
        if (async_reset_i) begin
            sync_r <= 3'b111;
        end else begin
            sync_r <= {sync_r[1:0], 1'b0};
        end
    end

    assign sync_reset_o = sync_r[2];
endmodule
