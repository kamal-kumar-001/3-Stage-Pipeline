
module top_module (
    input  wire        clock,      
    input  wire        reset,      
    output wire  [15:0] led        
);


reg [7:0] addr = 0;

(* rom_style = "block" *)
reg [138:0] stimulus_mem [0:16];

initial begin
    $readmemb("input_ex_b.mem", stimulus_mem);
end

// Clock Divider
clock_divider #(
    .DIVISOR(100_000_000)
) clk_div_u (
    .clk   (clock),
    .reset (reset),
    .clk_en(clk)
);

always @(posedge clk) begin
    if (!reset)
        addr <= 0;
    else begin
        if (addr == 16)
            addr <= 0;
        else
            addr <= addr + 1;
    end
end

wire [138:0] stim = stimulus_mem[addr];

// Unpack inputs from stimulus trace
wire [31:0] reg_rdata1   = stim[138:107];
wire [31:0] reg_rdata2   = stim[106:75];
wire [31:0] execute_imm  = stim[74:43];
wire [31:0] pc           = stim[42:11];
wire [31:0] fetch_pc     = stim[10:11]; // default or zero-extended
wire        immediate_sel = stim[10];
wire        mem_write     = stim[9];
wire        jal           = stim[8];
wire        jalr          = stim[7];
wire        lui           = stim[6];
wire        alu           = stim[5];
wire        branch        = stim[4];
wire        arithsubtype  = stim[3];
wire        mem_to_reg    = stim[2];
wire        stall_read    = 1'b0;

wire [4:0]  dest_reg_sel  = stim[1:0]; // placeholder slice
wire [2:0]  alu_op        = 3'b000;
wire [1:0]  dmem_raddr    = 2'b00;

wire        wb_branch_i     = 1'b0;
wire        wb_branch_nxt_i = 1'b0;


////////////////////////////////////////////////////////////// DUT OUTPUTS////////////////////////////////////////////////////////////
    wire [31:0] alu_operand1;
    wire [31:0] alu_operand2;
    wire [31:0] write_address;
    wire        branch_stall;

    wire [31:0] next_pc;
    wire        branch_taken;

    // -----------------------------
    // EX → WB
    // -----------------------------
    wire [31:0] wb_result;
    wire        wb_mem_write;
    wire        wb_alu_to_reg;
    wire [4:0]  wb_dest_reg_sel;
    wire        wb_branch;
    wire        wb_branch_nxt;
    wire        wb_mem_to_reg;
    wire [1:0]  wb_read_address;
    wire [2:0]  mem_alu_operation;

////////////////////////////////////////////////////////////// DUT INSTANCE////////////////////////////////////////////////////////////
execute dut (
    .clk               (clk),
    .reset             (reset),

    .reg_rdata1        (reg_rdata1),
    .reg_rdata2        (reg_rdata2),
    .execute_imm       (execute_imm),
    .pc                (pc),
    .fetch_pc          (fetch_pc),

    .immediate_sel     (immediate_sel),
    .mem_write         (mem_write),
    .jal               (jal),
    .jalr              (jalr),
    .lui               (lui),
    .alu               (alu),
    .branch            (branch),
    .arithsubtype      (arithsubtype),
    .mem_to_reg        (mem_to_reg),
    .stall_read        (stall_read),

    .dest_reg_sel      (dest_reg_sel),
    .alu_op            (alu_op),
    .dmem_raddr        (dmem_raddr),

    .wb_branch_i       (wb_branch_i),
    .wb_branch_nxt_i   (wb_branch_nxt_i),

    .alu_operand1     (alu_operand1),
    .alu_operand2     (alu_operand2),
    .write_address    (write_address),

    .next_pc           (next_pc),
    .branch_taken      (branch_taken),
    .branch_stall      (branch_stall),

    .wb_result         (wb_result),
    .wb_mem_write      (wb_mem_write),
    .wb_alu_to_reg     (wb_alu_to_reg),
    .wb_dest_reg_sel   (wb_dest_reg_sel),
    .wb_branch         (wb_branch),
    .wb_branch_nxt     (wb_branch_nxt),
    .wb_mem_to_reg     (wb_mem_to_reg),
    .wb_read_address   (wb_read_address),
    .mem_alu_operation (mem_alu_operation)
);


assign led =   wb_dest_reg_sel ;

endmodule

module clock_divider(
    input  wire clk,
    input  wire reset,
    output reg  clk_en
);
    parameter DIVISOR = 100_000_000;
    reg [26:0] counter;

    always @(posedge clk) begin
        if (!reset) begin
            counter <= 0;
            clk_en <= 1'b0;
        end
        else if (counter == DIVISOR-1) begin
            counter <= 0;
            clk_en <= ~clk_en;
        end
        else begin
            counter <= counter + 1;
        end
    end
    
endmodule

