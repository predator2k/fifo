`resetall
`timescale 1ns / 1ps
`default_nettype none


module fifo
#(
    parameter DEPTH_WIDTH = 0,
    parameter DATA_WIDTH = 0
) 
(
    input  wire                   clk,
    input  wire                   rst_n,

    input  wire [DATA_WIDTH-1:0]  wr_data_i,
    input  wire                   wr_en_i,

    output wire [DATA_WIDTH-1:0]  rd_data_o,
    input  wire                   rd_en_i,

    output wire                   full_o,
    output wire                   empty_o
);

localparam DW = (DATA_WIDTH  < 1) ? 1 : DATA_WIDTH;
localparam AW = (DEPTH_WIDTH < 1) ? 1 : DEPTH_WIDTH;

initial begin
    if(DEPTH_WIDTH < 1)  begin
        $error("%m : DEPTH_WIDTH must be > 0");
        $finish;
    end
    if(DATA_WIDTH < 1) begin
        $error("%m : DATA_WIDTH must be > 0");
        $finish;
    end
end

reg [AW:0] write_pointer;
reg [AW:0] read_pointer;

wire empty_int = (write_pointer[AW] == read_pointer[AW]);
wire full_or_empty = (write_pointer[AW-1:0] == read_pointer[AW-1:0]);

assign full_o  = full_or_empty & !empty_int;
assign empty_o = full_or_empty & empty_int;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        read_pointer  <= 0;
        write_pointer <= 0;
    end else begin
        if (wr_en_i) begin
            write_pointer <= write_pointer + 1'd1;
        end
        if (rd_en_i) begin
            read_pointer <= read_pointer + 1'd1;
        end
    end
end

simple_dpram_sclk
#(
    .ADDR_WIDTH(AW),
    .DATA_WIDTH(DW),
    .ENABLE_BYPASS(1)
) fifo_ram (
    .clk(clk),
    .dout(rd_data_o),
    .raddr(read_pointer[AW-1:0]),
    .re(rd_en_i),
    .waddr(write_pointer[AW-1:0]),
    .we(wr_en_i),
    .din(wr_data_i)
);

endmodule
