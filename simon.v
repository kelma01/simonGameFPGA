`timescale 1ns / 1ps
module simon(
    input clk,
    input btnR, //fpga buttons
    input btnD,
    input btnU,
    input btnL,
    input btnC,
    output reg[3:0] led,
    output [6:0] seg,
    output [3:0] an
    );
    
    localparam START_STATE = 'b00;
    localparam LED_STATE = 'b01;
    localparam INPUT_STATE = 'b10;
    localparam FAIL_STATE = 'b11;
    
    reg[31:0] counter;//used for slowing down the clk
    reg[1:0] state = START_STATE;
    reg blink = 0;//little cute xd animation before the game start
    reg[6:0] score = 'd0;//reg that holds score, then it will be assigned into "an" output
    reg[3:0] colors[100:0];//array that contains game pattern
    reg[6:0] button_counter = 'd0;  //saves the number inputs given by user in INPUT_STATE
    reg[6:0] color_counter = 0;    //decides how many colors will be represented, limited by score value
    reg[31:0] timeout = 0; //in INPUT_STATE, according to the score, gives user a time for inputs
    reg btnC_next,btnR_next,btnL_next,btnD_next,btnU_next = 0;
    reg game_started = 'b0; //defined for sevenSeg module
    
    sevenSeg an0(.clk(clk),.score(score-1),.game_started(game_started),.seg(seg),.an(an));
    
    initial begin   //colorsin tanýmlanmasý
        colors[0] = 'b0001;colors[1] = 'b1000;colors[2] = 'b0010;colors[3] = 'b0100;colors[4] = 'b0001;colors[5] = 'b1000;colors[6] = 'b0001;colors[7] = 'b0100;
        colors[8] = 'b0010;colors[9] = 'b1000;colors[10] = 'b0001;colors[11] = 'b0100;colors[12] = 'b1000;colors[13] = 'b0010;colors[14] = 'b1000;colors[15] = 'b0001;
        colors[16] = 'b0010;colors[17] = 'b0100;colors[18] = 'b1000;colors[19] = 'b0001;colors[20] = 'b0010;colors[21] = 'b0100;colors[22] = 'b0001;colors[23] = 'b1000;
        colors[24] = 'b0100;colors[25] = 'b0010;colors[26] = 'b1000;colors[27] = 'b0100;colors[28] = 'b1000;colors[29] = 'b0001;colors[30] = 'b0100;colors[31] = 'b0001;
        colors[32] = 'b0100;colors[33] = 'b1000;colors[34] = 'b0010;colors[35] = 'b0100;colors[36] = 'b0001;colors[37] = 'b1000;colors[38] = 'b0001;colors[39] = 'b0100;
        colors[40] = 'b0010;colors[41] = 'b1000;colors[42] = 'b0001;colors[43] = 'b0100;colors[44] = 'b1000;colors[45] = 'b0010;colors[46] = 'b1000;colors[47] = 'b0001;
        colors[48] = 'b0010;colors[49] = 'b0100;colors[50] = 'b1000;colors[51] = 'b0001;colors[52] = 'b0010;colors[53] = 'b0100;colors[54] = 'b0001;colors[55] = 'b1000;
        colors[56] = 'b0100;colors[57] = 'b0010;colors[58] = 'b1000;colors[59] = 'b0100;colors[60] = 'b1000;colors[61] = 'b0001;colors[62] = 'b0100;colors[63] = 'b0001;
        colors[64] = 'b0100;colors[65] = 'b1000;colors[66] = 'b0010;colors[67] = 'b0100;colors[68] = 'b0001;colors[69] = 'b1000;colors[70] = 'b0001;colors[71] = 'b0100;
        colors[72] = 'b0010;colors[73] = 'b1000;colors[74] = 'b0001;colors[75] = 'b0100;colors[76] = 'b1000;colors[77] = 'b0010;colors[78] = 'b1000;colors[79] = 'b0001;
        colors[80] = 'b0010;colors[81] = 'b0100;colors[82] = 'b1000;colors[83] = 'b0001;colors[84] = 'b0010;colors[85] = 'b0100;colors[86] = 'b0001;colors[87] = 'b1000;
        colors[88] = 'b0100;colors[89] = 'b0010;colors[90] = 'b1000;colors[91] = 'b0100;colors[92] = 'b1000;colors[93] = 'b0001;colors[94] = 'b0100;colors[95] = 'b0001;
        colors[96] = 'b0001;colors[97] = 'b0001;colors[98] = 'b0001;colors[99] = 'b0001;colors[100] = 'b0001;
    end
    always@(posedge clk) begin  //slowing down the clock
        if(counter == 10**8/2)begin
            counter = 0;
        end
        counter = counter + 1;
    end
    always@(posedge clk)begin
        btnC_next <= btnC;  
        btnU_next <= btnU;
        btnD_next <= btnD;
        btnR_next <= btnR;
        btnL_next <= btnL;
        
        if(counter == 10**8/2)begin
            timeout = timeout + 1;
        end
        
        if(btnC_next)begin   //when pressed the middle button(btnC), resets everything and starts the game
            score = 1 ;
            timeout = 0;
            color_counter = 0;
            button_counter = 0;
            state = LED_STATE;
            game_started = 'b1;
        end
        if(state == START_STATE && counter == 10**8/2)begin  //state that game waiting to be played
            led[0] <= blink;
            led[1] <= ~blink;
            led[2] <= blink;
            led[3] <= ~blink;
            blink <= ~blink;
        end
        else if(state == LED_STATE && counter == 10**8/2)begin 
            led = colors[color_counter];
            color_counter = color_counter + 1;
            if(color_counter == score+1)begin //displays the colors till the number of score and when this if blocks works, it means it is time to take input from user
                color_counter = 0;
                button_counter = 0;
                timeout = 'd0;
                state = INPUT_STATE;
            end
        end
        else if(state == INPUT_STATE)begin 
            led = 'b0000;
            if(timeout >= score * 3 + 1) //timeout check for the user input time
                state = FAIL_STATE;
            if(colors[color_counter] == 'b0001)begin
                if(btnU_next == 1)begin
                    button_counter = button_counter + 1;
                    color_counter = color_counter + 1;
                end
            end
            else if(colors[color_counter] == 'b0010)begin
                if(btnR_next == 1)begin
                    color_counter = color_counter + 1;
                    button_counter = button_counter + 1;
                end
            end
            else if(colors[color_counter] == 'b0100)begin
                if(btnD_next == 1)begin
                    color_counter = color_counter + 1;
                    button_counter = button_counter + 1;
                end
            end
            else if(colors[color_counter] == 'b1000)begin
                if(btnL_next == 1)begin
                    color_counter = color_counter + 1;
                    button_counter = button_counter + 1;
                end
            end
            if ((btnU_next && (colors[(color_counter-1)] != 'b0001)) ||	//reason of -1 is we increased color_counter previously, but we have to check it was true or not
                (btnR_next && (colors[(color_counter-1)] != 'b0010)) ||
                (btnD_next && (colors[(color_counter-1)] != 'b0100)) ||
                (btnL_next && (colors[(color_counter-1)] != 'b1000))) begin
                state = FAIL_STATE; 
            end
            if(button_counter == score)begin  //if our state is this, it means no problem. score gets increased, time for the next round
                score = score + 1;
                color_counter = 'd0;
                button_counter = 'd0;
                led = 'b0000;
                state = LED_STATE;
            end
            if(skor-1 == 100)    //finish score of the game, doesn't go infinitely
                state = FAIL_STATE;
        end
        else if(state == FAIL_STATE)begin
            button_counter = 'd0;
            color_counter = 'd0;
            state = START_STATE; 
        end
    end
endmodule