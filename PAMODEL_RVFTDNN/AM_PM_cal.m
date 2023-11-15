function [PindB, PoutdB, PM] = AM_PM_cal(IQ_in, IQ_out)
%AM_PM_CAL 此处显示有关此函数的摘要
%   此处显示详细说明
Pin = abs(IQ_in).^2;Pinmax=max(Pin);PindB=10*log10(Pin/Pinmax);
Pout = abs(IQ_out).^2; Poutmax=max(Pout);PoutdB=10*log10(Pout/Poutmax);
IQ_N=IQ_out./IQ_in;
NF=length(IQ_N);
for i=1:NF
    PM(i)=phase(IQ_N(i))/pi*180;
end
end

