module tb();

reg clk = 0;
reg rst = 0;
wire [3:0] row_tar;
wire [3:0] col_tar;
reg [7:0] key_val;
always#1 clk = ~clk;

wire [3:0] row, col;
assign row = (col == col_tar)?row_tar:'b1111;
assign {col_tar,row_tar} = key_val;

reg wait_delay_en = 0;

initial begin
    rst = 0;
    #10 
    rst = 1;
    #600 
    key_val = 8'b1101_1011;
    #3000 
    key_val = 8'b1111_1111;
end

elevator  elevator0(
    .clk(clk),
    .rst(rst),
    .row(row),
    .col(col),
    .wait_delay_en(wait_delay_en)
);


endmodule
