function [ x ] = Encoder2(Hs, Hp, s)
%Encoder2 LDPC�����㷨2
%   ����Hs�������Ϣ����s�����ر�������x

mb = 18; kb = 18;
z = 56;

w = zeros(1, mb*z); %�м�������w
p = zeros(1, mb*z); %У���������p
x = zeros(1, (mb + kb)*z); %��������x
% ��������ʸ��s�����м���w
w = s*(Hs');

% ����x����У�����p(�㷨2)
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

%�㷨1
% pb = zeros(1, mb*z); %У���������pb
% pb = mod(w*inv(Hp'), 2);

x = [p s];
%x���е���ȷ����ʹ�� Hx_T = 0 ���м���

end