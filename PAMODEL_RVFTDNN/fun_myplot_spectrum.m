%% 绘制频谱图
function fun_myplot_spectrum(IQ_in, IQ_out, figure_number, SampleRate, Center_F)
% This function plot the gain versus the normalized input power
% SampleRate=3.84e6*4;
linestyle1=char('-ro', '-m*', '-c^', '-bv', '-gs', '-y>', '-k<');
win=hamming(1024);                                                          %生成汉明窗
Pin=fun_Power_cal(IQ_in);                                                   %计算输入信号的平均功率
Pout=fun_Power_cal(IQ_out(:,1));                                            %计算初始输出信号的平均功率
IQ_in1=fun_Power_scale(Pout,Pin,IQ_in);                                     %计算功率
[PSD1,F1]=pwelch(IQ_in1,win,50,1024,SampleRate,'centered');
F1=F1+Center_F;
[~,n]=size(IQ_out);
for i=1:n
    [PSDout(:,i),Fout(:,i)]=pwelch(IQ_out(:,i),win,50,1024,SampleRate,'centered');
end
Fout=Fout+Center_F;
figure(figure_number)
plot(F1/1e9,10*log10(PSD1),linestyle1(1,1:2));
grid on
hold on
for i=1:n
    plot(Fout(:,i)/1e9,10*log10(PSDout(:,i)),linestyle1(i+1,1:2));
end
set(gcf,'color','w');
h=legend('Input','w/o DPD','DPD iter1','DPD iter2','DPD iter3','DPD iter4','DPD iter5','DPD iter6','DPD iter7');
set(h,'fontsize',14,'fontname','Times New Roman')
% title('DE vs Normalized Pout for various x_n','fontsize',14,'fontname','Times New Roman');
xlabel('Frequency (GHz)','fontsize',15,'fontname','Times New Roman','fontweight','b');
ylabel('PSD (dBm/Hz)','fontsize',15,'fontname','Times New Roman','fontweight','b');    
hold off  
grid on
hold off
end
