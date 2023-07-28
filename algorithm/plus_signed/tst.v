module tst (

    input [7:0] a,
    input [5:0] b,
    output reg [4:0] c
);


wire signed [8:0] c2;
wire signed [7:0] c3;
wire signed [6:0] c4;
wire signed [7:0] a2;
wire signed [6:0] b2;


assign a2 = a;
assign b2 = {b,1'b0};
assign c2 = a2 + b2;
// assign c3 = c2[8:2] + 7'd1;
assign c3 = (c2 >>> 20) + 1;
// assign c4 = c3[7:1];
assign c4 = (c3 >>> 1);

always@(*) begin 
    if (c4 > 4'hf)
        c = 4'hf;
    else 
        c = c4[3:0];
end 


// always @(*) begin 
//     if (~c4[6]) begin //c4 >= 0
//         if (|c4[5:4]) //overflow
//             c = 5'd15;
//         else 
//             c = {1'b0,c4[3:0]};
//     end 
//     else begin //c4 < 0;
//         if (~(&c4[5:4])) //overflow
//             c = 5'd16; //-16
//         else 
//             c = {1'b1,c4[3:0]};
//     end 
// end 


always @(*) begin 
    if (~c4[6]) begin //c4 >= 0
        if (c4 > 15) //overflow
            c = 5'd15;
        else 
            c = c4;
    end 
    else begin //c4 < 0;
        if (c4 < -16) //overflow
            c = -16; //-16
        else 
            c = c4;
    end 
end 

endmodule 