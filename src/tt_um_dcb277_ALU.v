`default_nettype none

module adder (
    input   wire [3:0]  A,
    input   wire [3:0]  B,
    input   wire        C_in,
    output  wire [3:0]  Y,
    output  wire        C_out,
    output  wire        V
);
    // Adder unit
    wire C1,C2,C3;

    assign Y[0] = ((A[0] ^ B[0]) ^ C_in);
    assign C1 = (((A[0] ^ B[0]) & C_in) | (A[0] & B[0]));

    assign Y[1] = ((A[1] ^ B[1]) ^ C1);
    assign C2 = (((A[1] ^ B[1]) & C1) | (A[1] & B[1]));

    assign Y[2] = ((A[2] ^ B[2]) ^ C2);
    assign C3 = (((A[2] ^ B[2]) & C2) | (A[2] & B[2]));

    assign Y[3] = ((A[3] ^ B[3]) ^ C3);
    assign C_out = (((A[3] ^ B[3]) & C3) | (A[3] & B[3]));

    assign V = (C3 ^ C_out);

endmodule

module tt_um_dcb277_ALU (
    input  wire [7:0] ui_in,    // Dedicated inputs - connected to the input switches
    output wire [7:0] uo_out,   // Dedicated outputs - connected to the 7 segment display
    input  wire [7:0] uio_in,   // IOs: Bidirectional Input path
    output wire [7:0] uio_out,  // IOs: Bidirectional Output path
    output wire [7:0] uio_oe,   // IOs: Bidirectional Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);


  // use bidirectionals
    assign uio_oe = 8'b11110000;
    wire reset = ! rst_n;

    wire [6:0] led_out;
    wire [3:0] ALU_out;
    wire [3:0] A, B, adder_B;
    wire C_in;
    wire neg_B;
    wire [2:0] func;
    wire [3:0] add_out, and_out, or_out, xor_out;
    wire Ze,N,C,V; //ALU flags

    assign A = ui_in[3:0];
    assign B = ui_in[7:4];
    assign func = uio_in[2:0];

    assign uio_out[7] = Ze;
    assign uio_out[6] = N;
    assign uio_out[5] = C;
    assign uio_out[4] = V;

    assign Ze = ~(ALU_out[0] | ALU_out[1] | ALU_out[2] | ALU_out[3]);
    assign N = ALU_out[3];
    
    assign uo_out[6:0] = led_out;
    assign uo_out[7] = 1'b0;
    

    // Logical unit
    assign and_out = A & B;
    assign or_out = A | B;
    assign xor_out = A ^ B;

    parameter f_add = 3'b000;
    parameter f_sub = 3'b001;
    parameter f_and = 3'b010;
    parameter f_or = 3'b011;
    parameter f_xor = 3'b100;
    parameter f_pass = 3'b101;

    assign neg_B = (func[0] == 1) ? 1'b1 : 1'b0;

    assign C_in    =  ((neg_B) ? 1'b1 : 1'b0);
    assign adder_B =  ((neg_B) ? ~B : B);

    assign ALU_out =  (func == f_add) ? add_out:
                      (func == f_sub) ? add_out:
                      (func == f_and) ? and_out:
                      (func == f_or)  ? or_out:
                      (func == f_xor) ? xor_out:
                                        A;

    adder adder(.A(A), .B(adder_B), .C_in(C_in), .Y(add_out), .V(V), .C_out(C));

    // instantiate segment display
    seg7 seg7(.counter(ALU_out), .segments(led_out));

endmodule
