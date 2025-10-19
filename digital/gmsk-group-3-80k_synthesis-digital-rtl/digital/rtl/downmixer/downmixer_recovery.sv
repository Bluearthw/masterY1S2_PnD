`timescale 1ns/1ns

module downmixer_recovery 
    #(parameter CIC_NIN  = 16,
      parameter CIC_NMAX = 40,
      parameter CIC_NOUT = 16,
      parameter SYS_CLK_FREQ = 3200_000,
      parameter MIXING_FREQ  = 160_000,
      parameter DEMOD_FREQ   = 16_000,
      parameter SAMPLE_RATE  = 800 )(
      input clk,     //6400kHz
      input rst,
      input en,
      input  wire signed [7:0] adc_in,
      output wire signed [CIC_NOUT-1:0] I_out,
      output wire signed [CIC_NOUT-1:0] Q_out,
      output wire sweep_done
);

      //----------------------------------------------------------
      // Clock division -> enable 
      // mixing rate  = 160kHz
      // SAMPLE_DIV = 3.2MHz / 160kHz = 20
      //----------------------------------------------------------
      localparam SAMPLE_DIV = SYS_CLK_FREQ / MIXING_FREQ;
      reg [31:0] sample_counter;
      reg sample_en;

      always @(posedge clk or negedge rst) begin
      if(!rst) begin
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


      //Parameters
      // sweep steps
      //localparam [15:0] sweep_steps [0:10] = '{16'd2193, 16'd2205, 16'd2216, 16'd2227, 16'd2238,16'd2250, 16'd2261, 16'd2273, 16'd2284, 16'd2295, 16'd2306};
      localparam [15:0] sweep_steps [0:10] = '{16'd4386, 16'd4410, 16'd4432, 16'd4454, 16'd4476,16'd4500, 16'd4522, 16'd4546, 16'd4568, 16'd4590, 16'd4612};

      //FSM
      localparam IDLE         = 3'd1;// wait for reset
      localparam START_SWEEP  = 3'd2;// set DDS step to current sweep_steps
      localparam ACCUMULATE   = 3'd3;// accumulate 32 energy samples from CIC outputs
      localparam NEXT_FREQ    = 3'd4;// compare current accumulated energy to maximum found
      localparam DONE_SWEEP   = 3'd5;// finish sweep, output best carrrier frequency step
      localparam START_MIXING = 3'd6;// start normal downmixing with best_step
      localparam MIXING       = 3'd7;

      reg [2:0] state,next_state;

      //sweeep index
      reg [3:0] sweep_index; 
      reg [15:0] current_step;

      //Mixing registers
      wire signed [CIC_NOUT-1:0] I_out_cic;
      wire signed [CIC_NOUT-1:0] Q_out_cic;
      reg signed [CIC_NOUT-1:0] I_out_reg;
      reg signed [CIC_NOUT-1:0] Q_out_reg;
      wire signed [15:0] I_mixer;
      wire signed [15:0] Q_mixer;
      wire signed [7:0] sin_carrier;
      wire signed [7:0] cos_carrier;
      reg    sweep_flag ;
      reg    sweep_done_flag;
      wire [15:0]    step ;
      wire I_valid,Q_valid;

      //Accumulate CIC output for energy measurement
      reg [7:0] sample_count;   // counts how many samples accumulated
      parameter SAMPLE_ACCUM_NUM = 50;  // number of CIC samples for each freq
      reg [37:0] best_energy;
      reg [15:0] best_step;
      wire finished_accumulate;
      //track best step

      // state transition
      always @(posedge clk or negedge rst) begin
            if(!rst) begin
                  state <=IDLE;
            end else if(sample_en)begin
                  state <= next_state;
            end else begin
                  state <= state;
            end
      end


    //Next state logic
    always @(*) begin
        case (state)
            IDLE:         next_state = START_SWEEP;
            START_SWEEP:  next_state = ACCUMULATE;
            ACCUMULATE:   next_state = (finished_accumulate)? NEXT_FREQ : ACCUMULATE;
            NEXT_FREQ:    next_state = (sweep_index == 10)? DONE_SWEEP:START_SWEEP; 
            DONE_SWEEP:   next_state = START_MIXING;
            START_MIXING: next_state = MIXING;
            MIXING:       next_state = MIXING;
            default:      next_state = IDLE;
        endcase
    end


      assign step     = current_step;
      //assign step     = ((state == START_MIXING) && (state == MIXING)&& (state == DONE_SWEEP))?  best_step: sweep_steps[sweep_index]; //'d 360*(20kHz/80kHz)

      //energy accumulation
      reg unsigned [31:0] I_squared; 
      reg unsigned [31:0] Q_squared; 
      reg unsigned [32:0] magnitude_sq; 
      reg unsigned [37:0] accumulated_energy;

      always @(*) begin
                  I_squared = I_out_reg * I_out_reg;
                  Q_squared = Q_out_reg * Q_out_reg;
                  magnitude_sq = I_squared + Q_squared;
      end

      assign finished_accumulate = (sample_count == SAMPLE_ACCUM_NUM)? 1:0;
      

      always @(posedge clk) begin
                  if (state == IDLE) begin
                        sample_count       <= 0;
                        accumulated_energy <=0;
                        sweep_index  <= 0;
                        best_energy  <= 0;
                        best_step    <= 0;
                        current_step <= 0;
                        sweep_flag   <= 0;
                        sweep_done_flag <= 0;
                  end else if (state == ACCUMULATE && I_valid && Q_valid) begin
                        sample_count <= sample_count + 1;
                        accumulated_energy <= accumulated_energy + magnitude_sq;
                        sweep_index  <= sweep_index;
                        best_energy  <= best_energy;
                        best_step    <= best_step;
                        current_step <= sweep_steps[sweep_index];
                        sweep_flag   <= 0;
                        sweep_done_flag <= 0;
                  end else if (state == ACCUMULATE && sample_en) begin
                        sample_count <= sample_count;
                        accumulated_energy <= accumulated_energy;
                        sweep_index  <= sweep_index;
                        best_energy  <= best_energy;
                        best_step    <= best_step;
                        current_step <= current_step;
                        sweep_flag   <= 0;
                        sweep_done_flag <= 0;
                  end else if (state == NEXT_FREQ && sample_en) begin
                        sample_count <= sample_count;
                        sweep_index  <= sweep_index;
                        accumulated_energy <= accumulated_energy;
                        if(accumulated_energy > best_energy) begin
                              best_energy <= accumulated_energy;
                              best_step   <= sweep_steps[sweep_index];
                        end else begin
                              best_energy <= best_energy;
                              best_step   <= best_step;
                        end
                        current_step <= sweep_steps[sweep_index];
                        sweep_flag   <= 1;
                        sweep_done_flag <= 0;
                  end else if (state == START_SWEEP && sample_en) begin
                        sample_count <= 0;
                        sweep_index  <= sweep_index+1 ;
                        accumulated_energy <=0;
                        best_energy  <= best_energy;
                        best_step    <= best_step;
                        current_step <= sweep_steps[sweep_index];
                        sweep_flag <= 0;
                        sweep_done_flag <= 0;
                  end else if (state == DONE_SWEEP && sample_en) begin
                        sample_count <= 0;
                        sweep_index  <= 0 ;
                        accumulated_energy <=accumulated_energy;
                        best_energy  <= best_energy;
                        best_step    <= best_step;
                        current_step <= best_step;
                        sweep_flag   <= 0;
                        sweep_done_flag <= 1;
                  end else begin
                        sample_count <= sample_count;
                        sweep_index  <= sweep_index;
                        accumulated_energy <=accumulated_energy;
                        best_energy  <= best_energy;
                        best_step    <= best_step;
                        current_step <= current_step;
                        sweep_flag   <= sweep_flag;
                        sweep_done_flag <= sweep_done_flag;
                  end
      end

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
         .sweep_flag (sweep_flag),
         .f_word(step),
         .sin_dout(sin_carrier),
         .cos_dout(cos_carrier)
      );

      assign sweep_done = sweep_done_flag;




      cic #(.NIN(CIC_NIN), .NMAX(CIC_NMAX), .NOUT(CIC_NOUT), .SYS_CLK_FREQ(SYS_CLK_FREQ), .MIXING_FREQ(MIXING_FREQ), .DEMOD_FREQ(DEMOD_FREQ), .SAMPLE_RATE(SAMPLE_RATE))
      u_cic_I (
            .clk    (clk),
            .rstn   (rst),
            .en     (en),
            .din    (I_mixer),
            .valid  (I_valid),
            .dout   (I_out_cic)
      );

      cic #(.NIN(CIC_NIN), .NMAX(CIC_NMAX), .NOUT(CIC_NOUT), .SYS_CLK_FREQ(SYS_CLK_FREQ), .MIXING_FREQ(MIXING_FREQ), .DEMOD_FREQ(DEMOD_FREQ), .SAMPLE_RATE(SAMPLE_RATE))
      u_cic_Q (
            .clk    (clk),
            .rstn   (rst),
            .en     (en),
            .din    (Q_mixer),
            .valid  (Q_valid),
            .dout   (Q_out_cic)
      );

      hamming_filter #( .SYS_CLK_FREQ(SYS_CLK_FREQ), .MIXING_FREQ(MIXING_FREQ), .DEMOD_FREQ(DEMOD_FREQ), .SAMPLE_RATE(SAMPLE_RATE))
      real_filter (
      .clk        (clk),
      .rst        (rst),
      .start    	(en     ),
      .sample_in  (I_out_cic),
      .sample_out (I_out_reg)
      );

      hamming_filter #( .SYS_CLK_FREQ(SYS_CLK_FREQ), .MIXING_FREQ(MIXING_FREQ), .DEMOD_FREQ(DEMOD_FREQ), .SAMPLE_RATE(SAMPLE_RATE)) 
      imag_filter (
      .clk        (clk),
      .rst        (rst),
      .start    	(en     ),
      .sample_in  (Q_out_cic),
      .sample_out (Q_out_reg)
      );

      assign I_out = I_out_reg;
      assign Q_out = Q_out_reg;



    
endmodule