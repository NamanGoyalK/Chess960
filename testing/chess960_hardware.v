// Enhanced Chess960 Position Generator with Performance Counters
module chess960_position_generator(
    input wire clk,
    input wire reset,
    input wire [9:0] position_index,
    input wire generate_enable,
    output reg [63:0] chess_position,
    output reg position_valid,
    output reg generation_complete
);

    // Memory to store all 960 Chess960 positions
    reg [63:0] position_memory [0:959];
    
    // Performance counters
    reg [31:0] generation_count;
    reg [31:0] cycle_counter;
    
    // Initialize position memory (in real implementation, load from file)
    initial begin
        $readmemh("chess960_positions.mem", position_memory);
        generation_count = 0;
        cycle_counter = 0;
    end
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            chess_position <= 64'h0;
            position_valid <= 1'b0;
            generation_complete <= 1'b0;
            generation_count <= 32'h0;
            cycle_counter <= 32'h0;
        end else begin
            cycle_counter <= cycle_counter + 1;
            
            if (generate_enable) begin
                // Single cycle position generation
                if (position_index < 960) begin
                    chess_position <= position_memory[position_index];
                    position_valid <= 1'b1;
                    generation_count <= generation_count + 1;
                end else begin
                    chess_position <= 64'h0;
                    position_valid <= 1'b0;
                end
                generation_complete <= 1'b1;
            end else begin
                generation_complete <= 1'b0;
            end
        end
    end
    
endmodule

// Enhanced Chess960 Encoder with Pipeline Support
module chess960_encoder_enhanced(
    input wire clk,
    input wire reset,
    input wire [9:0] data_in,
    input wire encode_enable,
    output reg [63:0] board_out,
    output reg encode_valid,
    output reg [31:0] encode_count
);

    reg [63:0] positions [0:959];
    
    initial begin
        $readmemh("chess960_positions.mem", positions);
        encode_count = 0;
    end
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            board_out <= 64'h0;
            encode_valid <= 1'b0;
            encode_count <= 32'h0;
        end else if (encode_enable) begin
            if (data_in < 960) begin
                board_out <= positions[data_in];
                encode_valid <= 1'b1;
                encode_count <= encode_count + 1;
            end else begin
                board_out <= 64'h0;
                encode_valid <= 1'b0;
            end
        end else begin
            encode_valid <= 1'b0;
        end
    end
    
endmodule

// Enhanced Chess960 Decoder with CAM (Content Addressable Memory) approach
module chess960_decoder_enhanced(
    input wire clk,
    input wire reset,
    input wire [63:0] board_in,
    input wire decode_enable,
    output reg [9:0] data_out,
    output reg decode_valid,
    output reg [31:0] decode_count,
    output reg [9:0] search_cycles
);

    reg [63:0] positions [0:959];
    reg [9:0] search_index;
    reg searching;
    
    initial begin
        $readmemh("chess960_positions.mem", positions);
        decode_count = 0;
    end
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            data_out <= 10'h0;
            decode_valid <= 1'b0;
            decode_count <= 32'h0;
            search_cycles <= 10'h0;
            search_index <= 10'h0;
            searching <= 1'b0;
        end else if (decode_enable && !searching) begin
            // Start search
            searching <= 1'b1;
            search_index <= 10'h0;
            search_cycles <= 10'h0;
            decode_valid <= 1'b0;
        end else if (searching) begin
            search_cycles <= search_cycles + 1;
            
            if (positions[search_index] == board_in) begin
                // Found match
                data_out <= search_index;
                decode_valid <= 1'b1;
                decode_count <= decode_count + 1;
                searching <= 1'b0;
            end else if (search_index == 959) begin
                // Search complete, no match found
                data_out <= 10'h3FF; // Error code
                decode_valid <= 1'b1;
                searching <= 1'b0;
            end else begin
                search_index <= search_index + 1;
            end
        end
    end
    
endmodule

// Performance Monitor Module
module performance_monitor(
    input wire clk,
    input wire reset,
    input wire encode_valid,
    input wire decode_valid,
    output reg [31:0] encode_throughput,
    output reg [31:0] decode_throughput,
    output reg [31:0] total_operations,
    output reg [15:0] avg_latency
);

    reg [31:0] encode_count;
    reg [31:0] decode_count;
    reg [31:0] cycle_count;
    reg [31:0] latency_accumulator;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            encode_count <= 32'h0;
            decode_count <= 32'h0;
            cycle_count <= 32'h0;
            latency_accumulator <= 32'h0;
            encode_throughput <= 32'h0;
            decode_throughput <= 32'h0;
            total_operations <= 32'h0;
            avg_latency <= 16'h0;
        end else begin
            cycle_count <= cycle_count + 1;
            
            if (encode_valid) begin
                encode_count <= encode_count + 1;
            end
            
            if (decode_valid) begin
                decode_count <= decode_count + 1;
            end
            
            // Update throughput every 1000 cycles
            if (cycle_count % 1000 == 0) begin
                encode_throughput <= encode_count;
                decode_throughput <= decode_count;
                total_operations <= encode_count + decode_count;
                if (total_operations > 0) begin
                    avg_latency <= cycle_count / total_operations;
                end
            end
        end
    end
    
