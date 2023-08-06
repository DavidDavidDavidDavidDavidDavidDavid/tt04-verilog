`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps
`include "tt_um_dcb277_ALU.v"
`include "tb_encoder.v"

module ALU_procedural_tb;

reg  clk;
wire  rst_n;
wire  ena;
wire  [7:0] ui_in;
wire  [7:0] uio_in;
reg [3:0] A,B,func; 

wire [6:0] segments = uo_out[6:0];
wire [7:0] uo_out;
wire [7:0] uio_out;
wire [7:0] uio_oe;

wire [3:0] Y;

assign ui_in[3:0] = A;
assign ui_in[7:4] = B;
assign uio_in[3:0] = func;

// duration for each bit = 20 * timescale = 20 * 1 ns  = 20ns
localparam period = 20;  

tt_um_dcb277_ALU UUT (.clk(clk), .rst_n(rst_n), .ena(ena), .ui_in(ui_in), .uio_in(uio_in), .uo_out(uo_out), .uio_out(uio_out), .uio_oe(uio_oe));
seg7_enc encoder (.segments(segments), .digit(Y));



assign rst_n = 1'b1;
assign ena = 1'b1;


parameter f_add = 4'b0000;
parameter f_sub = 4'b0001;
parameter f_and = 4'b0100;
parameter f_or =  4'b0101;
parameter f_xor = 4'b0110;
parameter f_sll = 4'b1000;
parameter f_srl = 4'b1001;
parameter f_sra = 4'b1010;
parameter f_pass = 4'b1111;

// note that sensitive list is omitted in always block
// therefore always-block run forever
// clock period = 2 ns
always 
begin
    clk = 1'b1; 
    #20; // high for 20 * timescale = 20 ns

    clk = 1'b0;
    #20; // low for 20 * timescale = 20 ns
end

always @(posedge clk)
begin
    // values for a and b
    A = 2;
    B = -2;
    func = f_add;

    #period
    $display(Y);
    $display("%B", uo_out);

    // display message if output not matched
    if(Y != 4)  
        $display("test failed for input combination 00");
    else $display("correct value");

    A = 2;
    B = 4;
    func = f_sub;

    #period
    $display(Y);
    // $display("%B", uo_out);

    // display message if output not matched
    if(Y != 0)  
        $display("test failed for input combination 00");
    else $display("correct value");

    A = 4'b0110;
    B = 4'b0110;
    func = f_and;

    #period
    $display("%B", Y);
    // $display("%B", uo_out);

    // display message if output not matched
    if(Y != 0)  
        $display("test failed for input combination 00");
    else $display("correct value");

    $stop;   // end of simulation
end
endmodule