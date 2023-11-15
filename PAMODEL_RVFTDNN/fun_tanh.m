function A = fun_tanh(Z,neuron_num)
%FUN_TANH 此处显示有关此函数的摘要
%   此处显示详细说明
n_x = size(Z,2);%获取样本数量（列数）
A = zeros(neuron_num,n_x);%预先分配内存，提高matlab速度
for i = 1:n_x
    for j = 1:neuron_num
        x = Z(j,i);
        A(j,i) = (exp(x)-exp(-1*x))./(exp(x)+exp(-1*x));
    end
end
end