endmodule

// Comprehensive Test System - FIXED VERSION
module chess960_test_system(
    input wire clk,
    input wire reset,
    input wire start_test,
    output reg test_complete,
    output reg test_passed,
    // Individual test result outputs instead of array
    output reg [31:0] total_tests,
    output reg [31:0] correct_results,
    output reg [31:0] error_count,
    output reg [31:0] encode_throughput,
    output reg [31:0] decode_throughput,
    output reg [15:0] avg_latency,
    output reg [31:0] max_search_cycles,
    output reg [31:0] min_search_cycles,
    output reg [31:0] total_test_time,
    output reg [31:0] success_rate
);

    // Test parameters
    parameter TEST_SIZE = 100; // Reduced for faster testing
    parameter MAX_CYCLES = 100000;
    
    // State machine
    reg [3:0] test_state;
    reg [15:0] test_counter;
    reg [9:0] test_data;
    
    // Module instances
    wire [63:0] encoded_position;
    wire [9:0] decoded_data;
    wire encode_valid, decode_valid;
    wire [31:0] encode_count, decode_count;
    wire [9:0] search_cycles;
    
    chess960_encoder_enhanced encoder(
        .clk(clk),
        .reset(reset),
        .data_in(test_data),
        .encode_enable(test_state == 4'h2),
        .board_out(encoded_position),
        .encode_valid(encode_valid),
        .encode_count(encode_count)
    );
    
    chess960_decoder_enhanced decoder(
        .clk(clk),
        .reset(reset),
        .board_in(encoded_position),
        .decode_enable(test_state == 4'h4),
        .data_out(decoded_data),
        .decode_valid(decode_valid),
        .decode_count(decode_count),
        .search_cycles(search_cycles)
    );
    
    // Performance monitoring
    wire [31:0] perf_encode_throughput, perf_decode_throughput, perf_total_operations;
    wire [15:0] perf_avg_latency;
    
    performance_monitor perf_mon(
        .clk(clk),
        .reset(reset),
        .encode_valid(encode_valid),
        .decode_valid(decode_valid),
        .encode_throughput(perf_encode_throughput),
        .decode_throughput(perf_decode_throughput),
        .total_operations(perf_total_operations),
        .avg_latency(perf_avg_latency)
    );
    
    // Test statistics
    reg [31:0] correct_count;
    reg [31:0] error_cnt;
    reg [31:0] max_search_cyc;
    reg [31:0] min_search_cyc;
    reg [31:0] total_search_cycles;
    reg [31:0] start_time;
    reg [31:0] cycle_counter;
    
    // Random number generator for test data
    reg [31:0] lfsr;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            test_state <= 4'h0;
            test_counter <= 16'h0;
            test_data <= 10'h0;
            test_complete <= 1'b0;
            test_passed <= 1'b0;
            correct_count <= 32'h0;
            error_cnt <= 32'h0;
            max_search_cyc <= 32'h0;
            min_search_cyc <= 32'hFFFFFFFF;
            total_search_cycles <= 32'h0;
            start_time <= 32'h0;
            cycle_counter <= 32'h0;
            lfsr <= 32'hACE1; // Seed value
            
            // Initialize output ports
            total_tests <= 32'h0;
            correct_results <= 32'h0;
            error_count <= 32'h0;
            encode_throughput <= 32'h0;
            decode_throughput <= 32'h0;
            avg_latency <= 16'h0;
            max_search_cycles <= 32'h0;
            min_search_cycles <= 32'h0;
            total_test_time <= 32'h0;
            success_rate <= 32'h0;
            
        end else begin
            cycle_counter <= cycle_counter + 1;
            
            // Linear Feedback Shift Register for pseudo-random numbers
            lfsr <= {lfsr[30:0], lfsr[31] ^ lfsr[21] ^ lfsr[1] ^ lfsr[0]};
            
            case (test_state)
                4'h0: begin // IDLE
                    if (start_test) begin
                        test_state <= 4'h1;
                        test_counter <= 16'h0;
                        start_time <= cycle_counter;
                        test_complete <= 1'b0;
                    end
                end
                
                4'h1: begin // GENERATE_TEST_DATA
                    test_data <= lfsr[9:0] % 960; // Generate random position index
                    test_state <= 4'h2;
                end
                
                4'h2: begin // ENCODE
                    if (encode_valid) begin
                        test_state <= 4'h3;
                    end
                end
                
                4'h3: begin // WAIT_FOR_ENCODE
                    test_state <= 4'h4; // Move to decode immediately
                end
                
                4'h4: begin // DECODE
                    if (decode_valid) begin
                        test_state <= 4'h5;
                    end
                end
                
                4'h5: begin // CHECK_RESULT
                    if (decoded_data == test_data) begin
                        correct_count <= correct_count + 1;
                    end else begin
                        error_cnt <= error_cnt + 1;
                    end
                    
                    // Update search cycle statistics
                    if (search_cycles > max_search_cyc) begin
                        max_search_cyc <= search_cycles;
                    end
                    if (search_cycles < min_search_cyc) begin
                        min_search_cyc <= search_cycles;
                    end
                    total_search_cycles <= total_search_cycles + search_cycles;
                    
                    test_counter <= test_counter + 1;
                    
                    if (test_counter >= TEST_SIZE - 1) begin
                        test_state <= 4'h6; // Complete test
                    end else begin
                        test_state <= 4'h1; // Next test
                    end
                end
                
                4'h6: begin // COMPLETE_TEST
                    // Calculate final results
                    total_tests <= TEST_SIZE;
                    correct_results <= correct_count;
                    error_count <= error_cnt;
                    encode_throughput <= perf_encode_throughput;
                    decode_throughput <= perf_decode_throughput;
                    avg_latency <= perf_avg_latency;
                    max_search_cycles <= max_search_cyc;
                    min_search_cycles <= min_search_cyc;
                    total_test_time <= cycle_counter - start_time;
                    success_rate <= (correct_count * 100) / TEST_SIZE; // Success rate
                    
                    test_complete <= 1'b1;
                    test_passed <= (error_cnt == 0);
                    test_state <= 4'h7; // DONE
                end
                
                4'h7: begin // DONE
                    // Stay in done state until reset
                end
                
                default: begin
                    test_state <= 4'h0;
                end
            endcase
        end
    end
    
endmodule

// Main Testbench with Comprehensive Testing - FIXED VERSION
module comprehensive_testbench;
    
    reg clk;
    reg reset;
    reg start_test;
    
    // Individual result wires instead of array
    wire [31:0] total_tests;
    wire [31:0] correct_results;
    wire [31:0] error_count;
    wire [31:0] encode_throughput;
    wire [31:0] decode_throughput;
    wire [15:0] avg_latency;
    wire [31:0] max_search_cycles;
    wire [31:0] min_search_cycles;
    wire [31:0] total_test_time;
    wire [31:0] success_rate;
    
    wire test_complete;
    wire test_passed;
    
    // Clock generation (100 MHz)
    always #5 clk = ~clk;
    
    // Instantiate test system
    chess960_test_system test_sys(
        .clk(clk),
        .reset(reset),
        .start_test(start_test),
        .test_complete(test_complete),
        .test_passed(test_passed),
        .total_tests(total_tests),
        .correct_results(correct_results),
        .error_count(error_count),
        .encode_throughput(encode_throughput),
        .decode_throughput(decode_throughput),
        .avg_latency(avg_latency),
        .max_search_cycles(max_search_cycles),
        .min_search_cycles(min_search_cycles),
        .total_test_time(total_test_time),
        .success_rate(success_rate)
    );
    
    // Test sequence
    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        start_test = 0;
        
        // Create waveform dump
        $dumpfile("chess960_test.vcd");
        $dumpvars(0, comprehensive_testbench);
        
        // Reset sequence
        #20 reset = 0;
        #10 start_test = 1;
        #10 start_test = 0;
        
        // Wait for test completion
        wait(test_complete);
        
        // Display results
        $display("\n================================================================================");
        $display("CHESS960 HARDWARE STEGANOGRAPHY TEST RESULTS");
        $display("================================================================================");
        $display("Total Tests:           %d", total_tests);
        $display("Correct Results:       %d", correct_results);
        $display("Errors:                %d", error_count);
        $display("Success Rate:          %d%%", success_rate);
        $display("Encode Throughput:     %d pos/sec", encode_throughput);
        $display("Decode Throughput:     %d pos/sec", decode_throughput);
        $display("Average Latency:       %d cycles", avg_latency);
        $display("Max Search Cycles:     %d", max_search_cycles);
        $display("Min Search Cycles:     %d", min_search_cycles);
        $display("Total Test Time:       %d cycles", total_test_time);
        $display("Test Status:           %s", test_passed ? "PASSED" : "FAILED");
        $display("================================================================================");
        
        // Performance analysis
        if (total_test_time > 0) begin
            $display("\nPERFORMANCE ANALYSIS:");
            $display("Clock Frequency:       100 MHz");
            $display("Cycles per operation:  %d", total_test_time / total_tests);
            $display("Operations per second: %d", (total_tests * 100000000) / total_test_time);
        end
        
        #100 $finish;
    end
    
    // Timeout protection
    initial begin
        #1000000 // 1M cycles timeout
        $display("ERROR: Test timeout!");
        $finish;
    end
    
endmodule