function [output]=neural_network(input, network_vector, input_num, node_num, output_num)
%NEURAL_NETWORK input为神经网络的输入数据（包含m个样本），network_vector为神经网络的权值W与偏置b.
%   此处显示详细说明
%calculate the weight matrix
W1 = zeros(node_num,input_num);%以2-10-1网络为例W1 = [w11 w21 w31 ... w101 w12 w22 ... w102]
for i = 1:input_num
    for j = 1:node_num
        W1(j,i) = network_vector((i-1)*input_num+j);
    end
end
b1 = zeros(node_num,1);
for i = 1:node_num
    b1(i) = network_vector(input_num*node_num+i);
end
Z1 = W1*input+b1;
A1 = fun_tanh(Z1,node_num);

W2 = zeros(output_num,node_num);
for i = 1:output_num
    for j =1:node_num
        W2(i,j) = network_vector((input_num*node_num)+node_num+(i-1)*node_num+j);
    end
end
b2 = zeros(output_num,1);
for i = 1:output_num
    b2(i) = network_vector((input_num*node_num)+node_num+output_num*node_num+i);
end
Z2 = W2*A1+b2;
A2 = Z2;
output = A2;
end

