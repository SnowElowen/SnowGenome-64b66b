`timescale 1ps/1ps

module tb_snowgenome_top;
    localparam real IDEAL_PERIOD_PS = 3100.198;
    localparam integer K = 15;
    localparam integer TARGET_COUNT = 4;
    localparam integer W = 2*K;

    // target0 = ACGTACGTACGTACG, packed in stream order: oldest base at MSB in kmer.
    localparam [W-1:0] TARGET0 = 30'h06C6C6C6;
    localparam [W-1:0] TARGET1 = 30'h00000000;
    localparam [W-1:0] TARGET2 = 30'h3FFFFFFF;
    localparam [W-1:0] TARGET3 = 30'h15555555;
    localparam [TARGET_COUNT*W-1:0] TARGET_KMERS = {TARGET3, TARGET2, TARGET1, TARGET0};

    reg clk_i = 1'b0;
    reg rst_i = 1'b1;

    reg  [63:0] rx_data_i = 64'd0;
    reg  [1:0]  rx_header_i = 2'b01;
    reg         rx_valid_i = 1'b0;
    reg         rx_block_lock_i = 1'b0;
    wire        rx_ready_o;

    wire                         event_valid_o;
    wire [1:0]                   event_type_o;
    wire [31:0]                  read_pos_o;
    wire [63:0]                  event_kmer_o;
    wire signed [15:0]           motif_score_o;
    wire [TARGET_COUNT-1:0]      hit_vector_o;
    wire                         bad_block_o;

    integer event_count;
    integer target_hit_count;
    integer motif_hit_count;
    integer cycle_count;
    integer guard;

    always #(IDEAL_PERIOD_PS/2.0) clk_i = ~clk_i;

    snowgenome_top #(
        .K(K),
        .TARGET_COUNT(TARGET_COUNT),
        .MOTIF_W(8),
        .MOTIF_THRESHOLD(16'sd8),
        .TARGET_KMERS(TARGET_KMERS)
    ) dut (
        .clk_i          (clk_i),
        .rst_i          (rst_i),
        .rx_data_i      (rx_data_i),
        .rx_header_i    (rx_header_i),
        .rx_valid_i     (rx_valid_i),
        .rx_block_lock_i(rx_block_lock_i),
        .rx_ready_o     (rx_ready_o),
        .event_valid_o  (event_valid_o),
        .event_type_o   (event_type_o),
        .read_pos_o     (read_pos_o),
        .event_kmer_o   (event_kmer_o),
        .motif_score_o  (motif_score_o),
        .hit_vector_o   (hit_vector_o),
        .bad_block_o    (bad_block_o)
    );

    function [1:0] enc_base;
        input [7:0] ch;
        begin
            case (ch)
                "A": enc_base = 2'b00;
                "C": enc_base = 2'b01;
                "G": enc_base = 2'b10;
                "T": enc_base = 2'b11;
                default: enc_base = 2'b00;
            endcase
        end
    endfunction

    function [63:0] pack32;
        input integer start_idx;
        integer j;
        reg [7:0] ch;
        begin
            pack32 = 64'd0;
            for (j = 0; j < 32; j = j + 1) begin
                case ((start_idx + j) % 4)
                    0: ch = "A";
                    1: ch = "C";
                    2: ch = "G";
                    3: ch = "T";
                    default: ch = "A";
                endcase
                pack32[(2*j)+:2] = enc_base(ch);
            end
        end
    endfunction

    task send_word;
        input [63:0] word;
        begin
            @(posedge clk_i);
            while (!rx_ready_o) begin
                @(posedge clk_i);
            end
            rx_data_i   <= word;
            rx_header_i <= 2'b01;
            rx_valid_i  <= 1'b1;
            @(posedge clk_i);
            rx_valid_i  <= 1'b0;
            rx_data_i   <= 64'd0;
        end
    endtask

    always @(posedge clk_i) begin
        if (rst_i) begin
            cycle_count      <= 0;
            event_count      <= 0;
            target_hit_count <= 0;
            motif_hit_count  <= 0;
        end else begin
            cycle_count <= cycle_count + 1;
            if (event_valid_o) begin
                event_count <= event_count + 1;
                if (|hit_vector_o) begin
                    target_hit_count <= target_hit_count + 1;
                end
                if (event_type_o[1]) begin
                    motif_hit_count <= motif_hit_count + 1;
                end
                $display("EVENT cycle=%0d type=%b pos=%0d kmer=%h score=%0d hits=%b",
                         cycle_count, event_type_o, read_pos_o, event_kmer_o, motif_score_o, hit_vector_o);
            end
        end
    end

    initial begin
        event_count      = 0;
        target_hit_count = 0;
        motif_hit_count  = 0;
        cycle_count      = 0;
        guard            = 0;

        repeat (10) @(posedge clk_i);
        rst_i <= 1'b0;
        rx_block_lock_i <= 1'b1;
        repeat (4) @(posedge clk_i);

        // Stream is ACGT repeated. TARGET0 should hit repeatedly after k-mer fill.
        send_word(pack32(0));
        send_word(pack32(32));
        send_word(pack32(64));
        send_word(pack32(96));

        for (guard = 0; guard < 300; guard = guard + 1) begin
            @(posedge clk_i);
        end

        if (target_hit_count == 0) begin
            $fatal(1, "No target k-mer hit observed");
        end

        if (event_count == 0) begin
            $fatal(1, "No event observed");
        end

        $display("PASS: events=%0d target_hits=%0d motif_hits=%0d", event_count, target_hit_count, motif_hit_count);
        $finish;
    end
endmodule
