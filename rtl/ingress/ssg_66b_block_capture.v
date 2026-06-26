`timescale 1ns/1ps

module ssg_66b_block_capture (
    input  wire        clk_i,
    input  wire        rst_i,

    input  wire [63:0] rx_data_i,
    input  wire [1:0]  rx_header_i,
    input  wire        rx_valid_i,
    input  wire        rx_block_lock_i,

    input  wire        word_ready_i,
    output wire        rx_ready_o,

    output reg  [63:0] word_data_o,
    output reg         word_valid_o,
    output reg         bad_block_o
);
    wire header_legal_w;

    ssg_66b_header_check u_header_check (
        .header_i       (rx_header_i),
        .header_legal_o (header_legal_w)
    );

    assign rx_ready_o = (~word_valid_o) | word_ready_i;

    always @(posedge clk_i) begin
        if (rst_i) begin
            word_data_o  <= 64'd0;
            word_valid_o <= 1'b0;
            bad_block_o  <= 1'b0;
        end else begin
            bad_block_o <= 1'b0;

            if (word_valid_o && word_ready_i) begin
                word_valid_o <= 1'b0;
            end

            if (rx_ready_o && rx_valid_i) begin
                if (rx_block_lock_i && header_legal_w) begin
                    word_data_o  <= rx_data_i;
                    word_valid_o <= 1'b1;
                end else begin
                    word_valid_o <= 1'b0;
                    bad_block_o  <= 1'b1;
                end
            end
        end
    end
endmodule
