
module division #(
  parameter  N = 8,
  parameter  M  = 8
)(
  input              clk_i,
  input              rst_n_i,
  input  wire signed [N - 1 : 0] dividend_i,
  input  wire signed [M - 1 : 0] divisor_i,
  input              valid_i,
  output wire signed [N - 1 : 0] quotient_o,
  output wire signed [M - 1 : 0] remainder_o,
  output             valid_o
  );

wire [N-1:0]  unsigned_dividend;
wire [M-1:0]  unsigned_divisor;
wire [N-1:0]  unsigned_quotient;
wire [M-1:0]  unsigned_remainder;
wire signed [N-1:0]  signed_quotient;
wire signed [M-1:0]  signed_remainder;

wire dividend_is_negetive = $signed(dividend_i) < 0 ? 1'b1 : 1'b0;
wire divisor_is_negetive = $signed(divisor_i) < 0 ? 1'b1 : 1'b0;
wire dividend_is_negetive_d;
wire divisor_is_negetive_d;

assign unsigned_dividend = dividend_is_negetive ? -dividend_i : dividend_i;
assign unsigned_divisor = divisor_is_negetive ? -divisor_i : divisor_i;

pipeline_data_delay #( 
	.LATENCY(N+2),
	.DW(2)
)sign_delay_U(
	.clk(clk_i),
  .rst_n(rst_n_i),
	.in_data({dividend_is_negetive,divisor_is_negetive}),
	.o_data({dividend_is_negetive_d,divisor_is_negetive_d})
);

pipeline_division #(
  .DIVINDED_WIDTH ( N ),
  .DIVISOR_WIDTH  ( M  )
) div_u (
  .clk_i          ( clk_i              ),
  .rst_n_i        ( rst_n_i            ),
  .dividend_i     ( unsigned_dividend  ),
  .divisor_i      ( unsigned_divisor   ),
  .valid_i        ( valid_i            ),
  .quotient_o     ( unsigned_quotient  ),
  .remainder_o    ( unsigned_remainder ),
  .valid_o        ( valid_o        )
);

  // 计算有符号商和余数
  assign signed_quotient = ( dividend_is_negetive_d ^ divisor_is_negetive_d) ? -unsigned_quotient : unsigned_quotient;
  assign signed_remainder = (dividend_is_negetive_d) ? -unsigned_remainder : unsigned_remainder;
  assign quotient_o = signed_quotient;
  assign remainder_o = signed_remainder;

endmodule 