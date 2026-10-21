
`timescale 1ns/1ps

module tb_mac_baseline;

    reg clk;
    reg rst;
    reg en;
    reg signed [15:0] a;
    reg signed [15:0] b;
    wire signed [39:0] acc;

    integer errors;

    mac_baseline dut (
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
        input [255:0] test_name;
        begin
            if (acc !== expected) begin
                $display("FAIL: %0s | expected=%0d, got=%0d",
                         test_name, expected, acc);
                errors = errors + 1;
            end else begin
                $display("PASS: %0s | acc=%0d",
                         test_name, acc);
            end
        end
    endtask

    initial begin
        $dumpfile("sim/mac_baseline.vcd");
        $dumpvars(0, tb_mac_baseline);

        clk = 0;
        rst = 1;
        en = 0;
        a = 0;
        b = 0;
        errors = 0;

        // Test 1: Reset clears the accumulator
        @(posedge clk);
        #1;
        check_acc(40'sd0, "Reset clears accumulator");

        // Release reset away from the active clock edge
        @(negedge clk);
        rst = 0;
        en = 1;
        a = 16'sd3;
        b = 16'sd4;

        // Test 2: 0 + (3 * 4) = 12
        @(posedge clk);
        #1;
        check_acc(40'sd12, "3 * 4 = 12");

        // Test 3: 12 + (3 * 4) = 24
        @(negedge clk);
        a = 16'sd3;
        b = 16'sd4;
        @(posedge clk);
        #1;
        check_acc(40'sd24, "Second accumulation gives 24");

        // Test 4: Disabled enable holds the value
        @(negedge clk);
        en = 0;
        a = 16'sd10;
        b = 16'sd10;
        @(posedge clk);
        #1;
        check_acc(40'sd24, "Enable low holds accumulator");

        // Test 5: Negative product: 24 + (-3 * 4) = 12
        @(negedge clk);
        en = 1;
        a = -16'sd3;
        b = 16'sd4;
        @(posedge clk);
        #1;
        check_acc(40'sd12, "Negative operand");

        // Test 6: Reset clears a nonzero result
        @(negedge clk);
        rst = 1;
        en = 1;
        @(posedge clk);
        #1;
        check_acc(40'sd0, "Reset clears accumulated result");
        // Test 7: Back-to-back operations with different inputs
        @(negedge clk);
        rst = 0;
        en = 1;
        a = 16'sd2;
        b = 16'sd5;
        @(posedge clk);
        #1;
        check_acc(40'sd10, "Back-to-back operation 1");

        @(negedge clk);
        a = 16'sd3;
        b = 16'sd6;
        @(posedge clk);
        #1;
        check_acc(40'sd28, "Back-to-back operation 2");

        // Test 8: Multiple disabled cycles hold the accumulator
        @(negedge clk);
        en = 0;
        a = 16'sd100;
        b = 16'sd100;
        repeat (2) begin
            @(posedge clk);
            #1;
            check_acc(40'sd28, "Disabled cycle holds accumulator");
            @(negedge clk);
        end

        // Test 9: Reset during enabled activity
        en = 1;
        a = 16'sd2;
        b = 16'sd3;
        @(posedge clk);
        #1;
        check_acc(40'sd34, "Operation before reset");

        @(negedge clk);
        rst = 1;
        @(posedge clk);
        #1;
        check_acc(40'sd0, "Reset during activity clears accumulator");

        // Test 10: Signed 40-bit accumulator overflow wraps
        @(negedge clk);
        rst = 0;
        en = 1;
        a = 16'sh7FFF;
        b = 16'sh7FFF;

        // Repeatedly accumulate 32767 * 32767 until the signed
        // 40-bit accumulator crosses its positive limit.
        repeat (1025) begin
            @(posedge clk);
            #1;
            @(negedge clk);
        end

        check_acc(40'sd1006568449,
                  "40-bit signed accumulator overflow");
        if (errors == 0)
            $display("ALL TESTS PASSED");

        else
            $display("TESTS FAILED: %0d error(s)", errors);

        $finish;
  end

endmodule
