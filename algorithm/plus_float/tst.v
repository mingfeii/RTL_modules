module tst (

    input [6:0] a,
    input [4:0] b,
    output reg [3:0] c
);


wire [7:0] c2;
wire [6:0] c3;
wire [5:0] c4;
wire [6:0] a2;
wire [5:0] b2;


assign a2 = a;
assign b2 = {b,1'b0};
assign c2 = a2 + b2;
assign c3 = c2[7:2] + 6'd1;
assign c4 = c3[5:1];

always@(*) begin 
    if (c4 > 4'hf)
        c = 4'hf;
    else 
        c = c4[3:0];
end 


endmodule 