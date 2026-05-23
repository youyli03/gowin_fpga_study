module top(
    input clk   ,
    input rst_n ,

    output wire sdio_clk    ,
    inout       sdio_cmd    ,
    inout [3:0] sdio_data   ,
    input       sd_det      ,

    output wire led0        ,
    output wire led_sd_rst       
);
assign led0 = sd_det;

wire sd_rst_n, clk48m;
assign led_sd_rst = sd_rst_n;
sdio_top sdio_top0(
    .clk48mhz    (  clk48m      ),
    .rst_n       (  sd_rst_n    ),

    .sdio_clk    (  sdio_clk    ),
    .sdio_cmd    (  sdio_cmd    ),
    .sdio_data   (  sdio_data   )
);

Gowin_rPLL_48MHZ Gowin_rPLL_48MHZ0(
    .clkout (   clk48m      ), //output clkout
    .lock   (   sd_rst_n    ), //output lock
    .reset  (   ~rst_n      ), //input reset
    .clkin  (   clk         ) //input clkin
);

endmodule