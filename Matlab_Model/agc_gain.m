function out = agc_gain(in, alpha, cutoff_freq, fs)

    % Adaptive AGC with exponential moving average (EMA)
    % in          -> Input signal
    % alpha       -> Smoothing factor (0 < alpha < 1)
    % cutoff_freq -> Cutoff frequency for low-pass filter (Hz)
    % fs          -> Sampling frequency (Hz)
    

    % Apply Low-Pass Filter
   % in = agc_lowpass_filter(in, cutoff_freq, fs);

   out = in./max(abs(in));


%     % Initialize power estimate
%     power_estimate = abs(in(1));  
%     out = zeros(size(in));

%     for i = 1:length(in)
%         % Update power estimate using exponential moving average
%         power_estimate = alpha * abs(in(i)) + (1 - alpha) * power_estimate;

%         % Compute gain (prevent division by zero)
%         gain = 1 / max(power_estimate, 1e-6);

%         % Apply gain to normalize the signal
%         out(i) = in(i) * gain;
%     end


% % Step 3: Plot Input vs Output Signals
%     t = (0:length(in)-1) / fs; % Time vector

%     figure;
%     subplot(2,1,1);
%     plot(t, in, 'b');
%     title('Original Input Signal');
%     xlabel('Time (s)'); ylabel('Amplitude');
%     grid on;

%     subplot(2,1,2);
%     plot(t, out, 'r');
%     title('AGC Output Signal (Filtered & Normalized)');
%     xlabel('Time (s)'); ylabel('Amplitude');
%     grid on;

end