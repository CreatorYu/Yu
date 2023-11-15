% 采用RVTDFNN结构，神经元数量为15个，激活函数为tansig函数，输出层激活函数为pureln函数 
 clc;
 clear;
 
 % 加载训练数据
 data = load("PA_datatest.mat");
 input = data.input;
 target = data.output;
%  
%  Target = fun_TDL(target(1,:),target(2,:),3);
 
 % 创建神经网络
 hidensize = 20;
 trainFcn = 'trainlm';      %采用LM算法作为反向传播算法
 net = feedforwardnet(hidensize,trainFcn);  %采用feedforwardnet函数创建一个2层前向神经网络;
 net = configure(net,input,target);     %传输训练数据，每一列应代表着不同的样本
 view(net);
 
 % 训练网络
 net = train(net,input,target);
 
 %% 数据分析
 output = net(input);
 errors = gsubtract(target,output);
 performance = perform(net,target,output)       %performance = E = 1/2N*sum((target-output)^2)
 
 %% 分析
 j = sqrt(-1);
 Y_Target = target(1,:)+j*target(2,:);
 Y_out = output(1,:)+j*output(2,:);
 NMSE = fun_nmse(Y_Target,Y_out);
 fprintf("NMSE = %f (dB)\n\n",NMSE);
 X1=input(1,:)+j*input(5,:);                                          %得到正交调制信号IQ_Sample=I1+j*Q1
 
%  path('E:\matlab\bin\CODE\mycode\fun_lab',path);
%  
%  t1=load('DPD_Mea_Indirect_Learning_Phase_cal_20.mat','X1');                 %加载文件.mat 中的变量X1；并将其加载到结构体(struct)数组t1当中
%  Xt1=t1.X1;                                                                  %调用结构体数组（单元）ti中的数据X1
%  Pin_Xt= fun_Power_cal(Xt1)-2;                                                 %Xt的功率是X1的平均功率！！！！！！！！
% 
%  P_IQload= fun_Power_cal(IQ_start);                                          %计算已调信号IQ_start的功率（dBm）
%  X1 = fun_Power_scale(Pin_Xt,P_IQload,IQ_start');                               %将IQ_start放缩到abs(Xt1)/abs(IQ_start)倍
%  X1 = X1';
 
 
 
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
 [PindB, AM(:,1), PM(:,1)]=fun_AM_PM_cal(X1, Y_Target);
 [~, AM(:,2), PM(:,2)]=fun_AM_PM_cal(X1, Y_out);
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