function [V_out,Av_power_diff] = fun_RVTDFNN(V,X,Y,G,m)
%FUN_RVTDFNN 此处显示有关此函数的摘要
% m表示记忆深度，V表示预失真器输出，X表示预失真器输入，Y表示功放输出，G表示PA的平均功率增益
%   此处显示详细说明
Gain = 10^(G/20);
Y = Y./Gain;              
input_I = real(Y);
input_Q = imag(Y);
input = fun_TDL(input_I,input_Q,m);

target_I = real(V);
target_Q = imag(V);
sample_num = length(input_Q);
target = zeros(2,sample_num);
target(1,:) = target_I';
target(2,:) = target_Q';
% 神经网络的输入与输出都为行向量
 
% 创建神经网络
hidensize = 15;
trainFcn = 'trainlm';      %采用LM算法作为反向传播算法
net = feedforwardnet(hidensize,trainFcn);  %采用feedforwardnet函数创建一个2层前向神经网络;
net = configure(net,input,target);     %传输训练数据，每一列应代表着不同的样本
%view(net);
 
% 训练网络
net = train(net,input,target);

% 运用网络
X_in = fun_TDL(real(X),imag(X),m);
output = net(X_in);

V_out = output(1,:)'+1i*output(2,:)';
P_vout = fun_Power_cal(V_out);
Pin = fun_Power_cal(X);
Av_power_diff = P_vout-Pin;
%fprintf("Av_Power_diff=%f\n",Av_Power_diff);
end

