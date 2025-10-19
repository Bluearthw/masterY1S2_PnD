`timescale 1ns/1ns

module downmixer 
    #(parameter NIN  = 16,
      parameter NMAX = 32,
      parameter NOUT = 16 )(
      input clk, //1600 kHz
      input clk_80k,
      input rst,
      input en,
      input  signed [7:0] adc_in,
      output signed [NOUT-1:0] I_out,
      output signed [NOUT-1:0] Q_out
);

      wire signed [15:0] I_mixer;
      wire signed [15:0] Q_mixer;
      wire signed [7:0] sin_carrier;
      wire signed [7:0] cos_carrier;
      wire [8:0]    phase_init ;
      wire [8:0]    step ;

      assign phase_init = 'd0;

      assign step     = 'd90; //'d 360*(20kHz/80kHz)


      mixer u_mixer_I(
         .adc_input(adc_in),
         .carrier_input(cos_carrier),
         .mixer_output(I_mixer)
      );

      mixer u_mixer_Q(
         .adc_input(adc_in),
         .carrier_input(sin_carrier),
         .mixer_output(Q_mixer)
      );

      dds_cordic u_dds_cordic(
         .clk (clk),
         .rstn(rst),
         .phase_init (phase_init),
         .f_word(step),
         .sin_dout(sin_carrier),
         .cos_dout(cos_carrier)
      );

      wire I_valid,Q_valid;


      cic #(.NIN(NIN), .NMAX(NMAX), .NOUT(NOUT))
      u_cic_I (
            .clk    (clk_80k),
            .rstn   (rst),
            .en     (en),
            .din    (I_mixer),
            .valid  (I_valid),
            .dout   (I_out)
      );

      cic #(.NIN(NIN), .NMAX(NMAX), .NOUT(NOUT))
      u_cic_Q (
            .clk    (clk_80k),
            .rstn   (rst),
            .en     (en),
            .din    (Q_mixer),
            .valid  (Q_valid),
            .dout   (Q_out)
      );



    
endmodule