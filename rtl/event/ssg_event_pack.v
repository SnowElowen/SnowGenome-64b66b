`timescale 1ns/1ps

module ssg_event_pack #(
    parameter integer K = 15,
    parameter integer TARGET_COUNT = 16
)(
    input  wire                         clk_i,
    input  wire                         rst_i,

    input  wire                         target_valid_i,
    input  wire [TARGET_COUNT-1:0]      target_hit_vector_i,
    input  wire [2*K-1:0]               target_kmer_i,
    input  wire [31:0]                  target_pos_i,

    input  wire                         motif_valid_i,
    input  wire                         motif_hit_i,
    input  wire signed [15:0]           motif_score_i,

    output reg                          event_valid_o,
    output reg  [1:0]                   event_type_o,
    output reg  [31:0]                  read_pos_o,
    output reg  [63:0]                  event_kmer_o,
    output reg signed [15:0]            motif_score_o,
    output reg  [TARGET_COUNT-1:0]      hit_vector_o
);
    wire target_hit_any_w = |target_hit_vector_i;
    wire both_w           = target_valid_i & motif_valid_i & target_hit_any_w & motif_hit_i;
    wire target_only_w    = target_valid_i & target_hit_any_w & ~(motif_valid_i & motif_hit_i);
    wire motif_only_w     = motif_valid_i & motif_hit_i & ~(target_valid_i & target_hit_any_w);
    wire event_w          = both_w | target_only_w | motif_only_w;

    always @(posedge clk_i) begin
        if (rst_i) begin
            event_valid_o <= 1'b0;
            event_type_o  <= 2'b00;
            read_pos_o    <= 32'd0;
            event_kmer_o  <= 64'd0;
            motif_score_o <= 16'sd0;
            hit_vector_o  <= {TARGET_COUNT{1'b0}};
        end else begin
            event_valid_o <= event_w;
            read_pos_o    <= target_pos_i;
            event_kmer_o  <= {{(64-(2*K)){1'b0}}, target_kmer_i};
            motif_score_o <= motif_score_i;
            hit_vector_o  <= target_hit_vector_i;

            if (both_w) begin
                event_type_o <= 2'b11;
            end else if (target_only_w) begin
                event_type_o <= 2'b01;
            end else if (motif_only_w) begin
                event_type_o <= 2'b10;
            end else begin
                event_type_o <= 2'b00;
            end
        end
    end
endmodule
