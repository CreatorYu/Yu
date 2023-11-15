function NMSE = fun_nmse(Target,out)
%FUN_NMSE 此处显示有关此函数的摘要
%   此处显示详细说明
sum1 = sum((Target-out).^2);
sum2 = sum(Target.^2);
NMSE = 10*log10(sum1/sum2);
end

