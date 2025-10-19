module cordic(
input 			clk,
input 			rst_n,
input	[15:0]	angle,
input			start,
output wire finished,
output reg signed[7:0]	  Sin,
output reg signed[7:0]    Cos
);

parameter angle_0 = 32'd294912000;		//45度*2^16
parameter angle_1 = 32'd174099200;     //26.5651度*2^16
parameter angle_2 = 32'd91987200;      //14.0362度*2^16
parameter angle_3 = 32'd46694400;      //7.1250度*2^16
parameter angle_4 = 32'd23436800;      //3.5763度*2^16
parameter angle_5 = 32'd11731200;     //1.7899度*2^16
parameter angle_6 = 32'd5868800;      //0.8952度*2^16
parameter angle_7 = 32'd2931200;      //0.4476度*2^16
// parameter angle_8 = 32'd1465600;      //0.2238度*2^16
// parameter angle_9 = 32'd736000;      //0.1119度*2^16


parameter pipeline = 8;
//parameter K = 32'h09b74;			//0.607253*2^16,
parameter K = 32'd3979690;			//0.607253*2^16,

reg signed 	[31:0] 		x0 =0,y0 =0,z0 =0;
reg signed 	[31:0] 		x1 =0,y1 =0,z1 =0;
reg signed 	[31:0] 		x2 =0,y2 =0,z2 =0;
reg signed 	[31:0] 		x3 =0,y3 =0,z3 =0;
reg signed 	[31:0] 		x4 =0,y4 =0,z4 =0;
reg signed 	[31:0] 		x5 =0,y5 =0,z5 =0;
reg signed 	[31:0] 		x6 =0,y6 =0,z6 =0;
reg signed 	[31:0] 		x7 =0,y7 =0,z7 =0;
reg signed 	[31:0] 		x8 =0,y8 =0,z8 =0;
// reg signed 	[31:0] 		x9 =0,y9 =0,z9 =0;
// reg signed 	[31:0] 		x10=0,y10=0,z10=0;


reg  [3:0]           count;
reg  [15:0]           cordic_angle;
reg  sin_sign,cos_sign;
reg  signed [7:0] r_sin,r_cos;    


