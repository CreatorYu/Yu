function [V_out,Av_power_diff] = fun_RVTDFNN(V,X,Y,G,m)
%FUN_RVTDFNN �˴���ʾ�йش˺�����ժҪ
% m��ʾ������ȣ�V��ʾԤʧ���������X��ʾԤʧ�������룬Y��ʾ���������G��ʾPA��ƽ����������
%   �˴���ʾ��ϸ˵��
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
% ������������������Ϊ������
 
% ����������
hidensize = 15;
trainFcn = 'trainlm';      %����LM�㷨��Ϊ���򴫲��㷨
net = feedforwardnet(hidensize,trainFcn);  %����feedforwardnet��������һ��2��ǰ��������;
net = configure(net,input,target);     %����ѵ�����ݣ�ÿһ��Ӧ�����Ų�ͬ������
%view(net);
 
% ѵ������
net = train(net,input,target);

% ��������
X_in = fun_TDL(real(X),imag(X),m);
output = net(X_in);

V_out = output(1,:)'+1i*output(2,:)';
P_vout = fun_Power_cal(V_out);
Pin = fun_Power_cal(X);
Av_power_diff = P_vout-Pin;
%fprintf("Av_Power_diff=%f\n",Av_Power_diff);
end

