module top_mem_fpga (
    input  wire        clock,    
    input  wire        reset,    
    output wire [15:0] led      
);

    // ---------------------------------------------------------
    // 1. Clock Enable Generation (1 Hz)
    // ---------------------------------------------------------
    wire clk_en;
    // ---------------------------------------------------------
    // ---------------------------------------------------------
    // Memory Instantiations
    // ---------------------------------------------------------
    wire [31:0] instr_out;
    reg  [31:0] pc_reg;

    always @(posedge clk_en or posedge reset) begin
        if (reset)
            pc_reg <= 32'h0;
        else
            pc_reg <= pc_reg + 32'h4;
    end

    instr_mem uut_imem (
        .clk  (clock),
        .pc   (pc_reg),
        .instr(instr_out)
    );

    assign led = ~instr_out[15:0];

endmodule

//======================================================
// Clock Divider (clock enable generator)
//======================================================
module clock_divider #(
	parameter DIVISOR = 100_000_000
)(
	input  wire clk,
	input  wire reset,
	output reg  clk_en
);

	reg [26:0] counter;

	always @(posedge clk) begin
    	if (reset) begin
        	counter <= 27'd0;
        	clk_en  <= 1'b0;
    	end else if (counter == DIVISOR - 1) begin
        	counter <= 27'd0;
        	clk_en  <= 1'b1;   // one-cycle pulse
    	end else begin
        	counter <= counter + 1'b1;
        	clk_en  <= 1'b0;
    	end
	end

endmodule
