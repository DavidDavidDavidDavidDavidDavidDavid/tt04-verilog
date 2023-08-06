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
    input wire [6:0] segments
);

    always @(*) begin
        case(segments)
            //                7654321
            7'b0111111: digit = 0;
            7'b0000110: digit = 1;
            7'b1011011: digit = 2;
            7'b1001111: digit = 3;
            7'b1100110: digit = 4;
            7'b1101101: digit = 5;
            7'b1111100: digit = 6;
            7'b0000111: digit = 7;
            7'b1111111: digit = 8;
            7'b1100111: digit = 9;
            default:    
                digit = 4'b1111;
        endcase
    end

endmodule