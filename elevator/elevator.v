module elevator (CLK,RESET,ROW,COL,POSITION,LED);
    input CLK, RESET;
    input [3:0] ROW;
    output [3:0] COL;
    wire [7:0] KEY_VALUE;
    output reg [2:0] POSITION;
    output [7:0] LED;
    reg [2:0] P;
    reg [4:1] FLOOR;
    reg UP_DOWN;
    wire divclk;
    reg tmp, flag;
    integer temp;
    reg [8:0] CurrentState, NextState;
    parameter S0 = 9'b000000001, S1 = 9'b000000010, S2 = 9'b000000100, S3 = 9'b000001000, 
              S4 = 9'b000010000, S5 = 9'b000100000, S6 = 9'b001000000, S7 = 9'b010000000, S8 = 9'b100000000;

    reg [4:1] UP, DOWN, BUTTON;
    // 状态机和位置更新的主要always块
    div clk(
    .clk(CLK),
    .clk_div(divclk)
    );
    
    //always @(posedge CLK or negedge RESET) begin
    // LED <= 'b11111111;
    //end
    
    
    always @(posedge divclk or negedge RESET) begin
        if (~RESET) 
            CurrentState <= S0;  // 初始状态
        else
            CurrentState <= NextState;
    end

    // 控制逻辑
    always @(RESET or CurrentState or UP_DOWN or UP or DOWN or BUTTON or P or flag) begin
        if (~RESET) begin
            UP_DOWN = 0;
            FLOOR = 4'b0000;
               P=3'b001;
            flag = 0;
        end else begin
            if (flag == 0) FLOOR = UP_DOWN ? DOWN | BUTTON : UP | BUTTON;
            case (CurrentState)
                S0: begin
                POSITION <=P;
                    if (FLOOR <= 4'b0000) NextState <= S0;
                    else begin
                        if (UP_DOWN == 0) begin
                            if (P == 3'b100) UP_DOWN <= 1;
                            else begin
                                case (P)
                                    3'b001: tmp <= FLOOR[2] | FLOOR[3] | FLOOR[4];
                                    3'b010: tmp <= FLOOR[3] | FLOOR[4];
                                    3'b011: tmp <= FLOOR[4];
                                endcase
                                if (tmp == 0) begin
                                    FLOOR = DOWN | BUTTON;
                                    case (P)
                                        3'b001: tmp <= FLOOR[2] | FLOOR[3] | FLOOR[4];
                                        3'b010: tmp <= FLOOR[3] | FLOOR[4];
                                        3'b011: tmp <= FLOOR[4];
                                    endcase
                                    if (tmp == 0) UP_DOWN <= 1;
                                    else begin
                                        flag <= 1;
                                        UP_DOWN <= 0;
                                    end
                                end
                            end
                        end else begin
                            if (P == 3'b001) UP_DOWN <= 0;
                            else begin
                                case (P)
                                    3'b100: tmp <= FLOOR[3] | FLOOR[2] | FLOOR[1];
                                    3'b011: tmp <= FLOOR[2] | FLOOR[1];
                                    3'b010: tmp <= FLOOR[1];
                                endcase
                                if (tmp == 0) begin
                                    FLOOR = UP | BUTTON;
                                    case (P)
                                        3'b100: tmp <= FLOOR[3] | FLOOR[2] | FLOOR[1];
                                        3'b011: tmp <= FLOOR[2] | FLOOR[1];
                                        3'b010: tmp <= FLOOR[1];
                                    endcase
                                    if (tmp == 0) UP_DOWN <= 0;
                                    else begin
                                        flag <= 1;
                                        UP_DOWN <= 1;
                                    end
                                end
                            end
                        end
                        NextState = S1;
                    end
                end
                S1: NextState = S2;
                S2: NextState = S3;
                S3: NextState = S4;
                S4: begin
                    if (UP_DOWN == 0) NextState = S5;
                    else NextState = S6;
                end
                S5: begin
                    if (FLOOR == 4'b0000) NextState = S0;
                    else begin
                        P = P + 1'b1;
                        if (flag == 1) begin: B1
                            integer i;
                            temp = 0;
                            for (i = 4; i > 0 && temp == 0; i = i - 1)
                                if (FLOOR[i] == 1) temp = i;
                            if (P == temp) begin
                                flag = 0;
                                UP_DOWN = 1;
                                NextState = S0;
                            end else NextState = S7;
                        end else begin
                            if (FLOOR[P]) NextState = S0;
                            else NextState = S7;
                        end
                    end
                end
                S6: begin
                    if (FLOOR == 4'b0000) NextState = S0;
                    else begin
                        P = P - 1'b1;
                        if (flag == 1) begin: B2
                            integer i;
                            temp = 0;
                            for (i = 1; i < 5 && temp == 0; i = i + 1)
                                if (FLOOR[i] == 1) temp = i;
                            if (P == temp) begin
                                flag = 0;
                                UP_DOWN = 0;
                                NextState = S0;
                            end else NextState = S8;
                        end else begin
                            if (FLOOR[P]) NextState = S0;
                            else NextState = S8;
                        end
                    end
                end
                S7: NextState = S5;
                S8: NextState = S6;
            endcase
        end
    end

    // 实例化sled模块
    sled led_control (
        .POSITION(P),
        .FLOOR_REQUEST(FLOOR),
        .UP(UP_DOWN == 0),
        .DOWN(UP_DOWN == 1),
        .LED(LED),
        .key(KEY_VALUE)
    );
    //实例化key4x4_driver模块
    key4x4_driver keypad (
        .clk(CLK),
        .reset(RESET),
        .row(ROW),
        .col(COL),
        .key_value(KEY_VALUE)
    );


    // 根据按键值解码楼层请求

    always @(posedge CLK or negedge RESET) begin

        if (!RESET) begin

            UP <= 4'b0000;

            DOWN <= 4'b0000;

            BUTTON <= 4'b0000;

        end else begin

            // 根据KEY_VALUE来更新UP, DOWN, BUTTON信号
            case (KEY_VALUE)
                8'd0: UP <= 'b0001;      
                8'd1: UP <= 'b0010;   
                8'd2: UP <= 'b0100;   
                8'd3: UP <= 'b1000;  
                
                8'd4: DOWN <= 'b0001;
                8'd5: DOWN <= 'b0010;
                8'd6: DOWN <= 'b0100;   
                8'd7: DOWN <= 'b1000;
                
                8'd8: BUTTON <= 'b0001;  
                8'd9: BUTTON <= 'b0010;  
                8'd10: BUTTON <= 'b0100;  
                8'd11: BUTTON <= 'b1000;
                // ... 添加其他按键对应的行为

                // 注意：需要根据具体的键盘布局和需求来设置这些按键的功能

                

                // 清除信号（当没有按键按下时）

                8'hFF: begin

                    UP <= 4'b0000;

                    DOWN <= 4'b0000;

                    BUTTON <= 4'b0000;

                end

            endcase

        end

    end

endmodule