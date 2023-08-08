`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps
`include "tt_um_dcb277_ALU.v"
`include "tb_encoder.v"

module ALU_procedural_tb;

reg  clk;
wire  rst_n;
wire  ena;
wire  [7:0] ui_in;
wire  [7:0] uio_in;
reg signed [3:0] A,B;
reg [3:0] func; 


wire [6:0] segments = uo_out[6:0];
wire [7:0] uo_out;
wire [7:0] uio_out;
wire [7:0] uio_oe;

wire signed [3:0] Y;
wire Ze,N,C,V;

assign ui_in[3:0] = A;
assign ui_in[7:4] = B;
assign uio_in[3:0] = func;
assign Ze = uio_out[7];
assign N = uio_out[6];
assign C = uio_out[5];
assign V = uio_out[4];

// duration for each bit = 20 * timescale = 20 * 1 ns  = 20ns
localparam period = 20;  

tt_um_dcb277_ALU UUT (.clk(clk), .rst_n(rst_n), .ena(ena), .ui_in(ui_in), .uio_in(uio_in), .uo_out(uo_out), .uio_out(uio_out), .uio_oe(uio_oe));
seg7_enc encoder (.segments(segments), .digit(Y), .N(N));



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
    A = 7;
    B = 4;
    func = f_add;

    #period // Give delay for register updates
    $display("Segment output: %B", uo_out); // The 7-seg output
    $display(Y); // The re-encoded 7-seg value
    $display("ZNCV"); // ALU flag key
    $display(Ze, N, C, V); // ALU flags

    // display message if output not matched
    if  ((Y != A+B) ||
         (Ze != 0) ||
         (N != 1) ||
         (C != 0) ||
         (V != 1)) // If the output is incorrect:
        begin
        $display("test failed");
        $display("correct value is: ", A+B);
        $display("correct flags: ", Ze,N,C,V);
        $finish;
        end
    else 
        $display("correct");

    $finish;   // end of simulation
end
endmodule