function A = fun_TDL(I,Q,m)
%FUN_DTL I,Q�ֱ�������������ǰ����·�����źţ�����������ʾ��m��ʾ������ȣ�A��ʾ�����������ź�
%   �˴���ʾ��ϸ˵��
sample_num = length(I);
A = zeros(2*(m+1),sample_num);
for i = 1:m+1
    TD = fun_delay(I',i-1);
    A(i,:) = TD;
end
for i = 1:m+1
    TD = fun_delay(Q',i-1);
    A(m+1+i,:) = TD;
end
end

