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

module seg7_enc (
    output reg [3:0] digit,
    input wire [6:0] segments,
    input wire N
);
    wire [7:0] full_val = {N, segments};

    always @(*) begin
        case(full_val)
            //                7654321
            8'b00111111: digit = 0;
            8'b00000110: digit = 1;
            8'b01011011: digit = 2;
            8'b01001111: digit = 3;
            8'b01100110: digit = 4;
            8'b01101101: digit = 5;
            8'b01111100: digit = 6;
            8'b00000111: digit = 7;
            8'b11111111: digit = -8;
            8'b10000111: digit = -7;
            8'b11111100: digit = -6;
            8'b11101101: digit = -5;
            8'b11100110: digit = -4;
            8'b11001111: digit = -3;
            8'b11011011: digit = -2;
            8'b10000110: digit = -1;

            default:    
                digit = 4'b1111;
        endcase
    end

endmodule