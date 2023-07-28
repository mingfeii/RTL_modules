`timescale 1ns/1ps

module tb();

int seed;

logic signed [7:0] a;
logic signed [5:0] b;
wire signed [4:0] c;

real c_real;
real c2;
real c_err;
real cnt1;
real cnt2;

initial begin 
    if (!$value$plusargs("seed=%d",seed))
        seed = 100;
    $random(seed);
    $fsdbDumpfile("tb.fsdb");
    $fsdbDumpvars(0);

end 

initial begin 
    a = 0;
    b = 0;
    cnt1 = -8;
    cnt2 = -4;

    while (cnt1 < 8 - 0.0625) begin 
        cnt1 = cnt1 + 0.0625;
        a = int'(cnt1 * (2**4));

        cnt2 = -4;
        while (cnt2 < 4 - 0.125) begin 
            cnt2 = cnt2 + 0.125;
            b = int'(cnt2 * (2**3));

            c_real = cnt1 + cnt2;

            if (c_real > 7.5)
                c_real = 7.5;
            else if (c_real <= -8)
                c_real = -8; 
            #10;
        end 
    end 
    #100;
    $finish;
end 

assign c2 = real'(c) / 2.0;
assign err = $abs(c_real - c2);

tst i_tst (
    .a(a),
    .b(b),
    .c(c)
);


endmodule 