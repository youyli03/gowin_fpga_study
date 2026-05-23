module key4x4_driver
(
 clk,  
 reset,
 row,   
 col,   
 key_value 
);

input clk,reset;
input [3:0] row;
output [3:0] col;
output [7:0] key_value;

wire [3:0] col;
reg [7:0] key_value;
reg [5:0] count;
reg [2:0] state;  
reg key_flag;   
reg clk_500khz;  
reg [3:0] col_reg;  
reg [3:0] row_reg;  
assign col = col_reg;   

always @(posedge clk or negedge reset)
   if(!reset) 
	begin 
		clk_500khz<=0; 
		count<=0; 
	end
   else
    begin
      if(count>=50) 
		begin 
			clk_500khz<=~clk_500khz;
			count<=0;
		end
      else count<=count+1;
    end
  
always @(posedge clk_500khz or negedge reset)
   if(!reset) 
	begin 
		state<=3'd0;
		key_flag<=1'b0;
		col_reg<=4'b0000;
		row_reg<=4'b0000;
	end
   else
    begin
     case (state)
      3'd0:
         begin
			col_reg[3:0]<=4'b0000;
			key_flag<=1'b0;
			if(row[3:0]==4'b1111) 
				begin 
					state<=3'd1;
					col_reg[3:0]<=4'b1110;
				end 
			// else state<=3'd0;
         end
      3'd1: 
         begin   //col[3:0]="1110"
			if(row[3:0]!=4'b1111) 
				begin 
					state<=3'd5;
				end   
			else  
				begin 
					state<=3'd2;
					col_reg[3:0]<=4'b1101;
				end  
         end
      3'd2:
         begin   //col[3:0]="1101"
			if(row[3:0]!=4'b1111) 
				begin 
					state<=3'd5;
				end    
			else  
				begin 
					state<=3'd3;
					col_reg[3:0]<=4'b1011;
				end  
         end
      3'd3:
         begin   //col[3:0]="1011"
			if(row[3:0]!=4'b1111) 
				begin 
					state<=3'd5;
				end   
			else  
				begin 
					state<=3'd4;
					col_reg[3:0]<=4'b0111;
				end  
         end
      3'd4:
         begin   //col[3:0]="0111"
			if(row[3:0]!=4'b1111) 
				begin 
					state<=3'd5;
				end  
			else  state<=3'd0;
         end
      3'd5:
         begin 
            if(row[3:0]!=4'b1111)
				begin
					//col_reg<=col;  
					row_reg<=row;  
					state<=3'd5;
					key_flag<=1'b1;  
				end            
				else
				begin 
					state<=3'd0;
				end
		 end   
	 endcase
    end          

//always @(clk_500khz or col_reg or row_reg)
always @(posedge clk_500khz or negedge reset)
     begin
		if (!reset)
			key_value <= 8'hff;
        else if(key_flag==1'b1)
                begin
                     case ({col_reg,row_reg})
                      8'b1110_1110: key_value <= 8'd0;
                      8'b1110_1101: key_value <= 8'd1;
                      8'b1110_1011: key_value <= 8'd2;
                      8'b1110_0111: key_value <= 8'd3;
                      8'b1101_1110: key_value <= 8'd4;
                      8'b1101_1101: key_value <= 8'd5;
                      8'b1101_1011: key_value <= 8'd6;
                      8'b1101_0111: key_value <= 8'd7;
                      8'b1011_1110: key_value <= 8'd8;
                      8'b1011_1101: key_value <= 8'd9;
                      8'b1011_1011: key_value <= 8'd10;
                      8'b1011_0111: key_value <= 8'd11;
                      8'b0111_1110: key_value <= 8'd12;
                      8'b0111_1101: key_value <= 8'd13;
                      8'b0111_1011: key_value <= 8'd14;
                      8'b0111_0111: key_value <= 8'd15;    
					  default: key_value <= 8'hff;
                     endcase
				end  
			  else key_value <= 8'hff;
   end      

endmodule