`default_nettype none

/*
      -- 1 --
     |       |
     6       2
     |       |
      -- 7 --
     |       |
     5       3
     |       |
      -- 4 --
*/

module seg7 (
    input wire [3:0] counter,
    output reg [6:0] segments
);

    always @(*) begin
        case(counter)
            //                7654321
            0:  segments = 7'b0111111;
            1:  segments = 7'b0000110;
            2:  segments = 7'b1011011;
            3:  segments = 7'b1001111;
            4:  segments = 7'b1100110;
            5:  segments = 7'b1101101;
            6:  segments = 7'b1111100;
            7:  segments = 7'b0000111;
            8:  segments = 7'b1111111;
            9:  segments = 7'b1100111;
            default:    
                segments = 7'b0000000;
        endcase
    end

endmodule

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

module shifter (
    input wire [3:0] A,
    input wire [1:0] S,
    output wire [3:0] Y
);

  wire [3:0] SLL, SRL, SRA;

  assign SLL = A<<1;
  assign SRL = A>>1;
  assign SRA = A>>>1;

  assign Y =  (S == 2'b00) ?  SLL:
              (S == 2'b01) ?  SRL:
                              SRA;

endmodule

module logical (
    input wire [3:0] A,
    input wire [3:0] B,
    input wire [1:0] S,
    output wire [3:0] Y
);

    wire [3:0] l_and, l_or, l_xor;

    // Logical unit
    assign l_and = A & B;
    assign l_or = A | B;
    assign l_xor = A ^ B;

    assign Y =  (S == 2'b00) ?  l_and   :
                (S == 2'b01) ?  l_or    :
                                l_xor;
                            
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
    wire [3:0] func;
    wire [3:0] add_out, logic_out, shift_out;
    wire Ze,N,C,V; //ALU flags

    assign A = ui_in[3:0];
    assign B = ui_in[7:4];
    assign func = uio_in[2:0];

    assign uio_out[7] = Ze;
    assign uio_out[6] = N;
    assign uio_out[5] = C;
    assign uio_out[4] = V;
    assign uio_out[3:0] = 4'b0000;

    assign Ze = ~(ALU_out[0] | ALU_out[1] | ALU_out[2] | ALU_out[3]);
    assign N = ALU_out[3];
    
    assign uo_out[6:0] = led_out;
    assign uo_out[7] = 1'b0;
    
  
    parameter f_add = 4'b0000;
    parameter f_sub = 4'b0001;
    parameter f_and = 4'b0100;
    parameter f_or =  4'b0101;
    parameter f_xor = 4'b0110;
    parameter f_sll = 4'b1000;
    parameter f_srl = 4'b1001;
    parameter f_sra = 4'b1010;
    parameter f_pass = 4'b1111;

    assign neg_B = (func[0] == 1) ? 1'b1 : 1'b0;

    assign C_in    =  ((neg_B) ? 1'b1 : 1'b0);
    assign adder_B =  ((neg_B) ? ~B : B);
    assign ALU_out =  (func == f_add) ? add_out:
                      (func == f_sub) ? add_out:
                      (func == f_and) ? logic_out:
                      (func == f_or)  ? logic_out:
                      (func == f_xor) ? logic_out:
                      (func == f_sll) ? shift_out:
                      (func == f_srl) ? shift_out:
                      (func == f_sra) ? shift_out:
                                        A;

    logical logical(.A(A), .B(B), .S(func[1:0]), .Y(logic_out));

    shifter shifter(.A(A), .S(func[1:0]), .Y(shift_out));

    adder adder(.A(A), .B(adder_B), .C_in(C_in), .Y(add_out), .V(V), .C_out(C));

    // instantiate segment display
    seg7 seg7(.counter(ALU_out), .segments(led_out));

endmodule
