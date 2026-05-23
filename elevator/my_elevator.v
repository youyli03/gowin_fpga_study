module elevator (
    input clk,
    input rst,
    input [3:0] row,
    input wait_delay_en,

    output [3:0] col,
    output reg [2:0] pos,
    output [7:0] led
);
    
wire stop, up_empty, down_empty, botton_empty;
reg [3:0] up, down, button, status, status_target;
reg up_down;
reg delay_en, delay_down;
reg ctl_delay_cnt;
wire [7:0] key_val;

// reg wait_delay_en;
wire [3:0] up_btn, down_btn;
assign up_btn = up | button;
assign down_btn = down | button;

assign stop = up_empty & down_empty ;
// assign up_empty = (up[2:0] == 'b0)?'b1:'b0;
assign up_empty = (((up|button|down) >> (pos + 'd1)) != 0)?'b0:'b1;
wire up_empty_tar;
assign up_empty_tar = (((up|button|down) >> (pos + 'd2)) != 0)?'b0:'b1;
// assign down_empty = (down[3:1] == 'b0)?'b1:'b0;
assign down_empty = ((((up|down|button) << ('d4 - pos))&'b1111) != 0)?'b0:'b1;
assign botton_empty = (button == 'b0)?'b1:'b0;

// parameter RUN_DELAY_CNT = 32'd50_000_000;
parameter RUN_DELAY_CNT = 32'd5_000;
parameter WAIT_DELAY_CNT = 32'd5_000;

localparam 
    ELEVATOR_IDLE   = 4'd0,
    ELEVATOR_UP     = 4'd1,
    ELEVATOR_DOWN   = 4'd2,
    ELEVATOR_RUN_DELAY  = 4'd3,
    ELEVATOR_WAIT_DELAY = 4'd4,
    ELEVATOR_DELAY  = 4'd5;

assign led[3:0] = ~('b1 << pos); 
assign led[4] = (status == ELEVATOR_UP || status_target == ELEVATOR_UP)?'b0:'b1;
assign led[5] = (status == ELEVATOR_DOWN || status_target == ELEVATOR_DOWN)?'b0:'b1;
assign led[6] = (status == ELEVATOR_RUN_DELAY)?'b0:'b1;
assign led[7] = (wait_delay_en == 'b1)?'b0:'b1;

reg [31:0] delay_cnt_target;

always @(posedge clk or negedge rst) begin
    if(~rst)begin
        status <= ELEVATOR_IDLE;
        pos <= 'd0;
        up <= 0;
        down <= 0;
        button <= 0;
        delay_en <= 0;
        ctl_delay_cnt <= 'b0;
    end else begin
        case (status)
        ELEVATOR_IDLE:begin
            if(!ctl_delay_cnt) begin
                up <= up & (~(4'd1 << pos));
                down <= down & (~(4'd1 << pos));
                button <= button & (~(4'd1 << pos));
                ctl_delay_cnt <= 'b1;
            end else begin
                if(!stop) begin
                    if(!up_empty )begin
                        status_target <= ELEVATOR_UP;
                        status <= ELEVATOR_RUN_DELAY;
                    end
                    else if(!down_empty)begin
                        status_target <= ELEVATOR_DOWN;
                        status <= ELEVATOR_RUN_DELAY;
                    end
                end else begin
                    status <= ELEVATOR_IDLE;
                end
                ctl_delay_cnt <= 'b0;
            end
        end
        ELEVATOR_UP:begin
            if(stop) begin 
                if(pos == 'b0)
                    status <= ELEVATOR_IDLE;
                else begin
                    status_target <= ELEVATOR_DOWN;
                    status <= ELEVATOR_RUN_DELAY;
                end
            end else if(pos == 'd3 || up_empty == 'b1) begin
                status_target <= ELEVATOR_DOWN;
                status  <= ELEVATOR_RUN_DELAY;
            end
            else begin
                status_target <= ELEVATOR_UP;
                status  <= ELEVATOR_RUN_DELAY;
            end
        end
        ELEVATOR_DOWN:begin
            if(stop) begin 
                if(pos == 'b0)
                    status <= ELEVATOR_IDLE;
                else begin
                    status_target <= ELEVATOR_DOWN;
                    status <= ELEVATOR_RUN_DELAY;
                end
            end else if(pos == 'd0 || down_empty == 'b1) begin
                status_target <= ELEVATOR_UP;
                status <= ELEVATOR_RUN_DELAY;
            end else begin
                status_target <= ELEVATOR_DOWN;
                status <= ELEVATOR_RUN_DELAY;
            end
            ctl_delay_cnt <= 'b0;
        end
        ELEVATOR_RUN_DELAY:begin
            delay_cnt_target <= RUN_DELAY_CNT;
            if(!delay_down && !delay_en) begin
                delay_en <= 'b1;
            end
            if(delay_down && delay_en) begin
                delay_en <= 'b0;
                case (status_target)
                    ELEVATOR_UP:begin
                        pos <= pos + 'b1;
                        // if( up_btn[pos+'b1] == 1 ) begin
                        if((up_btn[pos+'b1] == 1) || up_empty_tar) begin
                            up[pos+'b1] <= 'b0;
                            button[pos+'b1] <= 'b0;
                            if(up_empty_tar) begin
                                down[pos+'b1] <= 'b0;
                            end
                            status <= ELEVATOR_WAIT_DELAY;
                        end else begin
                            status <= ELEVATOR_UP;
                        end
                    end
                    ELEVATOR_DOWN:begin
                        pos <= pos - 'b1;
                        if(up_btn[pos-'b1] == 1) begin
                            down[pos-'b1] <= 'b0;
                            button[pos-'b1] <= 'b0;
                            status <= ELEVATOR_WAIT_DELAY;
                        end else begin
                            status <= ELEVATOR_DOWN;
                        end
                    end
                endcase
            end
        end
        ELEVATOR_WAIT_DELAY:begin
            delay_cnt_target <= WAIT_DELAY_CNT;
            if(!delay_down && !delay_en) begin
                delay_en <= 'b1;
            end
            if(delay_down && delay_en) begin
                delay_en <= 'b0;
                case (status_target)
                    ELEVATOR_UP:begin
                        status <= ELEVATOR_UP;
                    end
                    ELEVATOR_DOWN:begin
                        status <= ELEVATOR_DOWN;
                    end
                endcase
            end
        end
        endcase
        if(!delay_down) begin
    case (key_val)
        8'd0: up <= (up|'b0001 )& (~(4'd1 << pos));      
        8'd1: up <= (up|'b0010 )& (~(4'd1 << pos));   
        8'd2: up <= (up|'b0100 )& (~(4'd1 << pos));   
        8'd3: up <= (up|'b1000 )& (~(4'd1 << pos));  
        
        8'd4: down <= (down|'b0001)& (~(4'd1 << pos));
        8'd5: down <= (down|'b0010)& (~(4'd1 << pos));
        8'd6: down <= (down|'b0100)& (~(4'd1 << pos));   
        8'd7: down <= (down|'b1000)& (~(4'd1 << pos));
        
        8'd8:  button <= (button|'b0001)& (~(4'd1 << pos));  
        8'd9:  button <= (button|'b0010)& (~(4'd1 << pos));  
        8'd10: button <= (button|'b0100)& (~(4'd1 << pos));  
        8'd11: button <= (button|'b1000)& (~(4'd1 << pos));
    endcase
        end
    end
end

reg delay_bef, delay_beg;
reg wait_delay_bef;
reg [31:0] delay_cnt;
always @(posedge clk or negedge rst) begin
    if(~rst)begin
        delay_down <= 'b0;
        delay_bef <= 'b0;
        delay_beg <= 'b0;
        delay_cnt <= 'b0;
    end else begin
        delay_bef <= delay_en;
        wait_delay_bef <= wait_delay_en;
        if(delay_bef == 'b0 && delay_en == 'b1)begin
            delay_beg <= 'b1;
            delay_down <= 'b0;
            delay_cnt <= 'b0;
        end else if(delay_beg && delay_cnt != delay_cnt_target)begin
            delay_cnt <= delay_cnt + 'b1;
            if(wait_delay_bef == 'b0 && wait_delay_en == 'b1 && status == ELEVATOR_WAIT_DELAY) delay_cnt <= 'b0;
        end else if(delay_cnt == delay_cnt_target && delay_down == 'b0)begin
            delay_down <= 'b1;
            delay_beg <= 0;
            delay_cnt <= 0;
        end
        if(delay_down && delay_en == 'b0)
            delay_down <= 'b0;
    end
end

key4x4_driver keypad (
    .clk(clk),
    .reset(rst),
    .row(row),
    .col(col),
    .key_value(key_val)
);

endmodule