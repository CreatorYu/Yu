function [jacobian_matrix]=jacobian(input, network_vector, input_num, node_num, output_num)
% input为神经网络的输入数据（包含m个样本），network_vector为神经网络的权值W与偏置b
%   此处显示详细说明
% calculate the relevant elements
row_num = size(input, 2);%获取样本数
% vector_num = size(network_vector,1);%获取参数向量的长度
% jacobian_matrix = zeros(row_num, vector_num);%生成雅可比矩阵（m x weight_num）

% calculate Weight matrix and calculate midden variables
W1 = zeros(node_num,input_num);%以2-10-1网络为例，W1 = [w11 w21 w31 ... w101 w12 w22 ... w102]
for i = 1:input_num
    for j = 1:node_num
        W1(j,i) = network_vector((i-1)*input_num+j);%node_num x input_num
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


% calculate jacobian matrix——δ1 = theta1；δ2 = theta2
theta2 = repmat(-1,output_num,row_num);
% w2t_multi_theta2 = repmat(W2',1,row_num).*theta2;
w2t_multi_theta2 = W2'*theta2;
theta1 = fun_deviate_of_tanh(Z1,node_num).*w2t_multi_theta2;
num = size(input,1);
input_T = input';
dW1 = [];
for i = 1:num
    dW1(:,(i-1)*node_num+1:i*node_num) = theta1'.*input_T(:,i);%得到的是∂em/∂wji 
end
%以2-10-1网络为例，dW1 为 dW1=[dw11 dw21 dw31 dw41 ... dw101 dw12 dw22 dw32 ... dw102]
% dW1 = theta1'.*input';
db1 = theta1';
% dW2 = theta2'.*A1';
dW2 = [];
theta2_T = theta2';
for i =1:output_num
    dW2(:,(i-1)*node_num+1:i*node_num) = theta2_T(:,i).*A1';
end
db2 = theta2';
jacobian_matrix = [dW1 db1 dW2 db2];
end

