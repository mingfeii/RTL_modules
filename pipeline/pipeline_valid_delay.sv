module pipeline_valid_delay #(parameter 
    LATENCY=20
)(
    input clk,
    input rst_n,
    input in_valid,
    output logic  o_valid
);

reg [LATENCY-2:0] valid_mem;
reg                valid_r;

generate
	if (LATENCY==0)begin:NO_LANTENCY
		assign o_valid=in_valid;
	end else if (LATENCY==1)begin:DELAY1
		reg o_valid_r;
		always_ff@(posedge clk)
			o_valid_r<=in_valid;
		assign o_valid=o_valid_r;
	end else begin:NORMAL_LANTENCY
		integer i;
		always_ff@(posedge clk or negedge rst_n)begin
			if (~rst_n)begin
				valid_r <= 1'b0;
				valid_mem = '0;
			end else begin 
				valid_mem[0] <= in_valid;
				valid_r <= valid_mem[LATENCY-2];
				for (i=LATENCY-2;i>=1;i=i-1)begin
					valid_mem[i] <= valid_mem[i-1];
				end 
			end 
		end 
			assign o_valid=valid_r;
	end 
endgenerate 

endmodule 