module mac_pipelined (
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

    assign a_signed = a;
    assign b_signed = b;
    assign product = a_signed * b_signed;

    reg signed [31:0] product_reg;
    reg               valid_reg;
    reg signed [39:0] acc_reg;

    assign acc = acc_reg;

    always @(posedge clk) begin
        if (rst) begin
            product_reg <= 32'sd0;
            valid_reg   <= 1'b0;
            acc_reg     <= 40'sd0;
        end else begin
            valid_reg <= en;

            if (en)
                product_reg <= product;

            if (valid_reg)
                acc_reg <= acc_reg + product_reg;
        end
    end

endmodule
