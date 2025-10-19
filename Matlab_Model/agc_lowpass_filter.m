function filtered_signal = agc_lowpass_filter(signal, cutoff_freq, fs)

    % Design a low-pass filter using a Butterworth filter
    order = 4;  % Filter order
    [b, a] = butter(order, cutoff_freq / (fs / 2), 'low');
    
    % Apply the filter
    filtered_signal = filtfilt(b, a, signal);

    % Frequency response of the filter
    [h, f] = freqz(b, a, 1024, fs);
    
    % Plot
    figure;
    semilogx(f, 20*log10(abs(h)));
    grid on;
    xlabel('Frequency (Hz)');
    ylabel('Magnitude (dB)');
    title('Frequency Response of Low-Pass Filter');
    ylim([-80 5]);
    
end
