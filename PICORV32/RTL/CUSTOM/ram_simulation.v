module ram_simulation(
	input wire bus_valid,
	output reg bus_ready,

	input wire [31:0] bus_addr,
	input wire [31:0] bus_wdata,
	output reg [31:0] bus_rdata,
	input wire [3:0] bus_wstrb,
	
	input wire en,
	input wire clk,
	input wire resetn
	
);

	reg [31:0] ram_memory [1023:0];
	
	initial begin
		$readmemh("../../../SRC/executable.hex", ram_memory);
	end;
	
	always @(posedge clk) begin
		if (en == 1'b1) begin
			if (bus_wstrb == 4'b0000) begin
				bus_rdata <= ram_memory[bus_addr[11:2]];
			end else begin
				ram_memory[bus_addr[11:2]] <= bus_wdata;
			end;
		end;
	end;
	
	always @(posedge clk) begin
		if (resetn == 1'b0) begin
			bus_ready <= 1'b0;
		end else begin
			bus_ready <= en & !bus_ready;
		end;
	end;

endmodule