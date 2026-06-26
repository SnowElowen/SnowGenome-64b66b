`timescale 1ns/1ps

module ssg_target_cam_filter #(
    parameter integer K = 15,
    parameter integer TARGET_COUNT = 16,
    parameter [TARGET_COUNT*(2*K)-1:0] TARGET_KMERS = {(TARGET_COUNT*(2*K)){1'b0}}
)(
    input  wire                         clk_i,
    input  wire                         rst_i,

    input  wire                         kmer_valid_i,
    input  wire [2*K-1:0]               kmer_i,
    input  wire [31:0]                  kmer_pos_i,

    output reg                          hit_valid_o,
    output reg  [TARGET_COUNT-1:0]      hit_vector_o,
    output reg  [2*K-1:0]               hit_kmer_o,
    output reg  [31:0]                  hit_pos_o
);
    genvar gi;
    wire [TARGET_COUNT-1:0] hit_w;

    generate
        for (gi = 0; gi < TARGET_COUNT; gi = gi + 1) begin : g_target_compare
            wire [2*K-1:0] target_w;
            assign target_w = TARGET_KMERS[(gi*(2*K)) +: (2*K)];
            assign hit_w[gi] = (kmer_i == target_w);
        end
    endgenerate

    always @(posedge clk_i) begin
        if (rst_i) begin
            hit_valid_o  <= 1'b0;
            hit_vector_o <= {TARGET_COUNT{1'b0}};
            hit_kmer_o   <= {(2*K){1'b0}};
            hit_pos_o    <= 32'd0;
        end else begin
            hit_valid_o  <= kmer_valid_i;
            hit_vector_o <= kmer_valid_i ? hit_w : {TARGET_COUNT{1'b0}};
            hit_kmer_o   <= kmer_i;
            hit_pos_o    <= kmer_pos_i;
        end
    end
endmodule
