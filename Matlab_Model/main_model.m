clear
close all

% increased #bits of ADC has more noise 

%% Settings

% baseband modeling parameters
use_fec = false; % enable/disable forward error correction
bt = 0.5; % gaussian filter bandwidth
snr = 15; % in-band signal to noise ratio (dB) level 8
osr = 8; % oversampling ratio

% RF modeling parameters
use_simwave = false;
use_rf = true; % enable/disable RF model
adc_levels = 64; % number of ADC output codes (NB: #bits = log2[#levels])
br = 100; % bit rate (bit/s)
fc = 20.0e3; % carrier frequency (Hz)
fs = 320.0e3; % sample frequency (Hz)
alpha = 0.95 ;
load('waveform/gmsk_level_0.mat', 'data');
simdata = double(data); % Assign the loaded data to simdataS

% plotting parameters
plot_raw_data = true;
plot_rf_signal = false;
plot_encode = true;
% input message
%message_in = '00000GENERAL MANUAL GMSK100.GENERAL MANUAL GMSK100.GENERAL MANUAL GMSK100.GENERAL MANUAL GMSK100.GENERAL MANUAL GMSK100.GENERAL MANUAL GMSK100.GENERAL MANUAL GMSK100.GENERAL MANUAL GMSK100.GENERAL MANUAL GMSK100.GENERAL MANUAL GMSK100.GENERAL MANUAL GMSK100.';
%message_in = 'HHHHHHHHHHHH Hello, we are group three';
message_in = '3333333333333333333333333';

%message_in = 'hellohello';
%% Modulation

% varicode encoding
plain_in = varicode_encode(message_in);

% FEC encoding (optional)
if use_fec
    encoded_in = fec_encode(plain_in);
else
    encoded_in = plain_in;
end

% GMSK modulation
complex_envelope_in = gmsk_modulate(encoded_in, bt, osr);
  % plot_spectrum(complex_envelope_in,fs,'complex envelope in');
% figure;
% subplot(2,1,1); plot(encoded_in);
% subplot(2,1,2); plot(angle(complex_envelope_in));
% upmixing: signal is upconverted to the carrier frequency fc , with a
% sample frequency fs 
% Nyquist theorem: fs > 2fc
if use_rf
    signal_in = iq_upmixer(complex_envelope_in, osr, br, fc, fs);
   % plot_spectrum(signal_in,fs,'Signal in');
end


%% Channel model

% add noise
if use_rf
    signal_out = signal_add_noise(signal_in, snr, br, fs);
      % plot_spectrum(signal_out,fs,'signal out');
else
    complex_envelope_out = complex_envelope_add_noise(complex_envelope_in, snr, osr);
end


%% Demodulation

if use_rf
    if use_simwave
        fs = 100000;
        br = 100;
        fc = 20000;
        bt = 0.5;
        signal_quantized = agc_gain(simdata,alpha,fc, fs);
        complex_envelope_out = iq_downmixer_cic(signal_quantized, osr, br, 20.0e3 , fs);
    else
        % automatic gain control
        signal_agc = agc_gain(signal_out);
        % plot_spectrum(signal_agc,fs,'agc');
        
        % quantization
        signal_quantized = quantize(signal_agc, adc_levels);
  

        % Assume signal_quantized is in range [0, 1]
        signal_quantized_range = min(max(signal_quantized, 0), 1);  % clip just in case

        % Scale to [0, 255] and round
        signal_scaled = round(signal_quantized * 255);

        % Convert to fixed-point unsigned 8-bit integer (no fractional bits)
        data_fixed = fi(signal_quantized, 1, 8, 7);  % unsigned, 8 bits, 0 fractional bits

        fileID = fopen('adc_input.txt','w');
        for i=1:length(data_fixed)
                bin_str = bin(data_fixed(i));
                fprintf(fileID,"%s\n",bin_str);
        end
        fclose(fileID);
    
        %downmixing
        complex_envelope_out = iq_downmixer_cic(signal_quantized, osr, br, 20.0e3 , fs);

        figure;
        subplot(2,1,1);
        real_out = real(complex_envelope_out);
        plot(real_out);
        subplot(2,1,2);
        image_out = imag(complex_envelope_out);
        plot(image_out);
        title("complex envelope");
       
        plot_spectrum(complex_envelope_out,fs,'complex envelope out');
    end

end

% GMSK demodulation
raw_out = gmsk_demodulate(complex_envelope_out, bt, osr,fs);
plot_spectrum(raw_out,fs,'raw out');
% plot_spectrum(raw_out,fs,'raw out');

% clock recovery
clock_out = clock_recovery(raw_out, osr);

% extract bits
encoded_out = extract_bits(raw_out, clock_out, osr);

% FEC decoding (optional)
if use_fec
    plain_out = fec_decode(encoded_out);
else
    plain_out = encoded_out;
end

% varicode decoding
message_out = varicode_decode(plain_out)
%compare_char_streams(message_in,message_out);


%% Plotting

raw_in = repelem(encoded_in * 2 - 1, osr, 1);

if plot_raw_data
    figure('Name', 'Raw data');
    time_in = ((1 : numel(raw_in))' - 1) / osr;
    time_out = ((1 : numel(raw_out))' - 1) / osr;
    time_plain = (1: numel(plain_out))'-0.5;
    % h = plot( time_out, raw_out, '', ...
    %          clock_out, encoded_out * 2 - 1, 'sk' );
    h = plot(time_in, raw_in, '-', ...
             time_out, raw_out, '-', ...
             clock_out, encoded_out * 2 - 1, 'sk');

    set(h, {'MarkerFaceColor'}, get(h, 'Color')); 
    grid();
    legend('input before modulation', ...
        'output after demodulation', ...
        'encoded out');
end

if plot_encode
    figure('Name', 'encoded bits');
    clock_in = (1 : numel(encoded_in))';

    % h = plot( time_out, raw_out, '', ...
    %          clock_out, encoded_out * 2 - 1, 'sk' );
    h = plot(clock_in, encoded_in * 2 -1, '-', ...
             clock_out, encoded_out * 2 - 1, 'sk');

    set(h, {'MarkerFaceColor'}, get(h, 'Color')); 
    grid();
    legend('input before modulation', ...
        'output after demodulation', ...
        'encoded out')
end

if plot_rf_signal && use_rf
    figure('Name', 'RF signal');
    time_in = ((1 : numel(signal_in))' - 1) / osr;
    time_out = ((1 : numel(signal_out))' - 1) / osr;
    subplot(2,1,1)
    plot(time_in, signal_in, '-');
    subtitle("TX signal")
    title("RF Transmission Behaviour")
    subplot(2,1,2)
    plot(time_out,signal_out,'-')
    subtitle("RX signal")
    grid();
end


