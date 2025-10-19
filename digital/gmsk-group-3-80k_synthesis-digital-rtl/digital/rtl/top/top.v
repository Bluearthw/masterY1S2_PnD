module top#(
      parameter CIC_NIN  = 16,
      parameter CIC_NMAX = 40,
      parameter CIC_NOUT = 16,
      parameter DEMOD_OUT = 7,
      parameter CLOCK_REC_OSR = 8,
      parameter SYS_CLK_FREQ = 6400_000,
      parameter MIXING_FREQ  = 320_000,
      parameter DEMOD_FREQ   = 16_000,
      parameter SAMPLE_RATE  = 800,
      parameter SWEEP_SAMPLE_ACCUM_NUM = 32,
      parameter TAPS = 12 

)(
    input  clk,     //6400kHz
    input  rst,
    input  en,
    input  signed [7:0] adc_in,
    output wire [7:0] char_out,  // 输出解码后的 ASCII 字符
    output wire char_valid
);

    // output declaration of module downmixer_recovery
    wire signed [CIC_NOUT-1:0] I_out;
    wire signed [CIC_NOUT-1:0] Q_out;
    wire signed [DEMOD_OUT-1:0] freq;
    wire [8:0]  phase;
    wire sweep_done;
    wire symbol_sample_tick;
    wire out_bit;

    
    downmixer_recovery #(
        .CIC_NIN              	(CIC_NIN                        ),
        .CIC_NMAX             	(CIC_NMAX                       ),
        .CIC_NOUT             	(CIC_NOUT                       ),
        .SYS_CLK_FREQ     	    (SYS_CLK_FREQ                   ),
        .MIXING_FREQ      	    (MIXING_FREQ                    ),
        .DEMOD_FREQ       	    (DEMOD_FREQ                     ),
        .SAMPLE_RATE      	    (SAMPLE_RATE                    ))
    u_downmixer_recovery(
        .clk        	(clk         ),
        .rst        	(rst         ),
        .en         	(en          ),
        .adc_in     	(adc_in      ),
        .I_out      	(I_out       ),
        .Q_out      	(Q_out       ),
        .sweep_done 	(sweep_done  )
    );

    demod_gmsk#(
        .SYS_CLK_FREQ     	    (SYS_CLK_FREQ                   ),
        .MIXING_FREQ      	    (MIXING_FREQ                    ),
        .DEMOD_FREQ       	    (DEMOD_FREQ                     ),
        .SAMPLE_RATE      	    (SAMPLE_RATE                    ))
     u_demod_gmsk(
        .I      	(I_out     ),
        .Q      	(Q_out     ),
        .start      (sweep_done),
        .resetn 	(rst       ),
        .clk    	(clk       ),
        .phase  	(phase     ),
        .freq   	(freq      )
    );
    
    clk_rec_zerox #(
    .SYS_CLK_FREQ     	    (SYS_CLK_FREQ                   ),
    .MIXING_FREQ      	    (MIXING_FREQ                    ),
    .DEMOD_FREQ       	    (DEMOD_FREQ                     ),
    .SAMPLE_RATE      	    (SAMPLE_RATE                    ),
    .IN_WIDTH 	(DEMOD_OUT  ),
    .OSR      	(CLOCK_REC_OSR  ))
    u_clk_rec_zerox(
        .clk                	(clk                 ),
        .rst                	(rst                 ),
        .enable             	(sweep_done              ),
        .diff_phase_in      	(freq       ),
        .symbol_sample_tick 	(symbol_sample_tick  ),
        .out_bit            	(out_bit             )
    );


    varicode_decoder #(
        .SYS_CLK_FREQ     	    (SYS_CLK_FREQ                   ),
        .MIXING_FREQ      	    (MIXING_FREQ                    ),
        .DEMOD_FREQ       	    (DEMOD_FREQ                     ),
        .SAMPLE_RATE      	    (SAMPLE_RATE                    ))
    u_varicode_decoder(
        .clk        	(clk         ),
        .rst        	(rst         ),
        .bit_in     	(out_bit      ),
        .bit_valid  	(symbol_sample_tick   ),
        .char_out   	(char_out    ),
        .char_valid 	(char_valid  )
    );

    

endmodule //top
