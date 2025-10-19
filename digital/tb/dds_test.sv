`timescale 1ns/1ns

module test ;
    reg          clk ;
    reg          rstn ;
    reg [8:0]    phase_init ;
    reg [8:0]    f_word ;
    wire signed [11:0]  sin_dout ;
    wire signed [11:0]  cos_dout ;



    dds_cordic u_dds_cordic(
        .clk    (clk),
        .rstn   (rstn),
        .phase_init(phase_init),
        .f_word (f_word),
        .sin_dout(sin_dout),
        .cos_dout(cos_dout)
    );

    //(1)clk, reset and other constant regs
    initial begin
        clk           = 1'b0 ;
        rstn          = 1'b0 ;
        #1000;
        rstn          = 1'b1 ;
        #100 ;
        forever begin
            #2500 ;      clk = ~clk ;   //system clock, 80kHz
        end
    end

    //(2)signal setup ;
    parameter    clk_freq    = 200000;   //100MHz
    integer      freq_dst    = 20000 ;   //20kHz
    integer      phase_coe   = 2;        //1/4 cycle, that is pi/2

    initial begin
        //(a)cos wave, pi/2 phase
        phase_init        = 'd0/phase_coe ;   //pi/8 initialing-phase
        f_word            = 'd360 * freq_dst / clk_freq; //get the frequency control word
        #500 ;
        @ (negedge clk) ;
        # 2000 ;
    end


    //(4) finish the simulation
    always begin
        #100;
        if ($time >= 10000000) $finish ;
    end
endmodule