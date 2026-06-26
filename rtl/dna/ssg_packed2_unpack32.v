`timescale 1ns/1ps

module ssg_packed2_unpack32 (
    input  wire        clk_i,
    input  wire        rst_i,

    input  wire [63:0] word_i,
    input  wire        word_valid_i,
    output wire        word_ready_o,

    output wire        base_valid_o,
    input  wire        base_ready_i,
    output wire [1:0]  base_2bit_o,
    output wire [31:0] base_pos_o
);
    reg [63:0] word_shift_r;
    reg [4:0]  lane_cnt_r;
    reg        busy_r;
    reg [31:0] base_pos_r;

    wire base_fire_w = base_valid_o & base_ready_i;

    assign word_ready_o = ~busy_r;
    assign base_valid_o = busy_r;
    assign base_2bit_o  = word_shift_r[1:0];
    assign base_pos_o   = base_pos_r;

    always @(posedge clk_i) begin
        if (rst_i) begin
            word_shift_r <= 64'd0;
            lane_cnt_r   <= 5'd0;
            busy_r       <= 1'b0;
            base_pos_r   <= 32'd0;
        end else begin
            if (~busy_r) begin
                if (word_valid_i) begin
                    word_shift_r <= word_i;
                    lane_cnt_r   <= 5'd0;
                    busy_r       <= 1'b1;
                end
            end else if (base_fire_w) begin
                word_shift_r <= {2'b00, word_shift_r[63:2]};
                base_pos_r   <= base_pos_r + 32'd1;

                if (lane_cnt_r == 5'd31) begin
                    lane_cnt_r <= 5'd0;
                    busy_r     <= 1'b0;
                end else begin
                    lane_cnt_r <= lane_cnt_r + 5'd1;
                end
            end
        end
    end
endmodule
