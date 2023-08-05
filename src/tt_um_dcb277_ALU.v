`default_nettype none

module tt_um_dcb277_ALU #( parameter MAX_COUNT = 24'd10_000_000 ) (
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
    assign uio_oe = 8'b00000000;
    wire reset = ! rst_n;

    wire [6:0] led_out;
    wire [3:0] ALU_out;
    wire [3:0] A, B, adder_B;
    wire C_in, C1, C2, C3;
    wire [2:0] func;
    wire [3:0] add_out, and_out, or_out, xor_out;
    wire Ze,N,C4,V; 



    assign A = ui_in[3:0];
    assign B = ui_in[7:4];
    assign func = uio_in[2:0];

    assign Ze = ~(ALU_out[0] | ALU_out[1] | ALU_out[2] | ALU_out[3]);
    assign N = ALU_out[3];
    
    assign uo_out[6:0] = led_out;
    assign uo_out[7] = 1'b0;
    

    // Logical unit
    assign and_out = A & B;
    assign or_out = A | B;
    assign xor_out = A ^ B;

    // Adder unit
    assign add_out[0] = ((A[0] ^ adder_B[0]) ^ C_in);
    assign C1 = (((A[0] ^ adder_B[0]) & C_in) | (A[0] & B[0]));
    assign add_out[1] = ((A[1] ^ adder_B[1]) ^ C1);
    assign C2 = (((A[1] ^ adder_B[1]) & C1) | (A[1] & B[1]));
    assign add_out[2] = ((A[2] ^ adder_B[2]) ^ C2);
    assign C3 = (((A[2] ^ adder_B[2]) & C_in) | (A[2] & B[2]));
    assign add_out[3] = ((A[3] ^ adder_B[3]) ^ C3);
    assign C4 = (((A[3] ^ adder_B[3]) & C_in) | (A[3] & B[3]));

    assign V = (C3 ^ C4);

    parameter f_add = 3'b000;
    parameter f_sub = 3'b001;
    parameter f_and = 3'b010;
    parameter f_or = 3'b011;
    parameter f_xor = 3'b100;
    parameter f_pass = 3'b101;

    always @(func)
    begin
      case(func)
        f_add:  begin
          ALU_out = add_out; adder_B = B; C_in = 0;
        end
        f_sub: begin
           ALU_out = add_out; adder_B = ~B; C_in = 1;
        end
        f_and: begin
           ALU_out = and_out; adder_B = B; C_in = 0;
        end
        f_or: begin 
            ALU_out = or_out; adder_B = B; C_in = 0;
        end
        f_xor: begin
           ALU_out = xor_out; adder_B = B; C_in = 0;
        end
        f_pass: begin 
          ALU_out = A; adder_B = B; C_in = 0;
        end
        default: begin 
          ALU_out = A; adder_B = B; C_in = 0;
        end
      endcase
    end



    // instantiate segment display
    seg7 seg7(.counter(ALU_out), .segments(led_out));

endmodule
