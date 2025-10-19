function raw = gmsk_demodulate(complex_envelope,~, osr,fs)

% TODO: This is a very simple demodulator to get you started. There are
% lots of things that can be improved!
% TIP: Search for demodulation methods online. Are you going for the
% coherent or incoherent approach? incoherent

% apply a simple filter 
% filt = ones(osr / 2 + 1);
% complex_envelope = conv(complex_envelope, filt / sum(filt), 'same');
% filt = hamming(8); % Create Hamming window of order 127
% filt = filt / sum(filt); % Normalize the filter
%filt = [0.0545 0.1109 0.2190 0.3016 0.3016 0.2190 0.1109 0.0545];

% 
% filt = [1787, 3636, 7171, 9884, 9884, 7171, 3636, 1787];
% complex_envelope = conv(complex_envelope, filt, 'same');

N = 7;                       % Filter order (32 taps total)
fc = 0.125;                   % Normalized cutoff frequency (0.125 × fs)
h = fir1(N, fc, hamming(N+1)); % Use a Hamming window for good side-lobe suppression
complex_envelope = conv(complex_envelope, h, 'same');
plot_spectrum(complex_envelope,fs,'complex envelope after filtering');

% extract phase
phase = unwrap(angle(complex_envelope));

% calculate derivative
raw = diff(phase) * osr / (0.5 * pi);

figure;
subplot(2,1,1); plot(phase);
title('phase');
subplot(2,1,2); plot(raw);
title('raw = phase derivative');

window_size = 8;  % You can adjust this size for more or less smoothing
ma_filter = ones(1, window_size) / window_size;
raw_filtered = conv(raw, ma_filter, 'same');

figure;
subplot(2,1,1); plot(raw); title('Original raw');
subplot(2,1,2); plot(raw_filtered); title('Smoothed raw (Moving Average)');

raw = raw_filtered;



end