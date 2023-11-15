%% 计算信号的功率（dBm）
function Power_dB= fun_Power_cal(IQ_out1)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
j=sqrt(-1);
Z0=50;                                                                      %输入阻抗值
% Sampling_rate=3.84e6*4;       
Energy=sum(abs(IQ_out1).^2)/Z0/2;                                           %求功率之和：P=½[(|U|^2)/Z0]，Z0表示输入阻抗。此时的功率符号不是dB，而是W。
Power=Energy/(length(IQ_out1));                                           %将功率之和Energy除以输入信号个数，求得平均功率。-1的目的在于不考虑，第一个点功率为0的情况。
Power_dB=10*log10(Power)+30;                                                %将输入功率的单位转换为dBm形式——10*lg(P/1mW)=10*lg(P)+30
end