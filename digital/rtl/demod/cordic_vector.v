module cordic_vector#(
      parameter SYS_CLK_FREQ = 3200_000,
      parameter MIXING_FREQ  = 160_000,
      parameter DEMOD_FREQ   = 8_000,
      parameter SAMPLE_RATE  = 800 
)(
input 						clk,
input 						rst_n,
input	signed [15:0]		x,
input	signed [15:0]		y,
input						start,
output 	reg    [8:0]	    angle,
output	wire				finished
);


//----------------------------------------------------------
// Clock division -> enable 
// SAMPLE_RATE  = 8_000Hz
// SAMPLE_DIV   = 64MHz / 8kHz = 8_000
//----------------------------------------------------------
localparam SAMPLE_DIV = SYS_CLK_FREQ / DEMOD_FREQ;
reg [31:0] sample_counter;
reg sample_en;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sample_counter <= 0;
        sample_en <= 0;
    end else begin
        if(sample_counter == SAMPLE_DIV-1) begin
            sample_counter <= 0;
            sample_en <= 1;
        end else begin
            sample_counter <= sample_counter + 1;
            sample_en <= 0;
        end
    end
end


    parameter angle_0 = 16'd11520;		//45度*2^8
    parameter angle_1 = 16'd6800;     //26.5651度*2^8
    parameter angle_2 = 16'd3593;      //14.0362度*2^8
    parameter angle_3 = 16'd1824;      //7.1250度*2^8
    parameter angle_4 = 16'd915;      //3.5763度*2^8
    parameter angle_5 = 16'd458;     //1.7899度*2^8
    parameter angle_6 = 16'd229;      //0.8952度*2^8
    parameter angle_7 = 16'd114;      //0.4476度*2^8
  

    reg signed 	[15:0] 		x0 =0,y0 =0,z0 =0;
    reg signed 	[15:0] 		x1 =0,y1 =0,z1 =0;
    reg signed 	[15:0] 		x2 =0,y2 =0,z2 =0;
    reg signed 	[15:0] 		x3 =0,y3 =0,z3 =0;
    reg signed 	[15:0] 		x4 =0,y4 =0,z4 =0;
    reg signed 	[15:0] 		x5 =0,y5 =0,z5 =0;
    reg signed 	[15:0] 		x6 =0,y6 =0,z6 =0;
    reg signed 	[15:0] 		x7 =0,y7 =0,z7 =0;


    reg  [4:0]           count;

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)
            count <= 'b0;
        else if(start && sample_en)begin
            if(count == 5'd19)
			    count <= 'b0;    
            else
                count <= count + 1'b1;        
        end else 
                count <= count;
    end
    

    assign finished  = (count == 5'd8)?1'b1:1'b0;


    /*
        check x[15] y[15]   quadrant    new xy     angleref
                0     0        1        x    y      0
                1     0        2        y   -x      90
                1     1        3       -x   -y      180
                1     1        4       -y    x      270
    */
    reg  [8:0] angle_ref;
    reg signed [15:0] x_new,y_new;
    always@(*) begin
         case ({x[15], y[15]})
        2'b00: begin // Quadrant 1
            x_new = x;
            y_new = y;
            angle_ref = 'd0;
        end
        2'b10: begin // Quadrant 2
            x_new = y;
            y_new = -(x);
            angle_ref = 'd90;
        end
        2'b11: begin // Quadrant 3
            x_new = -(x);
            y_new = -(y);
            angle_ref = 'd180;
        end
        2'b01: begin // Quadrant 4
            x_new = -(y);
            y_new = (x);
            angle_ref = 'd270;
        end
        default: begin
            x_new = 0;
            y_new = 0;
            angle_ref = 'd0;
        end
    endcase
    end

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            x0 <= 'b0;
            y0 <= 'b0;
            z0 <= 'b0;

        end
        
        else if(start && sample_en)begin
            x0 <= x_new ;
            y0 <= y_new ;
            z0 <= 'b0;
        end else begin
            x0 <= x0;
            y0 <= y0;
            z0 <= z0;
        end
    end 

    always@(posedge clk or negedge rst_n)begin//第一次迭代
        if(!rst_n)begin
            x1 <= 'b0;
            y1 <= 'b0;
            z1 <= 'b0;
        end
        else if (start&&sample_en) begin
            if(!y0[15] ) begin					//和A不同的是，每次判断y坐标的正负，从而决定是顺时针还是逆时针旋转。
                x1 <= x0 + y0;
                y1 <= y0 - x0;
                z1 <= z0 + angle_0;
            end else begin
                x1 <= x0 - y0;
                y1 <= y0 + x0;
                z1 <= z0 - angle_0;		
            end
        end else begin
            x1 <= x1;
            y1 <= y1;
            z1 <= z1;	
        end
    end 

    always@(posedge clk or negedge rst_n)begin//第二次迭代
        if(!rst_n)begin
            x2 <= 'b0;
            y2 <= 'b0;
            z2 <= 'b0;
        end else if (start&&sample_en) begin
            if(!y1[15]) begin
                x2 <= x1 + (y1>>>1);
                y2 <= y1 - (x1>>>1);
                z2 <= z1 + angle_1;
            end else begin
                x2 <= x1 - (y1>>>1);
                y2 <= y1 + (x1>>>1);
                z2 <= z1 - angle_1;	
            end
        end else begin
            x2 <= x2;
            y2 <= y2;
            z2 <= z2;
        end
    end

    always@(posedge clk or negedge rst_n)begin//第3次迭代
        if(!rst_n)begin
            x3 <= 'b0;
            y3 <= 'b0;
            z3 <= 'b0;
        end else if (start&&sample_en) begin
            if(!y2[15]) begin
                x3 <= x2 + (y2>>>2);
                y3 <= y2 - (x2>>>2);
                z3 <= z2 + angle_2;
            end
            else begin
                x3 <= x2 - (y2>>>2);
                y3 <= y2 + (x2>>>2);
                z3 <= z2 - angle_2;	
            end
        end else begin
            x3 <= x3;
            y3 <= y3;
            z3 <= z3;
        end
    end 

    always@(posedge clk or negedge rst_n)begin//第4次迭代
        if(!rst_n)begin
            x4 <= 'b0;
            y4 <= 'b0;
            z4 <= 'b0;
        end else if (start&&sample_en) begin
            if(!y3[15]) begin
                x4 <= x3 + (y3>>>3);
                y4 <= y3 - (x3>>>3);
                z4 <= z3 + angle_3;
            end
            else begin
                x4 <= x3 - (y3>>>3);
                y4 <= y3 + (x3>>>3);
                z4 <= z3 - angle_3;	
            end
        end else begin
            x4 <= x4;
            y4 <= y4;
            z4 <= z4;
        end
    end 

    always@(posedge clk or negedge rst_n)begin//第5次迭代
        if(!rst_n)begin
            x5 <= 'b0;
            y5 <= 'b0;
            z5 <= 'b0;
        end else if (start&&sample_en) begin
            if(!y4[15]) begin
                x5 <= x4 + (y4>>>4);
                y5 <= y4 - (x4>>>4);
                z5 <= z4 + angle_4;
            end
            else begin
                x5 <= x4 - (y4>>>4);
                y5 <= y4 + (x4>>>4);
                z5 <= z4 - angle_4;	
            end
        end else begin
            x5 <= x5;
            y5 <= y5;
            z5 <= z5;
        end
    end 

    always@(posedge clk or negedge rst_n)begin//第6次迭代
        if(!rst_n)begin
            x6 <= 'b0;
            y6 <= 'b0;
            z6 <= 'b0;
        end else if (start&&sample_en) begin 
            if(!y5[15]) begin
            x6 <= x5 + (y5>>>5);
            y6 <= y5 - (x5>>>5);
            z6 <= z5 + angle_5;
            end
            else begin
                x6 <= x5 - (y5>>>5);
                y6 <= y5 + (x5>>>5);
                z6 <= z5 - angle_5;	
            end
        end else begin
            x6 <= x6;
            y6 <= y6;
            z6 <= z6;
        end
    end 

    always@(posedge clk or negedge rst_n)begin//第7次迭代
        if(!rst_n)begin
            x7 <= 'b0;
            y7 <= 'b0;
            z7 <= 'b0;
        end else if (start&&sample_en) begin 
            if(!y6[15]) begin
            x7 <= x6 + (y6>>>6);
            y7 <= y6 - (x6>>>6);
            z7 <= z6 + angle_6;
            end
            else begin
                x7 <= x6 - (y6>>>6);
                y7 <= y6 + (x6>>>6);
                z7 <= z6 - angle_6;	
            end
        end else begin
            x7 <= x7;
            y7 <= y7;
            z7 <= z7;
        end
    end 

    reg  [15:0]	angle_abs;
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            angle_abs <= 'b0;
        end
        else if (start&& sample_en)begin
            angle_abs <= z7; //TODO: simplify this
        end else begin
            angle_abs  <= angle_abs;
        end
    end 

    always @(*) begin
        if(angle_abs[15]==1)
            angle = angle_ref;
        else
            angle = angle_abs[15:8]+angle_ref;
    end

endmodule

