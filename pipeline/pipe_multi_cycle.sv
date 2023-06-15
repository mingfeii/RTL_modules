//当需要多级寄存器和多级延迟时，可采取这种，配合外部的eof和req,使pipeline可以一直持续下去

wire ce = ~val|rdy;
wire [XBIT-1:0] xc;
wire [YBIT-1:0] yc;
wire eol, eof;

reg [DL:0] run;
reg sof, sol;

wire [DL:0] en = ce ? run : 0;
assign ack = ce & ~run[0] & req;
assign val = run[DL];
assign val_1 = run[DL-1];

always @(posedge clk or negedge rst_n)
if (~rst_n) begin
  run <= 0;
  sof <= 1'b1;
  sol <= 1'b1;
end else begin
  if (ce) run <= {run, run[0] ? ~eof : req};
  if (en[0]) sof <= eof;
  if (en[0]) sol <= eol;
end
