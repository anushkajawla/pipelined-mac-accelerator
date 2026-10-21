
`timescale 1ns/1ps

module tb_mac_pipelined;

    reg clk;
    reg rst;
    reg en;
    reg signed [15:0] a;
    reg signed [15:0] b;

    wire signed [39:0] acc;

    integer errors;

    mac_pipelined dut (
        .clk(clk),
        .rst(rst),
        .en(en),
        .a(a),
        .b(b),
        .acc(acc)
    );

    always #5 clk = ~clk;

    task check_acc;
        input signed [39:0] expected;
        input [8*60-1:0] message;
        begin
            if (acc !== expected) begin
                $display("FAIL: %0s | expected=%0d actual=%0d",
                         message, expected, acc);
                errors = errors + 1;
            end
            else begin
                $display("PASS: %0s | acc=%0d",
                         message, acc);
            end
        end
    endtask

    initial begin
        $dumpfile("sim/mac_pipelined.vcd");
        $dumpvars(0, tb_mac_pipelined);

        clk = 0;
        rst = 1;
        en = 0;
        a = 0;
        b = 0;
        errors = 0;

        // Test 1: Reset
        @(posedge clk);
        #1;
        check_acc(40'sd0, "Reset clears accumulator");

        // Test 2: First product and pipeline latency
        @(negedge clk);
        rst = 0;
        en = 1;
        a = 3;
        b = 4;

        @(posedge clk);
        #1;
        check_acc(40'sd0, "First product captured, accumulation pending");

        @(negedge clk);
        en = 0;

        @(posedge clk);
        #1;
        check_acc(40'sd12, "First product accumulated");

        // Test 3: Back-to-back operations
        @(negedge clk);
        en = 1;
        a = 2;
        b = 5;

        @(posedge clk);
        #1;
        check_acc(40'sd12, "First back-to-back product captured");

        @(negedge clk);
        a = 3;
        b = 6;

        @(posedge clk);
        #1;
        check_acc(40'sd22, "First back-to-back product accumulated");

        @(negedge clk);
        en = 0;

        @(posedge clk);
        #1;
        check_acc(40'sd40, "Second back-to-back product accumulated");

        // Test 4: Disabled cycles do not accumulate
        repeat (2) begin
            @(negedge clk);
            @(posedge clk);
            #1;
            check_acc(40'sd40, "Disabled cycle holds accumulator");
        end

        // Test 5: Signed negative multiplication
        @(negedge clk);
        en = 1;
        a = -3;
        b = 4;

        @(posedge clk);
        #1;
        check_acc(40'sd40, "Negative product captured");

        @(negedge clk);
        en = 0;

        @(posedge clk);
        #1;
        check_acc(40'sd28, "Negative product accumulated");

        // Test 6: Reset while a product is pending
        @(negedge clk);
        en = 1;
        a = 5;
        b = 6;

        @(posedge clk);
        #1;
        check_acc(40'sd28, "Product pending before reset");

        @(negedge clk);
        rst = 1;
        en = 0;

        @(posedge clk);
        #1;
        check_acc(40'sd0, "Reset clears accumulator and pipeline");

        // Test 7: No stale product after reset
        @(negedge clk);
        rst = 0;

        @(posedge clk);
        #1;
        check_acc(40'sd0, "No stale product after reset");

        // Test 8: Signed 40-bit accumulator overflow
        @(negedge clk);
        en = 1;
        a = 16'sh7FFF;
        b = 16'sh7FFF;

        // 32767 * 32767 accumulated 1025 times.
        repeat (1025) begin
            @(posedge clk);
            #1;
            @(negedge clk);
        end

                // Allow the final accepted product to leave the pipeline.
        en = 0;
        @(posedge clk);
        #1;

        check_acc(40'sd1006568449,
                  "40-bit signed accumulator overflow");
        if (errors == 0)
            $display("ALL TESTS PASSED");
        else
            $display("TESTS FAILED: %0d error(s)", errors);

        $finish;
    end

endmodule


