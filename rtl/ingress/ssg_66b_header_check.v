`timescale 1ns/1ps

module ssg_66b_header_check (
    input  wire [1:0] header_i,
    output wire       header_legal_o
);
    assign header_legal_o = (header_i == 2'b01) | (header_i == 2'b10);
endmodule
