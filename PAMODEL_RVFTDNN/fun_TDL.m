function A = fun_TDL(I,Q,m)
%FUN_DTL I,Q分别是输入神经网络前的两路正交信号，用列向量表示，m表示记忆深度，A表示神经网络输入信号
%   此处显示详细说明
sample_num = length(I);
A = zeros(2*(m+1),sample_num);
for i = 1:m+1
    TD = fun_delay(I',i-1);
    A(i,:) = TD;
end
for i = 1:m+1
    TD = fun_delay(Q',i-1);
    A(m+1+i,:) = TD;
end
end

