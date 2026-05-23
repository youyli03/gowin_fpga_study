//Copyright (C)2014-2023 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//GOWIN Version: V1.9.9 Beta-5
//Part Number: GW2A-LV18PG256CC8/I7
//Device: GW2A-18
//Created Time: Sat Dec 02 13:58:38 2023

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    Gowin_rPLL_48MHZ your_instance_name(
        .clkout(clkout_o), //output clkout
        .lock(lock_o), //output lock
        .reset(reset_i), //input reset
        .clkin(clkin_i) //input clkin
    );

//--------Copy end-------------------
