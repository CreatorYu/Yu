function NMSE = fun_nmse(Target,out)
%FUN_NMSE �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
sum1 = sum((Target-out).^2);
sum2 = sum(Target.^2);
NMSE = 10*log10(sum1/sum2);
end

