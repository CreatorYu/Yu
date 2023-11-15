function [PindB, AM, PM]=fun_AM_PM_cal(IQ_in, IQ_out)
% This function plot the gain versus the normalized input power
Pin=abs(IQ_in).^2; Pinmax=max(Pin); PindB=10*log10(Pin/Pinmax);
IQ_N=IQ_out./IQ_in;
Gain=abs(IQ_N);                                                             %取增益的模
AM=20*log10(Gain);
NF=length(IQ_N);
for i=1:NF
    PM(i)=phase(IQ_N(i))/pi*180;
end
end
