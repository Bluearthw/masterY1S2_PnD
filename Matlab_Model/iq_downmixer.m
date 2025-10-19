% 
% function complex_envelope = iq_downmixer(signal, osr, br, fc, fs)
%     % TODO: You may want to implement a better downsampling filter.
%     % TIP: Look up 'CIC' filters as inspiration for an efficient hardware 
%     % implementation. Also think about how you will generate the LO signal in
%     % hardware, looking up 'CORDIC' will set you in a correct direction.
%     % IQ downmixer
%     t = ((1 : numel(signal))' - 1) / fs;
%     upsampled_envelope = 2 * exp(-1j * 2 * pi * fc * t) .* signal;
%      plot_spectrum(upsampled_envelope,fs,'upsampled envelope from iq downmixer');
%     % apply a simple downsampling filter
%     filt = ones(2 * round(fs / (br * osr)) + 1);
%     upsampled_envelope = conv(upsampled_envelope, filt / sum(filt), 'same');
%     plot_spectrum(upsampled_envelope,fs,'upsampled envelope from iq downmixer');
%     % calculate number of output samples
%     n1 = numel(upsampled_envelope);
%     n2 = round((n1 - 1) * (br * osr) / fs) + 1;
%     % resample the complex envelope to the new sample rate
%     t1 = ((1 : n1)' - 1) / fs;
%     t2 = ((1 : n2)' - 1) / (br * osr);
%     complex_envelope = interp1(t1, upsampled_envelope, t2);
% end

function complex_envelope = iq_downmixer(signal, osr, br, fc_nom, fs)
    % IQ Downmixer with Matched Filter and CIC Filtering
    % signal -> Received modulated GMSK signal
    % osr    -> Oversampling ratio
    % br     -> Bit rate (bps)
    % fc     -> Carrier frequency (Hz)
    % fs     -> Sampling frequency (Hz)

    % Step 1: Generate Local Oscillator (LO) using CORDIC-compatible method
    R = fs/(br*osr);
    N= 2;

    t = ((1:numel(signal))' - 1) / fs;
    
    sweep_range = -500:100:500;  % Sweep from -500 Hz to +500 Hz around nominal
    best_energy = 0;
    best_fc = fc_nom;

    
    for offset = sweep_range
        fc_try = fc_nom + offset;
        lo = exp(-1j * 2 * pi * fc_try * t);
        mixed = signal .* lo;
        
        % Apply lowpass filter
        mixed_real_filtered = movmean(real(mixed), 32);
        mixed_imag_filtered = movmean(imag(mixed), 32);
        mixed_filtered = mixed_real_filtered + 1j * mixed_imag_filtered;
        
        % Power estimation (now AFTER LPF)
        energy = sum(abs(mixed_filtered).^2);
        
        fprintf('Current carrier frequency tried: %.2f Hz\n', fc_try);
        fprintf('Current energy found: %.2f\n', energy);

        if energy > best_energy
            best_energy = energy;
            best_fc = fc_try;
        end
    end

    fprintf('Best carrier frequency found: %.2f Hz\n', best_fc);

    lo = exp(-1j * 2 * pi * best_fc * t);
    % Step 2: Multiply Received Signal with LO to Shift to Baseband
    baseband_signal = lo .* signal;

    figure;
    subplot(2,2,1);
    plot(signal);
    subplot(2,2,2);
    plot(real(lo));
    subplot(2,2,3);
    real_base = real(baseband_signal);
    plot(real_base);
    subplot(2,2,4);
    image_base = imag(baseband_signal);
    plot(image_base);
    title('mixer');

    %plot_spectrum(baseband_signal,fs,'baseband_signal from iq downmixer');

    % Step 3: Apply CIC-based Low-Pass Filtering
    complex_envelope = custom_cic_decim(baseband_signal,R,N);

end 

function filtered_signal = custom_cic_decim(signal, R, N)
    % Custom CIC decimator without DSP System Toolbox
    % signal -> Input signal
    % R      -> Decimation factor
    % N      -> Number of CIC sections

    % Step 1: Integrator Stages (Cumulative Sum)
    integrator = signal;
    for i = 1:N
        integrator = cumsum(integrator); % Integrator section
    end

    figure;
    subplot(2,1,1)
    plot(real(integrator));
    subplot(2,1,2)
    plot(imag(integrator));
   
    % Step 2: Decimation (Keep every R-th sample)
    decimated_signal = integrator(1:R:end);
    figure;
    subplot(2,1,1)
    plot(real(decimated_signal));
    subplot(2,1,2)
    plot(imag(decimated_signal));

    % Step 3: Comb Stages (Derivative Operation)
    filtered_signal = decimated_signal;
    for i = 1:N
        filtered_signal = [diff(filtered_signal); 0]; % Comb section
    end



end
