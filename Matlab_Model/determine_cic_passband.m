function determine_cic_passband(R, N, M, fs)
    % Function to compute and plot the passband of a CIC filter
    % R  -> Decimation factor
    % N  -> Number of integrator-comb sections
    % M  -> Differential delay (usually 1)
    % fs -> Input sampling frequency (Hz)

    % Frequency range (normalized to Nyquist frequency)
    f = linspace(0, fs/2, 1000); 
    omega = 2 * pi * f / fs;

    % Compute CIC filter magnitude response
    H = abs((sin(M * omega * R / 2) ./ sin(omega / 2))).^N;
    H(omega == 0) = 1; % Avoid division by zero

    % Normalize magnitude response
    H = H / max(H);

    % Convert to dB
    H_dB = 20 * log10(H);

    % Find -3 dB passband frequency
    idx = find(H_dB > -3, 1, 'last'); % Last index before dropping below -3 dB
    passband_freq = f(idx);

    % Plot frequency response
    figure;
    plot(f, H_dB, 'b', 'LineWidth', 1.5);
    hold on;
    yline(-3, 'r--', 'LineWidth', 1.2); % Mark -3 dB point
    xline(passband_freq, 'g--', 'LineWidth', 1.2, sprintf('%.2f Hz', passband_freq));
    xlabel('Frequency (Hz)');
    ylabel('Magnitude (dB)');
    title(sprintf('CIC Filter Frequency Response (R=%d, N=%d, M=%d)', R, N, M));
    grid on;
    ylim([-60 5]);

    % Display passband frequency
    fprintf('Passband frequency (-3 dB point): %.2f Hz\n', passband_freq);
end

