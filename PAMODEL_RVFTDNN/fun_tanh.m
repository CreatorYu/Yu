function A = fun_tanh(Z,neuron_num)
%FUN_TANH �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
n_x = size(Z,2);%��ȡ����������������
A = zeros(neuron_num,n_x);%Ԥ�ȷ����ڴ棬���matlab�ٶ�
for i = 1:n_x
    for j = 1:neuron_num
        x = Z(j,i);
        A(j,i) = (exp(x)-exp(-1*x))./(exp(x)+exp(-1*x));
    end
end
end

