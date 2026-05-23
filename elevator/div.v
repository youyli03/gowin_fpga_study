module div(
    input   clk,
    output  clk_div
);
 
localparam DIV_NUM      = 24999999;//自定义分频数
localparam DIV_ODD_EVEN = DIV_NUM%2;
localparam SWITCH_1TO0  = (DIV_NUM%2) ? (DIV_NUM - 1)/2 + 1 : DIV_NUM/2;
 
//localparam LEN          = int'($ceil($clog2(DIV_NUM)));
localparam LEN          = 25;
//以上system verilog语法用来确定cnt长度, 也可直接指定
 
 
reg [LEN-1:0]  cnt = 0;
reg            pos = 0;
reg            neg = 0;
 
 
//clk divide
assign clk_div = DIV_ODD_EVEN ? (pos && neg) : pos;
 
always @(posedge clk)begin
    if(cnt < DIV_NUM - 1) cnt <= cnt + 1;
    else cnt <= 0;
end
 
always @(negedge clk)begin
    if(cnt == 0) neg <= 1;
    else if(cnt == SWITCH_1TO0) neg <= 0;
    else neg <= neg;
end
 
always @(posedge clk)begin
    if(cnt == 0) pos <= 1;
    else if(cnt == SWITCH_1TO0) pos <= 0;
    else pos <= pos;
end
 
endmodule


                            