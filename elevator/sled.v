module sled (
    input [2:0] POSITION, // 电梯当前位置
    input [4:1] FLOOR_REQUEST, // 楼层请求信号
    input UP, // 上行信号
    input DOWN, // 下行信号
    input [7:0] key,
    output reg [7:0] LED // 8个LED灯
);
    // 每次POSITION或FLOOR_REQUEST或UP/DOWN信号变化时更新LED状态
    always @ (POSITION or FLOOR_REQUEST or UP or DOWN) begin
        // 默认情况下，所有LED都熄灭（因为低电平亮）
        LED <= 'b11111111;

        // 前四个LED表示对应楼层到达，到达时亮起（低电平亮）
        // LED灯序号调整为从0开始，因此使用POSITION直接索引
        if (POSITION >= 1 && POSITION <= 4) begin
            LED[POSITION - 1] <= 0; // 对应楼层LED亮起
        end

        // 第5个LED表示上行方向，上行时亮起
        if (UP) begin
            LED[4] <= 0;
        end

        // 第6个LED表示下行方向，下行时亮起
        if (DOWN) begin
            LED[5] <= 0;
        end
        
        // 第7个LED在到达任意楼层时亮起（即至少有一个楼层请求时亮起）
        if (|FLOOR_REQUEST) begin // 使用了按位或操作来检查是否有任何楼层请求
            LED[6] <= 0;
        end

        // 第8个LED未定义功能，保持熄灭（低电平亮）
    end

endmodule
