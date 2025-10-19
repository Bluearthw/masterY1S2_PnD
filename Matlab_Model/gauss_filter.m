function [gt,qt]=gauss_filter(Bb,Tb,fs,sample_number)
%高斯滤波器
%**************************************************************************
%Bb             滤波器的3dB带宽
%Tb             码元时间
%fs             采样速率
%sample_number  采样个数
irfn = 3;                   
n    = irfn * sample_number;
mid  = (n./2);
t    = -mid/fs:1/fs:mid/fs;
gt   = 1/2*(erf(-sqrt(2/log(2))*pi*Bb*(t-1/2*Tb))+erf(sqrt(2/log(2))*pi*Bb*(t+1/2*Tb)));
 
qt=zeros(1,irfn*sample_number);
for i=1:irfn*sample_number
    for j=1:i
       qt(i)=qt(i)+gt(j)/sample_number/2;
    end
end