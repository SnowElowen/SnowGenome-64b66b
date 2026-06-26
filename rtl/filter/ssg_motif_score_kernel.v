`timescale 1ns/1ps

module ssg_motif_score_kernel #(
    parameter integer K = 15,
    parameter integer MOTIF_W = 8,
    parameter signed [15:0] THRESHOLD = 16'sd8
)(
    input  wire              clk_i,
    input  wire              rst_i,

    input  wire              kmer_valid_i,
    input  wire [2*K-1:0]    kmer_i,
    input  wire [31:0]       kmer_pos_i,

    output reg               motif_valid_o,
    output reg               motif_hit_o,
    output reg signed [15:0] motif_score_o,
    output reg [31:0]        motif_pos_o
);
    integer j;
    reg [1:0] base_j;
    reg signed [15:0] score_sum;

    always @* begin
        score_sum = 16'sd0;
        for (j = 0; j < MOTIF_W; j = j + 1) begin
            base_j = kmer_i[(2*j)+:2];
            case (base_j)
                2'b00: score_sum = score_sum - 16'sd1; // A
                2'b01: score_sum = score_sum + 16'sd2; // C
                2'b10: score_sum = score_sum + 16'sd2; // G
                2'b11: score_sum = score_sum - 16'sd1; // T
                default: score_sum = score_sum;
            endcase
        end
    end

    always @(posedge clk_i) begin
        if (rst_i) begin
            motif_valid_o <= 1'b0;
            motif_hit_o   <= 1'b0;
            motif_score_o <= 16'sd0;
            motif_pos_o   <= 32'd0;
        end else begin
            motif_valid_o <= kmer_valid_i;
            motif_score_o <= score_sum;
            motif_hit_o   <= kmer_valid_i & (score_sum >= THRESHOLD);
            motif_pos_o   <= kmer_pos_i;
        end
    end
endmodule
