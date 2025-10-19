function plot_spectrum(signal,fs,Title)
%PLOT_SPECTRUM Summary of this function goes here
%   Detailed explanation goes here
Y = fft(signal);
L = length(signal);
P2 = abs(Y/L);
P1 = P2(1:floor(L/2+1));
P1(2:end-1) = 2*P1(2:end-1);

f = fs*(0:(L/2))/L;
figure;
plot(f,P1);
title(Title);
xlabel("f(Hz)")
ylabel("|P1(f)|")
end

