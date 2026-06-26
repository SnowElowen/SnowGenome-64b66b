`timescale 1ns/1ps

module ssg_reverse_complement #(
    parameter integer K = 15
)(
    input  wire [2*K-1:0] kmer_i,
    output wire [2*K-1:0] rc_kmer_o
);
    genvar i;
    generate
        for (i = 0; i < K; i = i + 1) begin : g_rc
            assign rc_kmer_o[(2*i)+:2] = ~kmer_i[(2*(K-1-i))+:2];
        end
    endgenerate
endmodule
