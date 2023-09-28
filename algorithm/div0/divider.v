module divider #(
    parameter N = 40,
    parameter M = 20,
    parameter N_ACT = M + N - 1

)(
    input clk,
    input rstn,
    
    input valid_in,
    input wire signed [N-1:0] dividend,
    input wire signed [M-1:0] divisor,
    output wire valid_o, 
    output wire signed [N-1:0] quotient,
    output wire signed [M-1:0] remainder

);


wire [N-1:0]  unsigned_dividend;
wire [M-1:0]  unsigned_divisor;
wire [N-1:0]  unsigned_quotient;
wire [M-1:0]  unsigned_remainder;
wire signed [N-1:0]  signed_quotient;
wire signed [M-1:0]  signed_remainder;



wire dividend_is_negetive = dividend < 0 ? 1'b1 : 1'b0;
wire divisor_is_negetive = divisor < 0 ? 1'b1 : 1'b0;
wire dividend_is_negetive_d;
wire divisor_is_negetive_d;

assign unsigned_dividend = dividend_is_negetive ? -dividend : dividend;
assign unsigned_divisor = divisor_is_negetive ? -divisor : divisor;

pipeline_data_delay #( 
	.LATENCY(N),
	.DW(2)
)sign_delay_U(
	.clk(clk),
    .rst_n(rstn),
	.in_data({dividend_is_negetive,divisor_is_negetive}),
	.o_data({dividend_is_negetive_d,divisor_is_negetive_d})
);


divider_main  #(.N(N), .M(M))
u_divider
    (
    .clk              (clk),
    .rstn             (rstn),
    .data_rdy         (valid_in),
    .dividend         (unsigned_dividend),
    .divisor          (unsigned_divisor),

    .res_rdy          (valid_o),
    .merchant         (unsigned_quotient),
    .remainder        (unsigned_remainder));

  // 计算有符号商和余数
  assign signed_quotient = ( dividend_is_negetive_d ^ divisor_is_negetive_d) ? -unsigned_quotient : unsigned_quotient;
  assign signed_remainder = (dividend_is_negetive_d) ? -unsigned_remainder : unsigned_remainder;
  assign quotient = signed_quotient;
  assign remainder = signed_remainder;





endmodule 
