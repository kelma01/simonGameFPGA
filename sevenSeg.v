`timescale 1ns / 1ps
module sevenSeg(
    input clk,
    input[6:0] score,
    input game_started,
    output reg[6:0] seg,
    output reg[3:0] an
    );
    
    reg[6:0] score_r;
    reg[3:0] ones;    //game ends at score 100, we don't need hundreds and thousends on 7seg dipslay
    reg[3:0] tens;
    
    localparam ZERO = 'b1000000;
    localparam ONE = 'b1111001;
    localparam TWO = 'b0100100;
    localparam THREE = 'b0110000;
    localparam FOUR = 'b0011001;
    localparam FIVE = 'b0010010;
    localparam SIX = 'b0000010;
    localparam SEVEN = 'b1111000;
    localparam EIGHT = 'b0000000;
    localparam NINE = 'b0010000;
    
    initial begin
        seg = 'b1000000;
    end
    
    reg[31:0] counter;
    reg[31:0] counter2;
    reg clk2;
    
    always@(posedge clk)begin   //slowing down clk2
        counter2 = counter2+1;
        if(counter2 == 10**5/2)begin
            clk2 = ~clk2;
            counter2 = 1;
        end
    end
    always@(posedge clk2)begin
        if(!game_started)   //keeps 7seg display closed till game starts
            an = 'b1111;
        else begin
            score_r = score;
            ones = score % 10;
            score_r = (score_r - ones)/10;
            tens = score_r % 10;
            
            if(counter == 0)begin
                case (tens)
                    0: seg = ZERO;
                    1: seg = ONE;
                    2: seg = TWO;
                    3: seg = THREE;
                    4: seg = FOUR;
                    5: seg = FIVE;
                    6: seg = SIX;
                    7: seg = SEVEN;
                    8: seg = EIGHT;
                    9: seg = NINE;
                endcase
                an = 'b1101;
                counter = 1;
            end
            else begin
                case (ones)
                    0: seg = ZERO;
                    1: seg = ONE;
                    2: seg = TWO;
                    3: seg = THREE;
                    4: seg = FOUR;
                    5: seg = FIVE;
                    6: seg = SIX;
                    7: seg = SEVEN;
                    8: seg = EIGHT;
                    9: seg = NINE;
                endcase
                an = 'b1110;
                counter = 0;
            end
        end
    end
endmodule