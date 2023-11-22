clc
clear;
addpath('D:\MATLAB2020\bin\bin\MATLAB_CODE\CODE\mycode\data');
addpath('D:\MATLAB2020\bin\bin\MATLAB_CODE\CODE\mycode\fun_lab');

%% Load Date 
Center_F=2.5*1e6;
Channel_F=[-5.3 0 5.3]*1e6;
Bandwidth=5e6;
Samplerate=30.72e6;                                                         %采样频率设置为30.72MHz

j = sqrt(-1);
I1 = importdata('LTE_5MHz_In_I_30_72r0_PAPR_9r0_0_5ms.txt');                %加载同相输入信号I1
Q1 = importdata('LTE_5MHz_In_Q_30_72r0_PAPR_9r0_0_5ms.txt');                %加载正交输入信号Q1
IQ_sample=I1+j*Q1;                                                          %得到正交调制信号IQ_Sample=I1+j*Q1
N_sample=length(IQ_sample);                                                 %获取已调信号的长度
IQ_start=IQ_sample(1:N_sample);                                             %将已调信号注入到变量IQ_start中

t1 = load('DPD_Mea_Indirect_Learning_Phase_cal_20.mat','X1');                 %加载文件.mat 中的变量X1；并将其加载到结构体(struct)数组t1当中
Xt1 = t1.X1;                                                                  %调用结构体数组（单元）ti中的数据X1
Pin_Xt = fun_Power_cal(Xt1)-2;                                               %Xt的功率是X1的平均功率！！！！！！！！

P_IQload = fun_Power_cal(IQ_start);                                          %计算已调信号IQ_start的功率（dBm）
X1 = fun_Power_scale(Pin_Xt,P_IQload,IQ_start);                               %将IQ_start放缩到abs(Xt1)/abs(IQ_start)倍
sample_num = length(X1);

%% Target PA
load("D:\MATLAB2020\bin\bin\MATLAB_CODE\CODE\mycode\data\Wiener_Model_30dBm.mat",'M', 'A', 'Plow', 'Pinm_dB', 'Num_section', 'Gstatic', 'PX');
Y1=fun_Wiener_Model_LUT_cal(X1, M, A, Plow, Pinm_dB, Num_section, Gstatic, PX);
Pin = fun_Power_cal(X1);Pout = fun_Power_cal(Y1);
G = Pout-Pin;

input_I = real(X1);
input_Q = imag(X1);
target_I = real(Y1);
target_Q = imag(Y1);
sample_num = length(input_Q);
input = zeros(2,sample_num);
input(1,:) = input_I';
input(2,:) = input_Q';
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

output = net(input);

errors = gsubtract(target,output);
 performance = perform(net,target,output)       %performance = E = 1/2N*sum((target-output)^2)
 
 %% 分析
 j = sqrt(-1);
 Y_Target = target(1,:)+j*target(2,:);
 Y_out = output(1,:)+j*output(2,:);
 NMSE = fun_nmse(Y_Target,Y_out);
 fprintf("NMSE = %f (dB)\n\n",NMSE);
 
 % 绘制Level of output v.s. input
 figure(1);
 title("|Y| v.s, X_IQload");
 plot(abs(X1),abs(Y_Target),".b");
 hold on
 plot(abs(X1),abs(Y_out),".r");
 legend("Original data","Prediction data");
 grid on

 % 进行PA非线性分析
 % input_signal information
 Center_F=2.5*1e6;
 Channel_F=[-5.3 0 5.3]*1e6;
 Bandwidth=5e6;
 Samplerate=30.72e6;
 % 非线性分析
%  NMSE = fun_NMSE_cal(Y_Target,Y_out);disp(NMSE);    %计算归一化均方误差
 [PindB, AM(:,1), PM(:,1)]=fun_AM_PM_cal(X1, Y_Target');
 [~, AM(:,2), PM(:,2)]=fun_AM_PM_cal(X1, Y_out');
 % 绘制AM/AM,AM/PM特性
 figure(2);
 plot(PindB,AM(:,1),'b.');
 hold on
 plot(PindB,AM(:,2),'.r');
 xlabel('Normalized input Power (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');
 ylabel('Gain (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
 title("AM-AM");
 n=legend("PA characteristics","Modeling characteristics");
 set(n,'fontsize',14,'fontname','Times New Roman');                           %将标签的字体、间距以及最大字号进行限制；fontsize表示字号，fontname表示华文中宋，Times New Roman表示英文字体 
 set(gcf,'color','w');
 axis([-38 0 13 28]); set(gcf,'color','w');
 grid on
 
%  figure(3);
%  plot(PindB,AM(:,2),'r.');
%  xlabel('Normalized input Power (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');
%  ylabel('Gain (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
%  title("AM-AM");
%  n=legend("Prediction  characteristic");
%  set(n,'fontsize',14,'fontname','Times New Roman');                           %将标签的字体、间距以及最大字号进行限制；fontsize表示字号，fontname表示华文中宋，Times New Roman表示英文字体 
%  set(gcf,'color','w');
%  axis([-35 0 13 28]); set(gcf,'color','w');
%  grid on
 
figure(3);
plot(PindB,PM(:,1),'.b');
hold on
plot(PindB,PM(:,2),".r");
xlabel('Normalized input Power (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Phase(degree)','fontsize',15,'fontname','Times New Roman','fontweight','b'); 
title("AM-PM");
n=legend("PA characteristics","Modeling characteristics");
set(n,'fontsize',14,'fontname','Times New Roman');                           %将标签的字体、间距以及最大字号进行限制；fontsize表示字号，fontname表示华文中宋，Times New Roman表示英文字体 
set(gcf,'color','w');
axis([-25 0 -20 20]); set(gcf,'color','w');
grid on
hold off;

% figure(5)
% plot(PindB,PM(:,2),'.r');
% xlabel('Normalized input Power (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');
% ylabel('Phase(degree)','fontsize',15,'fontname','Times New Roman','fontweight','b');
% title("AM-PM");
% n=legend("Prediction characteristic");
% set(n,'fontsize',14,'fontname','Times New Roman');                           %将标签的字体、间距以及最大字号进行限制；fontsize表示字号，fontname表示华文中宋，Times New Roman表示英文字体 
% set(gcf,'color','w');
% axis([-25 0 -20 20]); set(gcf,'color','w');
% grid on
% hold off;

figure(4)
sample = 5300:1:5361;
plot(sample,abs(Y_Target(5300:5361)),'-b*');
hold on
plot(sample,abs(Y_out(5300:5361)),'-ro');
 grid on;
 xlabel("Sample (5300-5361)");
 ylabel("Voltage level");
 legend("Target","Prediction");
 title("Voltage value v.s. Sample_num from 5300 to 5361");
 
 AM(1,:) = [0 0];
 NMSE_AM = fun_NMSE_cal(AM(:,1),AM(:,2));
 NMSE_PM = fun_NMSE_cal(PM(:,1),PM(:,2));
 fprintf("NMSE of AM = %f (dB)\n\n",NMSE_AM);
 fprintf("NMSE of PM = %f (dB)\n\n",NMSE_PM);
 
 Y = [Y_Target' Y_out'];
 Spectrum1(X1',Y,5,Samplerate,Center_F,2);
