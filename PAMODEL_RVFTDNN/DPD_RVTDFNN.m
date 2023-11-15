clc
clear;
addpath('E:\matlab\bin\CODE\mycode\data');
addpath('E:\matlab\bin\CODE\mycode\fun_lab');

%% Load Date 1
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
load("E:\matlab\bin\CODE\mycode\data\Wiener_Model_30dBm.mat",'M', 'A', 'Plow', 'Pinm_dB', 'Num_section', 'Gstatic', 'PX');
Y1=fun_Wiener_Model_LUT_cal(X1, M, A, Plow, Pinm_dB, Num_section, Gstatic, PX);
Pin = fun_Power_cal(X1);Pout = fun_Power_cal(Y1);
G = Pout-Pin;
% Gain = 10^(G/20);


%% 采用RVTDFNN结构，神经元数量为20个，激活函数为tansig函数，输出层激活函数为pureln函数 
m = 3;
V = zeros(sample_num,10);
for i = 1:10
    if i == 1
        V(:,i) = X1;
        Pin_V(i)=fun_Power_cal(V(:,1));
    else
        [V(:,i),Av_power_diff(i)] = fun_RVTDFNN(V(:,i-1),X1,Y(:,i-1),G(i-1),m);
        Pin_V(i)=fun_Power_cal(V(:,i));
    end
    Y(:,i)=fun_Wiener_Model_LUT_cal(V(:,i), M, A, Plow, Pinm_dB, Num_section, Gstatic, PX);   
    [ACLR_out(i,:),PAPR_out(i),ChannelPower_out(i,:)]= fun_ACLR_PAPR_Channel_Power_cal(Samplerate, Channel_F, Bandwidth,Y(:,i));
    Pout_average(i) = fun_Power_cal(Y(:,i));
    %Pout_peak(i)=fun_peak_cal(Y(:,i));
    P_V_average = fun_Power_cal(V(:,i));
    G(i) = Pout_average(i)-P_V_average;                                      %计算PA平均功率增益
    G2(i) = Pout_average(i)-Pin;                                      %计算带有DPD的PA系统的整体增益
    NMSE(i)=fun_NMSE_cal(X1,Y(:,i));
    if NMSE(i) < -46
     %理想输出与实际输出的NMSE小于-40dB时算法才收敛
         if abs(Av_power_diff(i)) < 0.3
         %X与V的平均功率差小于0.3dB时算法才可收敛
             break;
         end
     end
end


%% 利用训练的网络进行DPD处理
[~,index_best]=min(NMSE);
[ACLR_in,PAPR_in,ChannelPower_in]= fun_ACLR_PAPR_Channel_Power_cal(Samplerate, Channel_F, Bandwidth,X1);
fprintf("\n\nPA增益值");
G
fprintf("实际增益值");
G2
NMSE
Pin_V       
Pout_average

for i = 1:index_best
    [PindB, AM(:,i), PM(:,i)]=fun_AM_PM_cal(X1, Y(:,i));
end
for i = 1:index_best
    [~,PoutdB(:,i),~]=AM_PM_cal(X1,Y(:,i));
end       

AM_best=AM(:,index_best);
PM_best=PM(:,index_best);
figure(1);
plot(PindB,AM(:,1),'r.');
hold on;
plot(PindB,AM_best,'b.');
% hold on;
% plot(PindB,AM3,'g.');
% hold on;
% plot(PindB,AM4,'k.');
h=legend('without DPD','after DPD');                             
set(h,'fontsize',14,'fontname','Times New Roman');                           %将标签的字体、间距以及最大字号进行限制；fontsize表示字号，fontname表示华文中宋，Times New Roman表示英文字体 
set(gcf,'color','w');
xlabel('Normalized input Power (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Gain (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
axis([-20 0 13 28]); set(gcf,'color','w');
grid on
hold off

figure(2)
plot(PindB,PM(:,1),'r.');
hold on; 
plot(PindB,PM_best,'b.');
% hold on;
% plot(PindB,PM3,'g.');
% hold on;
% plot(PindB,PM4,'k.');
n=legend('without DPD','after DPD');     
set(n,'fontsize',14,'fontname','Times New Roman');
set(gcf,'color','w');
xlabel('Normalized input Power (dB)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('Phase (degree)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
set(gcf,'color','w');
axis([-25 0 -40 40]);
grid on
hold off


addpath("E:\matlab\bin\CODE\mycode\fun_lab");
addpath("E:\matlab\bin\CODE\DPD_Research");


fun_myplot_spectrum(X1, Y, 4, Samplerate,Center_F);                         %展示DPD运行过程中PSD的变换

fun_myplot_ACLR(ACLR_in,ACLR_out, 5);
fun_myplot_NMSE(NMSE, 6);
fun_myplot_PAPR(PAPR_in, PAPR_out, 7);