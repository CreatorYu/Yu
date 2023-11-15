%% 绘制频谱图
function Spectrum1(IQ_in, IQ_out, figure_number, SampleRate, Center_F,best_vulue)
% This function plot the gain versus the normalized input power
% SampleRate=3.84e6*4;
linestyle1=char('-ro', '-m*', '-c^', '-bv', '-gs', '-y>', '-k<');
win=hamming(1024);                                                          %生成汉明窗
Pin=fun_Power_cal(IQ_in);                                                   %计算输入信号的平均功率
Pout=fun_Power_cal(IQ_out(:,1));                                            %计算初始输出信号的平均功率
IQ_in1=fun_Power_scale(Pout,Pin,IQ_in);                                     %计算功率
[PSD1,F1]=pwelch(IQ_in1,win,50,1024,SampleRate,'centered');
F1=F1+Center_F;
[PSDout(:,1),Fout(:,1)]=pwelch(IQ_out(:,1),win,50,1024,SampleRate,'centered');
[PSDout(:,2),Fout(:,2)]=pwelch(IQ_out(:,best_vulue),win,50,1024,SampleRate,'centered');
Fout=Fout+Center_F;
figure(figure_number)
% plot(F1/1e9,10*log10(PSD1),linestyle1(1,1:2));
% hold on
for i =1:2
    plot(Fout(:,i)/1e9,10*log10(PSDout(:,i)),linestyle1(i+1,1:2));
    hold on;
end
hold off;
grid on
set(gcf,'color','w');
h=legend('Target','Prediction');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Frequency (GHz)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('PSD (dBm/Hz)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off  
grid on
hold off
axis([-0.013 0.017 -110 -40]);
end

