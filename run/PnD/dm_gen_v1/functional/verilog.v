//Verilog HDL for "PnD", "dm_gen_v1" "functional"


module dm_gen_v1 ( input vp, vn, output dm );
	assign dm = (vp==1 && vn==0) ? 1: 0;	

endmodule
