module mixtop (
    input logic rst_n,
    input logic clk,
    //CMP
    input wire cmp_out_n,
    input wire cmp_out_p,
    //VGA
    output wire [5:0] vga_control_out,// out from vga_control, into vga
    //ADC
    output wire v_in_ctrl,
    output wire [7:0] vref_ctrl,
    //to digital
    output logic [7:0] adc_out_signed

  );
  parameter CLOCK_REC_OSR = 8;
  wire w_ctrl;
  wire w_enable;
  //CMP
  wire cmp_out;
  

  logic [2:0] vga_control_in;//from_digital;
  logic [7:0] adc_out;
  logic done;


  dm_gen_v1 i_dm_out_v1(
    .vp(cmp_out_p),
    .vn(cmp_out_n),
    .dm(cmp_out)
  );

  mix_level_detect level_detect(
    .digital_in   (adc_out),
    .clk          (clk),
    .rst_n        (rst_n), 
    .vga_control (vga_control_in)  

  );

  mix_vga_control #(
    .INPUT_WIDTH (3)
  ) i_mix_vga_control(
    .clk (clk),
    // .rstn (rst_n),
    .vga_control_in (vga_control_in),
    .vga_control_out (vga_control_out)
  );

  dac_v3_tester i_dac_v3_tester(
    //in
    .clk(clk), 
    .cmp(cmp_out),
    //out 
    .o_vin_ctrl(v_in_ctrl), 
    .o_vref_ctrl(vref_ctrl), 
	  .o_readout(adc_out),
    .done(done)
  );

  mix_to_digital i_mix_to_digital(
    .unsign_digital(adc_out),
    .signed_digital(adc_out_signed)
  );
  
  

endmodule : mixtop

