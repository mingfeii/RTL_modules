module pipeline_division #(
  parameter  DIVINDED_WIDTH = 8,
  parameter  DIVISOR_WIDTH  = 8
)(
  input                           clk_i,
  input                           rst_n_i,
  input  [DIVINDED_WIDTH - 1 : 0] divinded_i,
  input  [DIVISOR_WIDTH - 1 : 0]  divisor_i,
  input                           valid_i,
  output [DIVINDED_WIDTH - 1 : 0] quotient_o,
  output [DIVISOR_WIDTH - 1 : 0]  reminder_o,
  output                          valid_o
  );

localparam STAGES_AMOUNT   = DIVINDED_WIDTH + 2;
localparam SHIFT_REG_WIDTH = DIVINDED_WIDTH * 2;

// reg [STAGES_AMOUNT - 1 : 0]  rh [DIVINDED_WIDTH - 1 : 0];
// reg [STAGES_AMOUNT - 1 : 0]  rl [DIVINDED_WIDTH - 1 : 0];
// reg [STAGES_AMOUNT - 1 : 0]  rh_comb [DIVINDED_WIDTH - 1 : 0];
// reg [STAGES_AMOUNT - 1 : 0]  q;
// reg [STAGES_AMOUNT - 1 : 0]  divisor_lock [DIVISOR_WIDTH - 1 : 0];
// reg [STAGES_AMOUNT - 1 : 0]  valid_d;

reg [STAGES_AMOUNT - 1 : 0]  [DIVINDED_WIDTH - 1 : 0] rh ;
reg [STAGES_AMOUNT - 1 : 0]  [DIVINDED_WIDTH - 1 : 0] rl ;
reg [STAGES_AMOUNT - 1 : 0]  [DIVINDED_WIDTH - 1 : 0] rh_comb ;
reg [STAGES_AMOUNT - 1 : 0]  q;
reg [STAGES_AMOUNT - 1 : 0]  [DIVISOR_WIDTH - 1 : 0] divisor_lock ;
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
        rl[i] <= divinded_i;
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
assign reminder_o = rh[STAGES_AMOUNT - 1];
assign valid_o    = valid_d[STAGES_AMOUNT - 1];

endmodule
