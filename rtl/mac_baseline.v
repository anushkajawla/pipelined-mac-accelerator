module mac_baseline (
    input  wire        clk,
    input  wire        rst,
    input  wire        en,
    input  wire [15:0] a,
    input  wire [15:0] b,
    output wire [39:0] acc
);

    wire signed [15:0] a_signed;
    wire signed [15:0] b_signed;
    wire signed [31:0] product;
    reg  signed [39:0] acc_reg;

    assign a_signed = a;
    assign b_signed = b;
    assign product = a_signed * b_signed;
    assign acc = acc_reg;

    always @(posedge clk) begin
        if (rst)
            acc_reg <= 40'sd0;
        else if (en)
            acc_reg <= acc_reg + product;
    end

endmodule
