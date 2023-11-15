function J = fun_jacobian(E,neuron_num,W2,A0,A1,Z1)
%FUN_JACOBIAN 此处显示有关此函数的摘要
%   此处显示详细说明
n_x = size(E,2);            %m
F2 = 1+zeros(1,n_x);
F1 = fun_deviate_of_tanh(Z1,neuron_num(1));
theta2 = -F2;
W2T = W2';
theta1 = zeros(neuron_num(1),n_x);
for i = 1:neuron_num(1)
    theta1(i,:) = (F1(i,:)*W2T(i,:)).*theta2;
end
J = zeros(n_x,2*(neuron_num(1)+1));
theta1T = theta1';
for i = 1:neuron_num(1)
    J(:,i) = A0'.*theta1T(:,i);
end
J(:,neuron_num(1)+1) = sum(theta1T,2)/neuron_num(1);

A1T = A1';
for i = 1:neuron_num(1)
    J(:,neuron_num(1)+1+i) = theta2'.*A1T(:,i);
end
J(:,end) = theta2';
end

