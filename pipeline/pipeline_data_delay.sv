
module pipeline_data_delay #(parameter 
	LATENCY=2,
	DW=32

)(
	input clk,
	input [DW-1:0] in_data,
	output logic [DW-1:0] o_data
);

generate 
	if(LATENCY==0)begin:NO_DELAY
		assign o_data=in_data;
	end 
	else if (LATENCY==1)begin:DELAY1
		reg [DW-1:0] o_data_1r;
		always_ff@(posedge clk)begin
			o_data_1r <= in_data;
		end
		assign o_data = o_data_1r;
	end
	else begin:DWLAYN
		integer i;
		reg [DW-1:0] mem[LATENCY-2:0];
		reg [DW-1:0] o_data_1r;
		always_ff@(posedge clk)begin
			o_data_1r <= mem[LATENCY-2];
			for(i=LATENCY-2;i>=1;i--)begin
				mem[i]<=mem[i-1];
			end
			mem[0]<=in_data;
		end
		assign o_data=o_data_1r;
	end
endgenerate
endmodule 