module chiptop (
    input wire vin,
    input wire vdd,
    input wire vss,
    input wire vcm,
    input logic rst_n,
    input logic clk,
    input logic clk_cmp,
    input logic en,
    // input logic clk_80,
    // input logic clk_6400,
    output wire [7:0] char_out,
    output wire char_valid
  );
  parameter CLOCK_REC_OSR = 8;
  wire w_ctrl;
  wire w_enable;
  wire cmp_out;
  wire cmp_out_p;
  wire cmp_out_n;

  logic [2:0] vga_control_in;//from_digital;
  wire [5:0] vga_control_out;// out from vga_control, into vga

  logic [7:0] adc_out;
  wire [7:0] vref_ctrl;
  logic done;

  wire v_in_ctrl;

  //digital part
  logic [7:0] adc_out_signed;
  
  mix_anatop i_anatop (
    // INPUTS
    .vin_ctrl             (v_in_ctrl),
    .vin              (vin),
    .vss              (vss),
    .vcm              (vcm),
    .vdd              (vdd),
    // .vref_ctrl            (vref_ctrl),// you can't write like this
    .vref_ctrl_7      (vref_ctrl[7]),
    .vref_ctrl_6      (vref_ctrl[6]),
    .vref_ctrl_5      (vref_ctrl[5]),
    .vref_ctrl_4      (vref_ctrl[4]),
    .vref_ctrl_3      (vref_ctrl[3]),
    .vref_ctrl_2      (vref_ctrl[2]),
    .vref_ctrl_1      (vref_ctrl[1]),
    .vref_ctrl_0      (vref_ctrl[0]),
    // .control              (vga_control_out),// you can't write like this
    .control_5        (vga_control_out[5]),
    .control_4        (vga_control_out[4]),
    .control_3        (vga_control_out[3]),
    .control_2        (vga_control_out[2]),
    .control_1        (vga_control_out[1]),
    .control_0        (vga_control_out[0]),
    .clk_cmp          (clk_cmp),
    
    // OUTPUTS
    .cmp_out_p              (cmp_out_p),
    .cmp_out_n              (cmp_out_n)
    // .rst_n            (rst_n)
    // BIASING
    
  );

  mixtop dut_mixtop(
    .rst_n( rst_n),
    .clk( clk),
    //CMP
    .cmp_out_n( cmp_out_n),
    .cmp_out_p( cmp_out_p),
    //VGA
    .vga_control_out( vga_control_out),// out from vga_control, into vga
    //ADC
    .v_in_ctrl( v_in_ctrl),
    .vref_ctrl( vref_ctrl),
    //to digital
    .adc_out_signed( adc_out_signed)

  );
  
  

  top #(
    .CIC_NIN                	(16        ),
    .CIC_NMAX               	(40        ),
    .CIC_NOUT               	(16        ),
    .DEMOD_OUT              	(6         ),
    .CLOCK_REC_OSR          	(CLOCK_REC_OSR),
    .SYS_CLK_FREQ           	(1600_000  ),
    .MIXING_FREQ            	(160_000   ),
    .DEMOD_FREQ             	(8_000    ),
    .SAMPLE_RATE            	(800       ),
    .SWEEP_SAMPLE_ACCUM_NUM 	(32        )
    )
  u_digital_top(
    .clk        	(clk),
    .rst        	(rst_n              ),
    .en         	(en                ),
    .adc_in     	(adc_out_signed     ),
    .char_out   	(char_out          ),
    .char_valid 	(char_valid        )
  );

  

endmodule : chiptop

