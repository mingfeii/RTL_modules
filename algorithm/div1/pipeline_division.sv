module pipeline_division #(
  parameter  DIVINDED_WIDTH = 8,
  parameter  DIVISOR_WIDTH  = 8
)(
  input                           clk_i,
  input                           rst_n_i,
  input  [DIVINDED_WIDTH - 1 : 0] dividend_i,
  input  [DIVISOR_WIDTH - 1 : 0]  divisor_i,
  input                           valid_i,
  output [DIVINDED_WIDTH - 1 : 0] quotient_o,
  output [DIVISOR_WIDTH - 1 : 0]  remainder_o,
  output                          valid_o
  );

localparam STAGES_AMOUNT   = DIVINDED_WIDTH + 2;

reg [DIVINDED_WIDTH - 1 : 0] rh [STAGES_AMOUNT - 1 : 0];
reg [DIVINDED_WIDTH - 1 : 0] rl [STAGES_AMOUNT - 1 : 0];
reg [DIVINDED_WIDTH - 1 : 0] rh_comb [STAGES_AMOUNT - 1 : 0];
reg [STAGES_AMOUNT - 1 : 0]  q;
reg [DIVISOR_WIDTH - 1 : 0] divisor_lock [STAGES_AMOUNT - 1 : 0];
reg [STAGES_AMOUNT - 1 : 0]  valid_d;

always @( posedge clk_i, negedge rst_n_i ) begin 
  integer i;
  if( !rst_n_i )
    valid_d <= 0;
  else begin
        valid_d[0] <= valid_i;
        for( i = 1; i < STAGES_AMOUNT; i++ )
          valid_d[i] <= valid_d[i - 1];
      end
end 

always @(*) begin 
  integer i;
  for( i = 0; i < STAGES_AMOUNT; i++ )
    begin
      q[i] = rh[i] >= divisor_lock[i];
      rh_comb[i] = rh[i];
      if( q[i] )
        rh_comb[i] = rh[i] - divisor_lock[i];
    end
end 

always @( posedge clk_i, negedge rst_n_i ) begin 
  integer i;
  for( i = 0; i < STAGES_AMOUNT; i++ ) begin 
    if( !rst_n_i )
        divisor_lock[i] <= 0;
    else if( i == 0 )
          divisor_lock[i] <= divisor_i;
        else
          divisor_lock[i] <= divisor_lock[i - 1];
  end 
end 

always @( posedge clk_i, negedge rst_n_i ) begin 
  integer i;
  for( i = 0; i < STAGES_AMOUNT; i++ ) begin 
    if( !rst_n_i ) begin 
      rh[i] <= 0;
      rl[i] <= 0;
    end else if( i == 0 ) begin 
        rh[i] <= 0;
        rl[i] <= dividend_i;
    end else if( i == ( STAGES_AMOUNT - 1 ) )  begin
        rh[i] <= rh_comb[i - 1];
        rl[i] <= { rl[i - 1][DIVINDED_WIDTH - 2 : 0], q[i - 1] };
    end else begin
        rh[i] <= { rh_comb[i - 1], rl[i - 1][DIVINDED_WIDTH - 1] };
        rl[i] <= { rl[i - 1][DIVINDED_WIDTH - 2 : 0], q[i - 1] };
    end
  end 
end 

assign quotient_o = rl[STAGES_AMOUNT - 1];
assign remainder_o = rh[STAGES_AMOUNT - 1];
assign valid_o    = valid_d[STAGES_AMOUNT - 1];

endmodule
