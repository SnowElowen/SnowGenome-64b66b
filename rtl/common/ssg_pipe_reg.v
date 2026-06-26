`timescale 1ns/1ps

module ssg_pipe_reg #(
    parameter integer W = 1
)(
    input  wire         clk_i,
    input  wire         rst_i,
    input  wire [W-1:0] d_i,
    input  wire         valid_i,
    output reg  [W-1:0] q_o,
    output reg          valid_o
);
    always @(posedge clk_i) begin
        if (rst_i) begin
            q_o     <= {W{1'b0}};
            valid_o <= 1'b0;
        end else begin
            q_o     <= d_i;
            valid_o <= valid_i;
        end
    end
endmodule
