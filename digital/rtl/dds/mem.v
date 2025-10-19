module mem(
    input           clk,            //reference clock
    input           rstn ,          //resetn, low effective
    input           en ,            //start to generating waves
    input [7:0]     addr ,
    output          dout_en ,
    output [9:0]    dout);          //data out, 10bit width

    //data out fROM ROMs
    wire [9:0]           q_cos ;

    //ROM addr
    reg [1:0]            en_r ;
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            en_r   <= 2'b0 ;
        end
        else begin
            en_r   <= {en_r[0], en} ;         //delay one cycle for en
        end
    end



    //ROM instiation
    cos_ROM      u_cos_ROM (
       .clk     (clk),
       .en      (en_r[0]),  //sel = 0, cos wave
       .addr    (addr[7:0]),
       .q       (q_cos[9:0]));

    assign dout      = en_r[1] ? q_cos : 10'b0 ;
    assign dout_en   = en_r[1] ;

endmodule


module cos_ROM (
    input               clk,
    input               en,
    input [7:0]         addr,
    output reg [9:0]     q);

   wire [8:0]           ROM_t [0 : 64] ;
   //as the symmetry of cos function, just store 1/4 data of one cycle
   assign ROM_t[0:64] = {
               511, 510, 510, 509, 508, 507, 505, 503,
               501, 498, 495, 492, 488, 485, 481, 476,
               472, 467, 461, 456, 450, 444, 438, 431,
               424, 417, 410, 402, 395, 386, 378, 370,
               361, 352, 343, 333, 324, 314, 304, 294,
               283, 273, 262, 251, 240, 229, 218, 207,
               195, 183, 172, 160, 148, 136, 124, 111,
               99 , 87 , 74 , 62 , 50 , 37 , 25 , 12 ,
               0 } ;

    always @(posedge clk) begin
        if (en) begin
            if (addr[7:6] == 2'b00 ) begin  //quadrant 1, addr[0, 63]
                q <= ROM_t[addr[5:0]] + 10'd512 ; //上移
            end
            else if (addr[7:6] == 2'b01 ) begin //2nd, addr[64, 127]
                q <= 10'd512 - ROM_t[64-addr[5:0]] ; //两次翻转
            end
            else if (addr[7:6] == 2'b10 ) begin //3rd, addr[128, 192]
                q <= 10'd512 - ROM_t[addr[5:0]]; //翻转右移
            end
            else begin     //4th quadrant, addr [193, 256]
                q <= 10'd512 + ROM_t[64-addr[5:0]]; //翻转上移
            end
        end
        else begin
            q <= 'b0 ;
        end
    end
endmodule