`timescale 1 ns / 1 ns

module tb;

parameter int CLK_T          = 10_000;
parameter int DIVINDED_WIDTH = 20;
parameter int DIVISOR_WIDTH  = 20;
parameter int N = DIVINDED_WIDTH;
parameter int M = DIVISOR_WIDTH;
parameter NUM = 1000;

bit                    clk;
bit                    rst_n;
bit signed [N - 1 : 0] dividend;    
bit signed [M - 1 : 0] divisor;
bit signed [N - 1 : 0] quotient;
bit signed [M - 1 : 0] remainder;
bit                    valid_in;
bit                    valid_o;

logic  [N+1:0] [N-1:0]   dividend_ref ;
logic  [N+1:0] [M-1:0]   divisor_ref ;

wire signed [N-1:0] dividend_ref_top;
wire signed [M-1:0] divisor_ref_top;

bit signed_bit_dividend;
reg [N-2:0] unsigned_dividend;
bit sigend_bit_divisor;
reg [M-2:0] unsigned_divisor;


int data_count;
int ocnt;

initial begin 
    forever
    begin
      #( CLK_T / 2 );
      clk = !clk;
    end
end 

initial begin 
  rst_n = 1'b0;
  repeat(100)@(posedge clk);
  rst_n = 1'b1;
end 


always @(posedge clk or negedge rst_n) begin

  if (!rst_n) begin 
      valid_in <= 1'b0;
      unsigned_dividend <= '0;
      unsigned_divisor <= 1;
  end else if (data_count < NUM) begin
      valid_in <= 1'b1;
      signed_bit_dividend <= $random();
      unsigned_dividend <= $urandom_range(1,2**N-1);
      sigend_bit_divisor <= $random();
      unsigned_divisor <= $urandom_range(1,2**M-1);
      data_count <= data_count + 1;
  end else begin 
      valid_in <= 1'b0;
      unsigned_dividend <= unsigned_dividend;
      unsigned_divisor <= unsigned_divisor;
  end 

end 



assign dividend = {signed_bit_dividend,unsigned_dividend};
assign divisor = {sigend_bit_divisor,unsigned_divisor};


always@(posedge clk or negedge rst_n)
  if (!rst_n)
    ocnt <= 0;
  else if (valid_o)
    ocnt <= ocnt + 1'b1;

genvar         i ;
generate
  for(i=1; i<=N+1; i=i+1) begin
      always @(posedge clk) begin
        dividend_ref[i] <= dividend_ref[i-1];
        divisor_ref[i]  <= divisor_ref[i-1];
      end
  end
endgenerate

assign dividend_ref_top = dividend_ref[N+1];
assign divisor_ref_top = divisor_ref[N+1];

//auto check
reg  error_flag ;
always @(posedge clk) begin
  if ((quotient * divisor_ref_top + remainder != dividend_ref_top) && valid_o) begin
      $display("dividend_ref : %d\n",dividend_ref_top);
      $display("divisor_ref : %d\n",divisor_ref_top);
      $display("quotient : %d\n",quotient);
      $display("remainder : %d\n",remainder);
      error_flag <= 1'b1 ;
      $stop;
  end
  else begin
      error_flag <= 1'b0 ;
  end
end

   always @(posedge clk) begin
      dividend_ref[0] <= dividend ;
      divisor_ref[0]  <= divisor ;
   end

division #(
  .N ( N ),
  .M ( M  )
) DUT (
  .clk_i          ( clk            ),
  .rst_n_i        ( rst_n          ),
  .dividend_i     ( dividend       ),
  .divisor_i      ( divisor        ),
  .valid_i        ( valid_in       ),
  .quotient_o     ( quotient       ),
  .remainder_o    ( remainder      ),
  .valid_o        ( valid_o        )
);

initial
  begin
    @(posedge rst_n);
    @( posedge clk );

    wait(ocnt == NUM)
    repeat( 10 )
      @( posedge clk );
    $finish;
  end




endmodule
