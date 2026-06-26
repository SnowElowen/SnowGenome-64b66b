`timescale 1ns/1ps

module snowgenome_top #(
    parameter integer K = 15,
    parameter integer TARGET_COUNT = 16,
    parameter integer MOTIF_W = 8,
    parameter signed [15:0] MOTIF_THRESHOLD = 16'sd8,
    parameter [TARGET_COUNT*(2*K)-1:0] TARGET_KMERS = {(TARGET_COUNT*(2*K)){1'b0}}
)(
    input  wire                         clk_i,
    input  wire                         rst_i,

    input  wire [63:0]                  rx_data_i,
    input  wire [1:0]                   rx_header_i,
    input  wire                         rx_valid_i,
    input  wire                         rx_block_lock_i,
    output wire                         rx_ready_o,

    output wire                         event_valid_o,
    output wire [1:0]                   event_type_o,
    output wire [31:0]                  read_pos_o,
    output wire [63:0]                  event_kmer_o,
    output wire signed [15:0]           motif_score_o,
    output wire [TARGET_COUNT-1:0]      hit_vector_o,
    output wire                         bad_block_o
);
    wire [63:0] word_data_w;
    wire        word_valid_w;
    wire        word_ready_w;

    wire        base_valid_w;
    wire        base_ready_w;
    wire [1:0]  base_2bit_w;
    wire [31:0] base_pos_w;

    wire              kmer_valid_w;
    wire [2*K-1:0]    kmer_w;
    wire [31:0]       kmer_pos_w;

    wire              canonical_valid_w;
    wire [2*K-1:0]    canonical_kmer_w;
    wire [2*K-1:0]    forward_kmer_w;
    wire [2*K-1:0]    rc_kmer_w;
    wire [31:0]       canonical_pos_w;

    wire                         target_valid_w;
    wire [TARGET_COUNT-1:0]      target_hit_vector_w;
    wire [2*K-1:0]               target_kmer_w;
    wire [31:0]                  target_pos_w;

    wire               motif_valid_w;
    wire               motif_hit_w;
    wire signed [15:0] motif_score_w;
    wire [31:0]        motif_pos_w;

    ssg_66b_block_capture u_block_capture (
        .clk_i          (clk_i),
        .rst_i          (rst_i),
        .rx_data_i      (rx_data_i),
        .rx_header_i    (rx_header_i),
        .rx_valid_i     (rx_valid_i),
        .rx_block_lock_i(rx_block_lock_i),
        .word_ready_i   (word_ready_w),
        .rx_ready_o     (rx_ready_o),
        .word_data_o    (word_data_w),
        .word_valid_o   (word_valid_w),
        .bad_block_o    (bad_block_o)
    );

    ssg_packed2_unpack32 u_unpack32 (
        .clk_i        (clk_i),
        .rst_i        (rst_i),
        .word_i       (word_data_w),
        .word_valid_i (word_valid_w),
        .word_ready_o (word_ready_w),
        .base_valid_o (base_valid_w),
        .base_ready_i (base_ready_w),
        .base_2bit_o  (base_2bit_w),
        .base_pos_o   (base_pos_w)
    );

    ssg_rolling_kmer #(
        .K(K)
    ) u_rolling_kmer (
        .clk_i        (clk_i),
        .rst_i        (rst_i),
        .base_valid_i (base_valid_w),
        .base_ready_o (base_ready_w),
        .base_2bit_i  (base_2bit_w),
        .base_pos_i   (base_pos_w),
        .kmer_valid_o (kmer_valid_w),
        .kmer_o       (kmer_w),
        .kmer_pos_o   (kmer_pos_w)
    );

    ssg_canonical_kmer #(
        .K(K)
    ) u_canonical_kmer (
        .clk_i             (clk_i),
        .rst_i             (rst_i),
        .kmer_valid_i      (kmer_valid_w),
        .kmer_i            (kmer_w),
        .kmer_pos_i        (kmer_pos_w),
        .canonical_valid_o (canonical_valid_w),
        .canonical_kmer_o  (canonical_kmer_w),
        .forward_kmer_o    (forward_kmer_w),
        .rc_kmer_o         (rc_kmer_w),
        .canonical_pos_o   (canonical_pos_w)
    );

    ssg_target_cam_filter #(
        .K(K),
        .TARGET_COUNT(TARGET_COUNT),
        .TARGET_KMERS(TARGET_KMERS)
    ) u_target_cam_filter (
        .clk_i        (clk_i),
        .rst_i        (rst_i),
        .kmer_valid_i (canonical_valid_w),
        .kmer_i       (canonical_kmer_w),
        .kmer_pos_i   (canonical_pos_w),
        .hit_valid_o  (target_valid_w),
        .hit_vector_o (target_hit_vector_w),
        .hit_kmer_o   (target_kmer_w),
        .hit_pos_o    (target_pos_w)
    );

    ssg_motif_score_kernel #(
        .K(K),
        .MOTIF_W(MOTIF_W),
        .THRESHOLD(MOTIF_THRESHOLD)
    ) u_motif_score_kernel (
        .clk_i         (clk_i),
        .rst_i         (rst_i),
        .kmer_valid_i  (canonical_valid_w),
        .kmer_i        (canonical_kmer_w),
        .kmer_pos_i    (canonical_pos_w),
        .motif_valid_o (motif_valid_w),
        .motif_hit_o   (motif_hit_w),
        .motif_score_o (motif_score_w),
        .motif_pos_o   (motif_pos_w)
    );

    ssg_event_pack #(
        .K(K),
        .TARGET_COUNT(TARGET_COUNT)
    ) u_event_pack (
        .clk_i               (clk_i),
        .rst_i               (rst_i),
        .target_valid_i      (target_valid_w),
        .target_hit_vector_i (target_hit_vector_w),
        .target_kmer_i       (target_kmer_w),
        .target_pos_i        (target_pos_w),
        .motif_valid_i       (motif_valid_w),
        .motif_hit_i         (motif_hit_w),
        .motif_score_i       (motif_score_w),
        .event_valid_o       (event_valid_o),
        .event_type_o        (event_type_o),
        .read_pos_o          (read_pos_o),
        .event_kmer_o        (event_kmer_o),
        .motif_score_o       (motif_score_o),
        .hit_vector_o        (hit_vector_o)
    );
endmodule
