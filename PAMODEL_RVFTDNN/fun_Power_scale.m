function IQ1=fun_Power_scale(P1,P2,IQ2)
%
dB_diff=P1-P2;
N=length(dB_diff);
for i=1:N
IQ1(:,i)=IQ2(:,i)*10^(dB_diff(i)/20);                                       %IQ1(:,i)就表示A的第i列的所有元素；即将IQ_start中所有元素乘上
end
end