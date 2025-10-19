clc; clear; close all;

% 仿真参数
fs = 100e3;  % 采样率 (100 kHz)
Rs = 10e3;   % 符号率 (10 kHz)
osr = fs / Rs; % 过采样率 (10 samples per symbol)
N = 1000;    % 发送符号数

% 生成 GMSK 调制信号
data = (randi([0 1], N, 1) );  % 生成二进制数据 {-1,1}
gmskMod = comm.GMSKModulator('BitInput', true, 'SamplesPerSymbol', osr);
tx_signal = gmskMod(data); % GMSK 调制信号

% 添加噪声
rx_signal = awgn(tx_signal, 20, 'measured'); % 添加 AWGN 噪声

% -------------- 时钟恢复 (基于锁相环 PLL) --------------
% 初始化变量
timing_error = 0;  % 定时误差
mu = 0.5;  % 采样偏移初始值 (0.5表示在符号中间采样)
alpha = 0.01; % 环路增益
output_symbols = [];  % 存储恢复的符号

% 迭代进行时钟恢复
for i = 1:length(rx_signal)-osr
    % 插值 (线性插值)
    sample_point = i + mu;
    if sample_point + 1 > length(rx_signal)
        break;
    end
    y0 = rx_signal(floor(sample_point));
    y1 = rx_signal(ceil(sample_point));
    symbol = (1 - (sample_point - floor(sample_point))) * y0 + ...
             (sample_point - floor(sample_point)) * y1;

    % 存储符号
    output_symbols = [output_symbols, symbol];

    % 计算定时误差 (基于平方法 TED)
    if i > 2 * osr
        timing_error = (rx_signal(i)^2 - rx_signal(i - osr)^2);
        mu = mu + alpha * timing_error; % 调整定时点
    end

    % 限制 mu 在合法范围内 (防止采样点超出)
    if mu >= osr
        mu = mu - osr;
    elseif mu < 0
        mu = mu + osr;
    end
end

% -------------- 符号判决 (符号提取) --------------
bits_decoded = output_symbols > 0; % 符号判决
bits_received = double(bits_decoded); % 转换为二进制格式

% -------------- 绘制结果 --------------
figure;
subplot(2,1,1);
plot(real(rx_signal), 'b'); hold on;
plot(1:osr:length(rx_signal), real(output_symbols), 'ro');
title('GMSK 时钟恢复');
xlabel('采样点'); ylabel('信号幅度');
legend('接收信号', '采样点');

subplot(2,1,2);
stem(bits_received(1:50), 'r', 'filled');
title('恢复的比特流');
xlabel('符号索引'); ylabel('比特值');

