function clock = clock_recovery(signal, osr)


    n = floor(numel(signal) / osr);
    clock = (1 : n)' - 0.5;

% 
%     % gardner approach
%     % Number of samples per symbol (Oversampling Rate)
%     n = floor(numel(signal) / osr);
%     
%     % Initialize clock phase and estimated timing error
%     clock = zeros(n, 1);
%     timing_error = zeros(n, 1); 
%     alpha = 0.2; % Loop filter gain (adjustable)
%     phase_correction = 0;
%   
%     % Loop through the signal to estimate timing
%     for k = 3:n
%         % Gardner TED:
%         %   e[k] = y[k-1] * (y[k] - y[k-2])
%         %timing_error = signal(k-1) * (signal(k) - signal(k-2));
%     
%         % Sample at estimated symbol locations
%         sample_now   = signal(k * osr + round(phase_correction)); 
%         sample_prev  = signal((k-1) * osr + round(phase_correction)); 
%         sample_prev_prev  = signal((k-2) * osr + round(phase_correction)); 
%         
%         % Gardner TED Formula
%         timing_error(k) = sample_prev * (sample_now - sample_prev_prev);
% 
%         % Adjust clock phase using a simple loop filter
%         phase_correction = phase_correction + alpha * timing_error(k);
%     
%         % Update clock estimates
%         clock(k) = k - 0.5 + phase_correction;
%         if k ==3
%               clock(1) = 1- 0.5 + phase_correction;
%               clock(2) = 2- 0.5 + phase_correction;
%         end
%        
%     end

end