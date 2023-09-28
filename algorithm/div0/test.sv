`timescale 1ns/1ns

module test ;

   parameter    N = 40 ;
   parameter    M = 21;

   parameter TEST_NUM = 10000;


   reg          clk;
   reg          rstn ;

   reg          data_rdy ;
   wire signed [N-1:0]  dividend ;
   wire signed [M-1:0]  divisor ;

   wire         res_rdy ;
   wire signed [N-1:0] merchant ;
   wire signed [M-1:0] remainder ;


   bit signed_bit_dividend;
   reg [N-2:0] unsigned_dividend;
   bit sigend_bit_divisor;
   reg [M-2:0] unsigned_divisor;

   assign dividend = {signed_bit_dividend,unsigned_dividend};
   assign divisor = {sigend_bit_divisor,unsigned_divisor};

   integer data_count = 0;


   //clock
   always begin
      clk = 0 ; #5 ;
      clk = 1 ; #5 ;
   end

   //driver
   initial begin
      rstn      = 1'b0 ;
      #8 ;
      rstn      = 1'b1 ;

     wait(data_count == TEST_NUM);     
      repeat(1000)@(posedge clk);
      $finish;
   end // initial begin


    always@(posedge clk or negedge rstn) begin

      if (!rstn) begin 
         data_rdy <= 1'b0;
         unsigned_dividend <= '0;
         unsigned_divisor <= 1;
      end else if (data_count < TEST_NUM) begin
         data_rdy <= 1'b1;
         signed_bit_dividend <= $random();
         unsigned_dividend <= $urandom_range(1,2**N-1);
         sigend_bit_divisor <= $random();
         unsigned_divisor <= $urandom_range(1,2**(M-1)-1);
         data_count <= data_count + 1;
      end else begin 
         data_rdy <= 1'b0;
         unsigned_dividend <= unsigned_dividend;
         unsigned_divisor <= unsigned_divisor;
      end 

    end 
   //for better observation to align data_in and results
   reg  signed [N-1:0]   dividend_ref [N-1:0];
   reg  signed [M-1:0]   divisor_ref [N-1:0];
   always @(posedge clk) begin
      dividend_ref[0] <= dividend ;
      divisor_ref[0]  <= divisor ;
   end

   genvar         i ;
   generate
      for(i=1; i<=N-1; i=i+1) begin
         always @(posedge clk) begin
            dividend_ref[i] <= dividend_ref[i-1];
            divisor_ref[i]  <= divisor_ref[i-1];
         end
      end
   endgenerate

   //auto check
   reg  error_flag ;
   always @(posedge clk) begin
      # 1 ;
      if (merchant * divisor_ref[N-1] + remainder != dividend_ref[N-1] && res_rdy) begin
         $display("dividend_ref : %d\n",dividend_ref[N-1]);
         $display("divisor_ref : %d\n",divisor_ref[N-1]);
         $display("merchant : %d\n",merchant);
         $display("remainder : %d\n",remainder);
         error_flag <= 1'b1 ;
      end
      else begin
         error_flag <= 1'b0 ;
      end
   end

   // //module instantiation
   // divider_man  #(.N(N), .M(M))
   // u_divider
   //   (
   //    .clk              (clk),
   //    .rstn             (rstn),
   //    .data_rdy         (data_rdy),
   //    .dividend         (dividend),
   //    .divisor          (divisor),

   //    .res_rdy          (res_rdy),
   //    .merchant         (merchant),
   //    .remainder        (remainder));


divider #(.N(N), .M(M))
u_divider(
   .clk              (clk),
   .rstn             (rstn),
   .valid_in(data_rdy),
   .dividend(dividend),
   .divisor(divisor),
   .valid_o(res_rdy), 
   .quotient(merchant),
   .remainder(remainder)

);

endmodule // test
