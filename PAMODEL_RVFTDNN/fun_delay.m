function B= fun_delay(A,D)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
N=length(A);
B=zeros(N,1);
B(D+1:N)=A(1:N-D);
end

