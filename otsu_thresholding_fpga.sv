`timescale 1ns/1ps

// SRI HARI A S

module otsu_thresholding_fpga (
    input  logic clk,
    input  logic rst_n,
    input  logic start,
    input  logic [7:0] pixel_in,
    input  logic pixel_valid,
    input  logic last_pixel,
    output logic [7:0] threshold,
    output logic done
);

    typedef enum logic [2:0] {IDLE, CLEAR, BUILD, SUM, OTSU, DONE} state_t;
    state_t state, next_state;

    logic [18:0] hist [0:255];
    logic [7:0] addr, addr_delayed;
    logic [31:0] total_sum;
    logic [18:0] total_pixels, weightB;
    logic [31:0] sumB;
    logic [63:0] best_metric, curr_metric;

    always_ff @(posedge clk or negedge rst_n)
        if(!rst_n) state <= IDLE;
        else state <= next_state;

    always_comb begin
        next_state = state;
        case(state)
            IDLE: if(start) next_state = CLEAR;
            CLEAR: if(addr == 8'hFF) next_state = BUILD;
            BUILD: if(pixel_valid && last_pixel) next_state = SUM;
            SUM: if(addr == 8'hFF) next_state = OTSU;
            OTSU: if(addr == 8'hFF) next_state = DONE;
            DONE: next_state = IDLE;
        endcase
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            {addr, addr_delayed, total_sum, total_pixels, weightB, sumB, best_metric, threshold, done} <= '0;
        end else begin
            case(state)
                IDLE: begin
                    {addr, addr_delayed, done, total_sum, total_pixels, weightB, sumB, best_metric} <= '0;
                end

                CLEAR: begin
                    hist[addr] <= 0;
                    addr <= addr + 1;
                end

                BUILD: begin
                    if(pixel_valid) begin
                        hist[pixel_in] <= hist[pixel_in] + 1;
                        total_pixels <= total_pixels + 1;
                    end
                    addr <= 0;
                end

                SUM: begin
                    total_sum <= total_sum + (addr * hist[addr]);
                    addr <= addr + 1;
                    weightB <= 0; sumB <= 0;
                end

                OTSU: begin
                    weightB <= weightB + hist[addr];
                    sumB <= sumB + (addr * hist[addr]);
                    
                    // Track addr for the math (math uses sumB/weightB from the PREVIOUS cycle)
                    addr_delayed <= addr; 

                    if(weightB > 0 && weightB < total_pixels) begin
                        // Calculate Numerator: (sumB * total_pixels - total_sum * weightB)
                        automatic logic [47:0] t1 = 48'(sumB) * 48'(total_pixels);
                        automatic logic [47:0] t2 = 48'(total_sum) * 48'(weightB);
                        automatic logic [47:0] diff = (t1 > t2) ? (t1 - t2) : (t2 - t1);
                        
                        // Scaling to prevent 64-bit overflow during squaring
                        begin
                            automatic logic [31:0] s_diff = diff >> 12;
                            automatic logic [63:0] num_sq = 64'(s_diff) * 64'(s_diff);
                            
                            // Denominator: weightB * weightF
                            automatic logic [37:0] den = 38'(weightB) * 38'(total_pixels - weightB);

                            // Correct Variance = Numerator^2 / Denominator
                            if (den > 0) curr_metric = num_sq / 64'(den);
                            else curr_metric = 0;
                        end

                        if(curr_metric > best_metric) begin
                            best_metric <= curr_metric;
                            threshold <= addr_delayed;
                        end
                    end
                    addr <= addr + 1;
                end

                DONE: done <= 1;
            endcase
        end
    end
endmodule