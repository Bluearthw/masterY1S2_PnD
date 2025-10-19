module  mixer (
    input  wire signed [7:0]  adc_input,
    input  wire signed [7:0] carrier_input,
    output wire signed [15:0] mixer_output
);


assign mixer_output = adc_input*carrier_input;
 

    
endmodule