path('E:\matlab\bin\CODE\mycode\data',path);
path('E:\matlab\bin\CODE\mycode\fun_lab',path);
Y = output1(1,:)+j*output1(2,:);
figure(1);
plot(abs(X1),abs(Y1),'.b');
hold on
plot(abs(X1),abs(Y),'.r');
% [PindB, AM1, PM1]=fun_AM_PM_cal(X1, Y1);
% [~, AM2, PM2]=fun_AM_PM_cal(X1, Y);
% figure(2);
% plot(PindB,AM1,'.r');
% hold on;
% plot(PindB,AM2,'.b');