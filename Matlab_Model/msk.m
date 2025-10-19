clc; % 清除命令窗口
clear; % 清除工作空间变量
close all; % 关闭所有图形窗口
warning off; % 关闭警告信息
rng('default')
rng(2)
 
 
Num  = 40; % 定义比特数
bits = rand(1,Num)>=0.5; % 生成随机比特序列
f1   = 1; % 定义载波频率
f2   = 2; % 定义载波频率
 
 
t    = 0:1/100:4-1/100; % 定义时间序列
dt   = length(t);
 
% QPSK
sa1 = cos(2*pi*f1*t); % 生成载波信号（对应比特1）
sa2 = sin(2*pi*f1*t); % 生成载波信号（对应比特1）
 
%串并
data= 2*bits(1:end)-1;
%采样率
Nsamp= 4;
%码元速率 
Rb   = 1e3;      
%载波频率 
fc   = dt*Rb;     
MB   = fc/Rb; 
for i = 1:Nsamp
    Dsamp(i:Nsamp:Num*Nsamp) = data;
end

filt = gaussian_filter(Rb, Nsamp);
complex_envelope = conv(complex_envelope, filt, 'same');


%计算相位
phase    = zeros(1,Num*Nsamp);
phase(1) = Dsamp(1) * pi/2/Nsamp;
for i = 2:Num*Nsamp
    phase(i) = phase(i-1) + Dsamp(i-1) * pi/2/Nsamp;
end
Imsk2= interp(cos(phase),MB); 
Qmsk2= interp(sin(phase),MB); 
 
 
 
% 调制
CARRIERI=[];
Imsk=[];
CARRIERQ=[];
Qmsk=[];
for i=1:length(phase)
    tmps1 = Imsk2(MB*(i-1)+1:MB*i);
    tmps2 = Qmsk2(MB*(i-1)+1:MB*i);
    Imsk=[Imsk,tmps1.*sa1];
    Qmsk=[Qmsk,tmps2.*sa2];
    CARRIERI=[CARRIERI,sa1];
    CARRIERQ=[CARRIERQ,sa2];
end
%相加
Ymsk = Imsk+Qmsk;
 
 
figure;
plot(phase);
 
 
figure;
subplot(421);plot(Imsk2);title('Imsk');
subplot(423);plot(CARRIERI);title('cos');
subplot(425);plot(Imsk);title('Imsk * cos');
 
 
 
subplot(422);plot(Qmsk2);title('Qmsk');
subplot(424);plot(CARRIERQ);title('sin');
subplot(426);plot(Qmsk);title('Qmsk * sin');
 
 
subplot(4,2,[7,8]);
plot(Ymsk);title('MSK');
 
 
 
%%
Ydemod1  = Imsk.*CARRIERI;
Ydemod2  = Qmsk.*CARRIERQ;
 
w        = hamming(127);
yfilter1 = filter(w,1,Ydemod1);
yfilter2 = filter(w,1,Ydemod2);
 
%将滤波器w进行量化，复制到FPGA的fir滤波器核中
w2      = round(1024*w')
for i = 1:127
    fprintf('%d,',w2(i));
end
%抽取 
for i=1:length(phase) 
    yfilter1c(i)=yfilter1(MB*(i-1)+1); 
    yfilter2c(i)=yfilter2(MB*(i-1)+1); 
end 
%差分解调 
ydemsk(1) = yfilter2c(Num); 
for i = 2:Num 
    ydemsk(i) = yfilter2c(i*Nsamp)*yfilter1c((i-1)*Nsamp) - yfilter1c(i*Nsamp)*yfilter2c((i-1)*Nsamp); 
end 
y = ydemsk>0; 
y = 2*y-1; 
% demod_data = yfilter1-yfilter2;
figure % 创建图形窗口
subplot(211)
stairs(data); title('原数据'); 
subplot(212)
stairs(y); title('MSK解调输出数据'); 
figure % 创建图形窗口
subplot(321) % 创建3行1列的子图，并定位到第一个
plot(Ydemod1,'b','linewidth',1) % 绘制ASK调制信号
title('MSK I解调'); % 设置标题
grid on % 打开网格
subplot(322) % 创建3行1列的子图，并定位到第一个
plot(Ydemod2,'b','linewidth',1) % 绘制ASK调制信号
title('MSK Q解调'); % 设置标题
grid on % 打开网格
subplot(323) % 创建3行1列的子图，并定位到第一个
plot(yfilter1,'b','linewidth',1) % 绘制ASK调制信号
title('滤波I'); % 设置标题
grid on % 打开网格
subplot(324) % 创建3行1列的子图，并定位到第一个
plot(yfilter2,'b','linewidth',1) % 绘制ASK调制信号
title('滤波Q'); % 设置标题
grid on % 打开网格
 
subplot(3,2,[5,6]) % 定位到第二个子图
stairs(y,'b','linewidth',1) % 绘制载波信号
title('输出'); % 设置标题
grid on % 打开网格