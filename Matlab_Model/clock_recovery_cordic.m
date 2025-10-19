function clock = clock_recovery_cordic(signal, osr)
    % Gardner Clock Recovery with CORDIC-based phase correction

    % 过采样率（Oversampling Rate）
    n = floor(numel(signal) / osr);
    
    % 预分配数组（适合硬件）
    clock = zeros(n, 1, 'like', signal); 
    timing_error = zeros(n, 1, 'like', signal); 

    % CORDIC 参数（可调整）
    alpha = 0.2;   % 误差调整增益
    phase_correction = 0;  % 初始相位偏移
    
    % CORDIC 计算角度 & 正弦波查找表
    lut_size = 1024; % LUT 大小
    cordic_lut = linspace(0, 2*pi, lut_size); % 角度查找表
    sin_lut = sin(cordic_lut); % 预计算正弦值
    cos_lut = cos(cordic_lut); % 预计算余弦值

    % CORDIC 计算相位调整（用 LUT）
    function angle = cordic_phase_correction(error)
        idx = mod(round(error * lut_size / (2*pi)), lut_size) + 1;
        angle = cos_lut(idx) * error; % CORDIC 近似计算
    end

    % 开始符号恢复
    for k = 3:n
        % 采样当前符号位置
        sample_now  = signal(k * osr + round(phase_correction)); 
        sample_prev = signal((k-1) * osr + round(phase_correction)); 
        sample_prev_prev = signal((k-2) * osr + round(phase_correction)); 

        % Gardner TED 计算时钟误差
        timing_error(k) = sample_prev * (sample_now - sample_prev_prev);

        % 用 CORDIC 计算相位误差修正
        phase_correction = phase_correction + alpha * cordic_phase_correction(timing_error(k));
        
        % 计算时钟位置
        clock(k) = k - 0.5 + phase_correction;

        % 初始化前两个时钟点
        if k == 3
            clock(1) = 1 - 0.5 + phase_correction;
            clock(2) = 2 - 0.5 + phase_correction;
        end
    end
end
