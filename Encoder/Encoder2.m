function [ x ] = Encoder2(Hs, Hp, s)
%Encoder2 LDPC编码算法2
%   输入Hs矩阵和信息序列s，返回编码序列x

mb = 18; kb = 18;
z = 56;

w = zeros(1, mb*z); %中间结果序列w
p = zeros(1, mb*z); %校验比特序列p
x = zeros(1, (mb + kb)*z); %编码序列x
% 利用输入矢量s计算中间结果w
w = s*(Hs');

% 利用x计算校验比特p(算法2)
p(1) = mod(w(1), 2);
idx = 1;
for i = 1:1:mb*z
    if idx > (mb-1)*z && idx <= mb*z-1
        p(idx - (mb-1)*z + 1) = mod(w(idx - (mb-1)*z + 1) + p(idx), 2);
        idx = idx - (mb-1)*z + 1;
    elseif idx > 0 && idx <= (mb-1)*z
        p(z + idx) = mod(w(z + idx) + p(idx), 2);
        idx = idx + z;
    end
end
p(mb*z) = mod(w(i)+p((mb-1)*z), 2);

%算法1
% pb = zeros(1, mb*z); %校验比特序列pb
% pb = mod(w*inv(Hp'), 2);

x = [p s];
%x序列的正确性需使用 Hx_T = 0 进行检验

end