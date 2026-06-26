`timescale 1ns/1ps

module ssg_canonical_kmer #(
    parameter integer K = 15
)(
    input  wire              clk_i,
    input  wire              rst_i,

    input  wire              kmer_valid_i,
    input  wire [2*K-1:0]    kmer_i,
    input  wire [31:0]       kmer_pos_i,

    output reg               canonical_valid_o,
    output reg  [2*K-1:0]    canonical_kmer_o,
    output reg  [2*K-1:0]    forward_kmer_o,
    output reg  [2*K-1:0]    rc_kmer_o,
    output reg  [31:0]       canonical_pos_o
);
    wire [2*K-1:0] rc_w;
    wire           take_forward_w;

    ssg_reverse_complement #(
        .K(K)
    ) u_reverse_complement (
        .kmer_i    (kmer_i),
        .rc_kmer_o (rc_w)
    );

    assign take_forward_w = (kmer_i <= rc_w);

    always @(posedge clk_i) begin
        if (rst_i) begin
            canonical_valid_o <= 1'b0;
            canonical_kmer_o  <= {(2*K){1'b0}};
            forward_kmer_o    <= {(2*K){1'b0}};
            rc_kmer_o         <= {(2*K){1'b0}};
            canonical_pos_o   <= 32'd0;
        end else begin
            canonical_valid_o <= kmer_valid_i;
            forward_kmer_o    <= kmer_i;
            rc_kmer_o         <= rc_w;
            canonical_kmer_o  <= take_forward_w ? kmer_i : rc_w;
            canonical_pos_o   <= kmer_pos_i;
        end
    end
endmodule
