
# Analog

### Library

All analog design files are placed inside the library `PnD`.  
If it wasn't included automatically, the `PnD` folder is located under the `/run` directory.  
When adding a new library after a pull, **use the same name: `PnD`**.

---

### System Verification

#### Combined VGA, ADC, and Digital Control Test
- Run **maestro** of `mix_vga_adc_control_TB`.
- To change `vin`, open the schematic and find `V6`.
- Available waveforms: `vin`, `vga_out`, `vga_control`, `adc_out_unsigned`, and `signed_adc_out`.

---

### Individual Block Testing

- **Standalone VGA Test**  
  Run maestro of `vga_v6_AC_TB`.  
  > Note: This test does not include AGC logic (implemented in the digital block).

- **Standalone OTA Performance**  
  Run maestro of `OTA_symmetrical_v5_Triansient_TB`.  
  > Note: A high-pass filter is added to its input.

- **Standalone ADC Test**  
  Run maestro of `dac_v3_TB`.  
  > `adc_out` is the conversion result of `vin`.  
  > This waveform is produced by connecting the ADC digital output to an ideal DAC for easier demonstration.

- **Standalone Comparator Test**  
  Run maestro of `comparator_v2_Tran_TB`.

---

### FFT Test for ENOB

To verify ENOB:

1. Go to the `PnD` library.
2. Run maestro of `lbl_mix_test_FFT`.
3. Single-click `d2a_analog_zeroT`.
4. Click **Measurements** → **Spectrum** on the toolbar.
5. Set parameters:
   - **FFT input method**: `Calculate Stop Time`
   - **Start Time**: `100u`
   - **Sample Count/Freq**: `2048` and `204.8k`
   - **Window Type**: `Rectangular`
   - **Start/End Freq**: `100` and `204.8k`
6. Click **Plot**.

---

# Digital

### Functional Verification

#### Run testbenches from `gmsk-group-3` folder

```bash
source setup  # (Add Genus setup if missing)
cd run
./commands/digital/test_top_snr20.sh
```

- Runs testbench with input data: `SNR = 20dB`.

```bash
./commands/digital/test_top_snr16.sh
```

- Runs testbench with input data: `SNR = 16dB`.

> Close all **SimVision** windows to view the comparison between input and output messages in Terminal.

#### Original Message

```
333333333 abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789 !@#$%^&*()_+-=~`;:"<>./?
```

#### Decoded Message Output

- Stored in: `digital/tb/out_char.txt`

#### Custom Input Messages

To try different inputs:
1. Modify and run `Matlab_model/main_model.m`
2. It will generate `adc_input.txt` in the same folder.

---

### Synthesis

```bash
run run/commands/synthesis/run_synthesis.sh
```

- Auto ungroup is set to `none` by default to display every component.

> Remember to commit the synthesis file to the **final branch**.

---

# Mixed-Signal

```
We did not run a completely mix_signal but we see sth, the screenshot is in screenshot/
```
### Steps

```
1. Open terminal at folder gmsk-group-3/
2. cd scripts/
3. . run_mix
4. if it does not work, at folder run/ : source commands/mixed_signal/test_chiptop.sh

```
