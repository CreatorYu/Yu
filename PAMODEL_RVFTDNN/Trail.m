clc
clear;

%% load data
Center_F=2.5*1e6;
Channel_F=[-5.3 0 5.3]*1e6;
Bandwidth=5e6;
Samplerate=30.72e6;                                                         %采样频率设置为30.72MHz

j = sqrt(-1);
In_I = importdata('LTE_5MHz_In_I_30_72r0_PAPR_9r0_0_5ms.txt');                %加载同相输入信号I1
In_Q = importdata('LTE_5MHz_In_Q_30_72r0_PAPR_9r0_0_5ms.txt');                %加载正交输入信号Q1
IQ_sample=In_I+j*In_Q;                                                          %得到正交调制信号IQ_Sample=I1+j*Q1
N_sample=length(IQ_sample);                                                 %获取已调信号的长度
IQ_start=IQ_sample(1:N_sample);                                             %将已调信号注入到变量IQ_start中

t1=load('DPD_Mea_Indirect_Learning_Phase_cal_20.mat','X1');                 %加载文件.mat 中的变量X1；并将其加载到结构体(struct)数组t1当中
Xt1=t1.X1;                                                                  %调用结构体数组（单元）ti中的数据X1
Pin_Xt= fun_Power_cal(Xt1)-2;                                                 %Xt的功率是X1的平均功率！！！！！！！！

P_IQload= fun_Power_cal(IQ_start);                                          %计算已调信号IQ_start的功率（dBm）
X1=fun_Power_scale(Pin_Xt,P_IQload,IQ_start);                               %将IQ_start放缩到abs(Xt1)/abs(IQ_start)倍

%% instant PA
load("E:\matlab\bin\CODE\mycode\data\Wiener_Model_30dBm.mat",'M', 'A', 'Plow', 'Pinm_dB', 'Num_section', 'Gstatic', 'PX');
Y1=fun_Wiener_Model_LUT_cal(X1, M, A, Plow, Pinm_dB, Num_section, Gstatic, PX);
Pin = fun_Power_cal(X1);Pout = fun_Power_cal(Y1);
G = Pout-Pin;
Gain = 10^(G/20);

%% seperate the IQ of output sinal
Out_I = real(Y1);
Out_Q = imag(Y1);
isequal(Y1,Out_I+j*Out_Q)


%% RVFTDNN based PA modeling
% Construct data set
% 说明，依据重庆大学硕士论文，采用的RVFTDNN网络架构为8-17-2(2-17-2)(第1个与第5个为此时刻的信号)，记忆深度为m=3
m = 3;          %记忆深度
sample_num = length(Out_I);
% input = zeros(2*(m+1),sample_num);
% for i = 1:m+1
%     TD = fun_delay(In_I',i-1);
%     input(i,:) = TD;
% end
% for i = 1:m+1
%     TD = fun_delay(In_Q',i-1);
%     input(4+i,:) = TD;
% end
input = fun_TDL(real(X1),imag(X1),m);
output = zeros(2,sample_num);
output(1,:) = Out_I';
output(2,:) = Out_Q';

%% 数据集划分
% input_train = input(:,1:ceil(0.8*sample_num));
% output_train = output(:,1:ceil(0.8*sample_num));
% 
% input_test = input(:,ceil(0.8*sample_num)+1:end);
% output_train = output(:,ceil(0.8*sample_num)+1:end);


%% Training network
% define neural network parameters
neuron_num = [8,17,2];
network_vector = rand(neuron_num(2)*neuron_num(1)+neuron_num(2)+neuron_num(3)+(neuron_num(3)*neuron_num(2)),1);%生成神经网络参数变量vector（W与b）；列向量
% hyperparameters
training_times = 500;
loss_collection = zeros(training_times,1);
MSE_collection = zeros(training_times,1);
identity_matrix = eye(length(network_vector),length(network_vector));
regularizer = 0.9;

tic;
for i = 1:training_times
    % calculate the forward output based on the simple net(10-1 FNN)
    current_output = ...
        neural_network(input, network_vector, neuron_num(1), neuron_num(2), neuron_num(3));
    % calculate the jacobian matrix for training
    jacobian_matrix = ...
        jacobian(input, network_vector, neuron_num(1), neuron_num(2), neuron_num(3));
    % calculate the loss function
    error = output-current_output;
    error1 = sum(error,1);
    error_voc = [error(1,:),error(2,:)]';%转换为列向量
    loss_collection(i) = sum(error_voc.^2)/(2*sample_num);
    MSE_collection(i) = mean(error_voc.^2);
    
    % local optimization
   for m =1:5%在这个循环中调整regularizer，找到最合适的下降方向与步长
       %calculate the elements for training and train new network
       identity_matrix_this_time = regularizer*identity_matrix; %uI
       new_network_vector = ...
           network_vector-(jacobian_matrix'*jacobian_matrix+identity_matrix_this_time)\jacobian_matrix'*error1';
       new_output = ...
           neural_network(input, new_network_vector, neuron_num(1), neuron_num(2), neuron_num(3));
       new_error = new_output-new_output;
       new_error_vector = [new_error(1,:),new_error(2,:)]';%转换为列向量
       new_loss = sum(new_error_vector.^2)/(2*sample_num);
       % change the regularizer to update the network 
       if (new_loss <= loss_collection(i))
          regularizer = regularizer / 10; %即已经寻找到合适的u值，同时减少u，使其接近高斯牛顿法，并进行下一次迭代，沿着最好的方向找loss的最优值
          break;
      else
          regularizer = regularizer * 10; %即还未寻找到合适的u值，增大u，使其接近梯度下降
      end
   end
   if MSE_collection(i) <= 1e-9
       break;
   end
  network_vector = new_network_vector;
end
toc;            %结束计时

%% dev the network
Prediction =  ...
    neural_network(input, network_vector, neuron_num(1), neuron_num(2), neuron_num(3));
SSE = 0.5*(sum((error(1,:)).^2)+sum((error(2,:)).^2));
t = 1:training_times;
figure(1);
plot(t,log10(loss_collection),"linewidth",3);
xlabel("# iteration");ylabel("# loss value (dB)");
figure(2);
plot(t,MSE_collection,"linewidth",3);
axis([0 training_times -3 120])
xlabel("# iteration");ylabel("# Mean squared error (mse)");

%% 性能展示
Y2 = Prediction(1,:)+j*Prediction(2,:);
% 绘制Y-X图像
figure(3)
plot(abs(X1),abs(Y1),'.b');
hold on
plot(abs(X1),abs(Y2),'.r');
legend("Origin","Prediction");

NMSE=fun_NMSE_cal(Y1,Y2);
fprintf("NMSE of Original and DDRV:\n");
disp(NMSE);
Y = [Y1,Y2'];
for i =1:2
    [PindB, AM(:,i), PM(:,i)]=fun_AM_PM_cal(X1, Y(:,i));
end