`timescale 1ns/1ps

module ssg_rolling_kmer #(
    parameter integer K = 15
)(
    input  wire              clk_i,
    input  wire              rst_i,

    input  wire              base_valid_i,
    output wire              base_ready_o,
    input  wire [1:0]        base_2bit_i,
    input  wire [31:0]       base_pos_i,

    output reg               kmer_valid_o,
    output reg  [2*K-1:0]    kmer_o,
    output reg  [31:0]       kmer_pos_o
);
    reg [2*K-1:0] kmer_r;
    reg [15:0]    fill_count_r;

    wire [2*K-1:0] kmer_next_w = {kmer_r[2*K-3:0], base_2bit_i};

    assign base_ready_o = 1'b1;

    always @(posedge clk_i) begin
        if (rst_i) begin
            kmer_r       <= {(2*K){1'b0}};
            fill_count_r <= 16'd0;
            kmer_valid_o <= 1'b0;
            kmer_o       <= {(2*K){1'b0}};
            kmer_pos_o   <= 32'd0;
        end else begin
            kmer_valid_o <= 1'b0;

            if (base_valid_i) begin
                kmer_r     <= kmer_next_w;
                kmer_o     <= kmer_next_w;
                kmer_pos_o <= base_pos_i;

                if (fill_count_r < K) begin
                    fill_count_r <= fill_count_r + 16'd1;
                end

                if (fill_count_r >= (K - 1)) begin
                    kmer_valid_o <= 1'b1;
                end
            end
        end
    end
endmodule
