`timescale 1 ps / 1 ps

module pipeline_division_tb;

parameter int CLK_T          = 10_000;
parameter int DIVINDED_WIDTH = 8;
parameter int DIVISOR_WIDTH  = 8;

bit                          clk;
bit                          rst;
bit [DIVINDED_WIDTH - 1 : 0] divinded;    
bit [DIVISOR_WIDTH - 1 : 0]  divisor;
bit [DIVINDED_WIDTH - 1 : 0] quotient;
bit [DIVISOR_WIDTH - 1 : 0]  reminder;
bit                          valid_in;
bit                          valid_o;

int quotient_q [$];
int reminder_q [$];

task automatic clk_gen();
  forever
    begin
      #( CLK_T / 2 );
      clk = !clk;
    end
endtask

task automatic apply_rst();
  @( posedge clk );
  rst <= 1'b1;
  @( posedge clk );
  rst <= 1'b0;
endtask



task automatic send_new_data();

  divinded <= $urandom_range( 2 ** DIVINDED_WIDTH - 1 );
  divisor  <= $urandom_range( 2 ** DIVISOR_WIDTH - 1 );
  valid_in    <= 1'b1;
  @(posedge clk);
  // do
  //   @( posedge clk );
  // while( !DUT.ready_o );
  valid_in <= 1'b0;
  quotient_q.push_back( divinded / divisor );
  reminder_q.push_back( divinded % divisor );
  
endtask

task automatic check_sum();

  bit [DIVINDED_WIDTH - 1 : 0] ref_quotient;
  bit [DIVISOR_WIDTH - 1 : 0]  ref_reminder;

  forever
    begin
      while( DUT.valid_o != 1'b1 )
        @( posedge clk );
      ref_quotient = quotient_q.pop_front();
      ref_reminder = reminder_q.pop_front();
      if( DUT.quotient_o != ref_quotient || DUT.reminder_o != ref_reminder )
        begin
          $display( "Result missmatch" );
          $display( "Was quotient %0d, reminder %0d", DUT.quotient_o, DUT.reminder_o );
          $display( "Should quotient %0d reminder %0d", ref_quotient, ref_reminder );
          @( posedge clk );
          $stop();
        end
    end
endtask

pipeline_division #(
  .DIVINDED_WIDTH ( DIVINDED_WIDTH ),
  .DIVISOR_WIDTH  ( DIVISOR_WIDTH  )
) DUT (
  .clk_i          ( clk            ),
  .rst_n_i          ( ~rst            ),
  .divinded_i     ( divinded       ),
  .divisor_i      ( divisor        ),
  .valid_i        ( valid_in          ),
  .quotient_o     ( quotient       ),
  .reminder_o     ( reminder       ),
  .valid_o        ( valid_o        )
);

initial
  begin
    fork
      clk_gen();
      
    join_none
    apply_rst();
    @( posedge clk );
    repeat( 100 )
      send_new_data();
    repeat( 10 )
      @( posedge clk );
    $stop();
  end


initial begin 
  check_sum();
end 


endmodule