//pre-processing of quadrant
always @(*) begin
    if (angle <= 'd9000) begin // 0°–90°
        cordic_angle = angle;
        sin_sign = 0;
        cos_sign = 0;
    end else if (angle <= 'd18000) begin // 90°–180°
        cordic_angle = 'd18000 - angle;
        sin_sign = 0;
        cos_sign = 1;
    end else if (angle <= 'd27000) begin // 180°–270°
        cordic_angle = angle - 'd18000;
        sin_sign = 1;
        cos_sign = 1;
    end else begin // 270°–360°
        cordic_angle = 'd36000 - angle;
        sin_sign = 1;
        cos_sign = 0;
    end
end

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		count <= 'b0;
	else if(start)begin
		if(count != 4'd8)
			count <= count + 1'b1;
		else if (finished)
			count <= 'b0;
		else 
			count <= count;
	end
end


assign finished = (count == 4'd8)?1'b1:1'b0;


always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		x0 <= 'b0;
		y0 <= 'b0;
		z0 <= 'b0;
        	// r_sin <= 'b0;
        	// r_cos <= 'b0;
	end
	
	else begin
		x0 <= K;
		y0 <= 32'd0;
		z0 <= cordic_angle << 16;
        	// r_sin <= r_sin;
        	// r_cos <= r_cos;
	end
end 

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		x1 <= 'b0;
		y1 <= 'b0;
		z1 <= 'b0;
	end
	else if(z0[31]) begin
		x1 <= x0 + y0;
		y1 <= y0 - x0;
		z1 <= z0 + angle_0;
	end
	else begin
		x1 <= x0 - y0;
		y1 <= y0 + x0;
		z1 <= z0 - angle_0;		
	end
end 

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		x2 <= 'b0;
		y2 <= 'b0;
		z2 <= 'b0;
	end
	else if(z1[31]) begin
		x2 <= x1 + (y1>>>1);
		y2 <= y1 - (x1>>>1);
		z2 <= z1 + angle_1;
	end
	else begin
		x2 <= x1 - (y1>>>1);
		y2 <= y1 + (x1>>>1);
		z2 <= z1 - angle_1;	
	end
end 

always@(posedge clk or negedge rst_n)begin//第3次迭代
	if(!rst_n)begin
		x3 <= 'b0;
		y3 <= 'b0;
		z3 <= 'b0;
	end
	else if(z2[31]) begin
		x3 <= x2 + (y2>>>2);
		y3 <= y2 - (x2>>>2);
		z3 <= z2 + angle_2;
	end
	else begin
		x3 <= x2 - (y2>>>2);
		y3 <= y2 + (x2>>>2);
		z3 <= z2 - angle_2;	
	end
end 

always@(posedge clk or negedge rst_n)begin//第4次迭代
	if(!rst_n)begin
		x4 <= 'b0;
		y4 <= 'b0;
		z4 <= 'b0;
	end
	else if(z3[31]) begin
		x4 <= x3 + (y3>>>3);
		y4 <= y3 - (x3>>>3);
		z4 <= z3 + angle_3;
	end
	else begin
		x4 <= x3 - (y3>>>3);
		y4 <= y3 + (x3>>>3);
		z4 <= z3 - angle_3;	
	end
end 

always@(posedge clk or negedge rst_n)begin//第5次迭代
	if(!rst_n)begin
		x5 <= 'b0;
		y5 <= 'b0;
		z5 <= 'b0;
	end
	else if(z4[31]) begin
		x5 <= x4 + (y4>>>4);
		y5 <= y4 - (x4>>>4);
		z5 <= z4 + angle_4;
	end
	else begin
		x5 <= x4 - (y4>>>4);
		y5 <= y4 + (x4>>>4);
		z5 <= z4 - angle_4;	
	end
end 

always@(posedge clk or negedge rst_n)begin//第6次迭代
	if(!rst_n)begin
		x6 <= 'b0;
		y6 <= 'b0;
		z6 <= 'b0;
	end
	else if(z5[31]) begin
		x6 <= x5 + (y5>>>5);
		y6 <= y5 - (x5>>>5);
		z6 <= z5 + angle_5;
	end
	else begin
		x6 <= x5 - (y5>>>5);
		y6 <= y5 + (x5>>>5);
		z6 <= z5 - angle_5;	
	end
end 

always@(posedge clk or negedge rst_n)begin//第7次迭代
	if(!rst_n)begin
		x7 <= 'b0;
		y7 <= 'b0;
		z7 <= 'b0;
	end
	else if(z6[31]) begin
		x7 <= x6 + (y6>>>6);
		y7 <= y6 - (x6>>>6);
		z7 <= z6 + angle_6;
	end
	else begin
		x7 <= x6 - (y6>>>6);
		y7 <= y6 + (x6>>>6);
		z7 <= z6 - angle_6;	
	end
end 

always@(posedge clk or negedge rst_n)begin//第8次迭代
	if(!rst_n)begin
		x8 <= 'b0;
		y8 <= 'b0;
		z8 <= 'b0;
	end
	else if(z7[31]) begin
		x8 <= x7 + (y7>>>7);
		y8 <= y7 - (x7>>>7);
		z8 <= z7 + angle_7;
	end
	else begin
		x8 <= x7 - (y7>>>7);
		y8 <= y7 + (x7>>>7);
		z8 <= z7 - angle_7;	
	end
end 

// always@(posedge clk or negedge rst_n)begin//第9次迭代
// 	if(!rst_n)begin
// 		x9 <= 'b0;
// 		y9 <= 'b0;
// 		z9 <= 'b0;
// 	end
// 	else if(z8[31]) begin
// 		x9 <= x8 + (y8>>>8);
// 		y9 <= y8 - (x8>>>8);
// 		z9 <= z8 + angle_8;
// 	end
// 	else begin
// 		x9 <= x8 - (y8>>>8);
// 		y9 <= y8 + (x8>>>8);
// 		z9 <= z8 - angle_8;	
// 	end
// end 

// always@(posedge clk or negedge rst_n)begin
// 	if(!rst_n)begin
// 		x10 <= 'b0;
// 		y10 <= 'b0;
// 		z10 <= 'b0;
// 	end
// 	else if(z9[31]) begin
// 		x10 <= x9 + (y9>>>9);
// 		y10 <= y9 - (x9>>>9);
// 		z10 <= z9 + angle_9;
// 	end
// 	else begin
// 		x10 <= x9 - (y9>>>9);
// 		y10 <= y9 + (x9>>>9);
// 		z10 <= z9 - angle_9;	
// 	end
// end 



reg signed [7:0] x10_temp,y10_temp;
reg signed [7:0] x10_temp_neg,y10_temp_neg;
always@(*) begin
	x10_temp = $signed(x8[23:16]);
	y10_temp = $signed(y8[23:16]);
	x10_temp_neg = -$signed(x8[23:16]);
	y10_temp_neg = -$signed(y8[23:16]);
end


always@(posedge clk)begin
	if(!rst_n)begin
		r_sin <= 'b0;
		r_cos <= 'b0;
	end
	else begin
		if(sin_sign)
         		r_sin <=  y10_temp_neg;
		else	
			r_sin <=  y10_temp;
		if(cos_sign)		
         		r_cos <= x10_temp_neg;
		else
			r_cos <= x10_temp;    
	end
end 

always@(*) begin
	Sin = r_sin;
	Cos = r_cos;
end
endmodule
